const { User, Session } = require('../models');
const config = require('../config/config');

class OtpService {
  /**
   * Generate a 6-digit numeric OTP code
   */
  static generateCode(length = 6) {
    let code = '';
    for (let i = 0; i < length; i++) {
      code += Math.floor(Math.random() * 10).toString();
    }
    return code;
  }

  /**
   * Request an OTP for a user's phone number
   */
  static async requestOtp(phoneNumber, deviceId = 'web_client') {
    const user = await User.findOne({ where: { phoneNumber } });
    if (!user) {
      const error = new Error('No user found with this phone number. Please register first.');
      error.statusCode = 404;
      throw error;
    }

    let session = await Session.findOne({ where: { userId: user.id } });

    // Check lockout
    if (session && session.failedAttempts >= config.maxOtpAttempts) {
      // Check if lockout is still within cooldown (e.g., 15 minutes)
      const lockDurationMinutes = 15;
      const lockoutExpires = new Date(new Date(session.updatedAt).getTime() + lockDurationMinutes * 60000);
      if (new Date() < lockoutExpires) {
        const remainingMinutes = Math.ceil((lockoutExpires - new Date()) / 60000);
        const error = new Error(`Account locked due to 3 consecutive failed OTP attempts. Please try again in ${remainingMinutes} minute(s).`);
        error.statusCode = 423; // Locked
        throw error;
      } else {
        // Cooldown passed, reset failed attempts
        session.failedAttempts = 0;
      }
    }

    const otpCode = this.generateCode(6);
    const expiresAt = new Date(Date.now() + config.otpExpiryMinutes * 60 * 1000);

    if (!session) {
      session = await Session.create({
        userId: user.id,
        otpCode,
        deviceId,
        failedAttempts: 0,
        expiresAt,
        isActive: false
      });
    } else {
      session.otpCode = otpCode;
      session.deviceId = deviceId;
      session.expiresAt = expiresAt;
      session.isActive = false;
      await session.save();
    }

    // SMS Gateway Stub (log to console during development)
    console.log(`[SMS-STUB] >>> Dispatched OTP [${otpCode}] to ${phoneNumber} (valid for ${config.otpExpiryMinutes} mins) <<<`);

    return {
      success: true,
      message: `OTP sent successfully to ${phoneNumber}`,
      // Provide OTP in response only during development or test for easy integration
      debugOtp: config.nodeEnv !== 'production' ? otpCode : undefined
    };
  }

  /**
   * Verify an OTP for a phone number
   */
  static async verifyOtp(phoneNumber, otpCode) {
    const user = await User.findOne({ where: { phoneNumber } });
    if (!user) {
      const error = new Error('User not found.');
      error.statusCode = 404;
      throw error;
    }

    const session = await Session.findOne({ where: { userId: user.id } });
    if (!session || !session.otpCode) {
      const error = new Error('No active OTP request found. Please request a new OTP.');
      error.statusCode = 400;
      throw error;
    }

    // Check lockout
    if (session.failedAttempts >= config.maxOtpAttempts) {
      const error = new Error('Account is locked due to too many failed OTP attempts. Request a new OTP after cooldown.');
      error.statusCode = 423;
      throw error;
    }

    // Check expiry
    if (new Date() > new Date(session.expiresAt)) {
      const error = new Error('OTP has expired. Please request a new OTP.');
      error.statusCode = 400;
      throw error;
    }

    // Check code match
    if (session.otpCode !== otpCode) {
      session.failedAttempts += 1;
      await session.save();

      const remainingAttempts = config.maxOtpAttempts - session.failedAttempts;
      if (remainingAttempts <= 0) {
        const error = new Error('Invalid OTP. Maximum attempts exceeded. Your session is temporarily locked.');
        error.statusCode = 423;
        throw error;
      }

      const error = new Error(`Invalid OTP. You have ${remainingAttempts} attempt(s) remaining.`);
      error.statusCode = 400;
      throw error;
    }

    // Valid OTP
    session.failedAttempts = 0;
    session.isActive = true;
    session.otpCode = null; // Invalidate after successful verification
    await session.save();

    return {
      user,
      session
    };
  }
}

module.exports = OtpService;
