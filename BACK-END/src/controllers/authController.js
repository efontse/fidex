const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const config = require('../config/config');
const { User, Session } = require('../models');
const OtpService = require('../services/otpService');

class AuthController {
  /**
   * Log in user with email and password
   * POST /api/auth/login
   */
  static async login(req, res, next) {
    try {
      const { email, password, farmingField, companyName } = req.body;

      if (!email || !password) {
        return res.status(400).json({
          success: false,
          error: {
            message: 'Email and password are required.',
            code: 'MISSING_CREDENTIALS'
          }
        });
      }

      const user = await User.findOne({ where: { email: email.toLowerCase().trim() } });
      if (!user) {
        return res.status(401).json({
          success: false,
          error: {
            message: 'Invalid email or password.',
            code: 'INVALID_CREDENTIALS'
          }
        });
      }

      // Check password
      const isMatch = await bcrypt.compare(password, user.password);
      if (!isMatch) {
        return res.status(401).json({
          success: false,
          error: {
            message: 'Invalid email or password.',
            code: 'INVALID_CREDENTIALS'
          }
        });
      }

      // Check active status
      if (!user.isActive) {
        return res.status(403).json({
          success: false,
          error: {
            message: 'Your account has been deactivated. Please contact support.',
            code: 'ACCOUNT_DEACTIVATED'
          }
        });
      }

      // If user is a farmer and provided/updated farming field, save it
      let updated = false;
      if (user.role === 'farmer' && farmingField && farmingField.trim()) {
        user.farmingField = farmingField.trim();
        updated = true;
      }

      // If user is a logistician and provided/updated company name, save it
      if (user.role === 'logistician' && companyName && companyName.trim()) {
        user.companyName = companyName.trim();
        updated = true;
      }

      if (updated) {
        await user.save();
      }

      // Generate JWT
      const token = jwt.sign(
        {
          id: user.id,
          email: user.email,
          role: user.role,
          fullName: user.fullName,
          farmingField: user.farmingField,
          companyName: user.companyName
        },
        config.jwtSecret,
        { expiresIn: config.jwtExpiresIn }
      );

      return res.status(200).json({
        success: true,
        message: 'Authentication successful',
        data: {
          token,
          user: {
            id: user.id,
            fullName: user.fullName,
            email: user.email,
            role: user.role,
            farmingField: user.farmingField,
            companyName: user.companyName,
            phoneNumber: user.phoneNumber,
            address: user.address,
            createdAt: user.createdAt
          }
        }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Register a new user with email and password
   * POST /api/register
   */
  static async register(req, res, next) {
    try {
      const {
        fullName,
        email,
        password,
        role = 'consumer',
        farmingField,
        companyName,
        phoneNumber,
        address
      } = req.body;

      if (!email || !password) {
        return res.status(400).json({
          success: false,
          error: {
            message: 'Email and password are required.',
            code: 'MISSING_CREDENTIALS'
          }
        });
      }

      const normalizedEmail = email.toLowerCase().trim();
      const existingUser = await User.findOne({ where: { email: normalizedEmail } });
      if (existingUser) {
        return res.status(409).json({
          success: false,
          error: {
            message: 'A user with this email address already exists. Please log in.',
            code: 'EMAIL_ALREADY_REGISTERED'
          }
        });
      }

      // Hash password
      const hashedPassword = await bcrypt.hash(password, 10);

      const user = await User.create({
        fullName,
        email: normalizedEmail,
        password: hashedPassword,
        role,
        farmingField: role === 'farmer' ? farmingField : null,
        companyName: role === 'logistician' ? companyName : null,
        phoneNumber: phoneNumber || null,
        address: address || null,
        isActive: true
      });

      // Generate JWT for immediate authenticated session
      const token = jwt.sign(
        {
          id: user.id,
          email: user.email,
          role: user.role,
          fullName: user.fullName,
          farmingField: user.farmingField,
          companyName: user.companyName
        },
        config.jwtSecret,
        { expiresIn: config.jwtExpiresIn }
      );

      return res.status(201).json({
        success: true,
        message: 'Account created successfully.',
        data: {
          token,
          user: {
            id: user.id,
            fullName: user.fullName,
            email: user.email,
            role: user.role,
            farmingField: user.farmingField,
            companyName: user.companyName,
            phoneNumber: user.phoneNumber,
            address: user.address,
            createdAt: user.createdAt
          }
        }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Request OTP for authentication (legacy support)
   * POST /api/auth/request-otp
   */
  static async requestOtp(req, res, next) {
    try {
      const { phoneNumber, deviceId } = req.body;
      const result = await OtpService.requestOtp(phoneNumber, deviceId);

      return res.status(200).json({
        success: true,
        message: result.message,
        data: {
          debugOtp: result.debugOtp
        }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Verify OTP and issue JWT (legacy support)
   * POST /api/auth/verify-otp
   */
  static async verifyOtp(req, res, next) {
    try {
      const { phoneNumber, otpCode } = req.body;
      const { user } = await OtpService.verifyOtp(phoneNumber, otpCode);

      const token = jwt.sign(
        {
          id: user.id,
          email: user.email,
          role: user.role,
          phoneNumber: user.phoneNumber
        },
        config.jwtSecret,
        { expiresIn: config.jwtExpiresIn }
      );

      return res.status(200).json({
        success: true,
        message: 'Authentication successful',
        data: {
          token,
          user: {
            id: user.id,
            fullName: user.fullName,
            email: user.email,
            role: user.role,
            farmingField: user.farmingField,
            companyName: user.companyName,
            phoneNumber: user.phoneNumber
          }
        }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get current authenticated user profile
   * GET /api/auth/me
   */
  static async getProfile(req, res, next) {
    try {
      return res.status(200).json({
        success: true,
        data: {
          user: {
            id: req.user.id,
            fullName: req.user.fullName,
            email: req.user.email,
            phoneNumber: req.user.phoneNumber,
            role: req.user.role,
            farmingField: req.user.farmingField,
            companyName: req.user.companyName,
            address: req.user.address,
            isActive: req.user.isActive,
            createdAt: req.user.createdAt
          }
        }
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = AuthController;
