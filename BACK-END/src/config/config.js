require('dotenv').config();

module.exports = {
  port: process.env.PORT || 5000,
  nodeEnv: process.env.NODE_ENV || 'development',
  jwtSecret: process.env.JWT_SECRET || 'farmora_jwt_secret_key_default',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '7d',
  otpExpiryMinutes: parseInt(process.env.OTP_EXPIRY_MINUTES || '5', 10),
  maxOtpAttempts: parseInt(process.env.MAX_OTP_ATTEMPTS || '3', 10),
  paymentApiKey: process.env.PAYMENT_API_KEY || 'mock_payment_key',
  geolocationApiKey: process.env.GEOLOCATION_API_KEY || 'mock_geo_key',
  db: {
    dialect: 'mysql',
    host: process.env.DB_HOST || '127.0.0.1',
    port: parseInt(process.env.DB_PORT || '3306', 10),
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'farmora_db'
  }
};
