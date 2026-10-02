const express = require('express');
const router = express.Router();
const AuthController = require('../controllers/authController');
const { authenticate } = require('../middlewares/auth');
const validate = require('../middlewares/validate');
const { otpRateLimiter } = require('../middlewares/rateLimiter');
const { loginSchema, registerSchema, requestOtpSchema, verifyOtpSchema } = require('../validations/schemas');

// Public endpoints
router.post('/auth/login', validate(loginSchema), AuthController.login);
router.post('/register', validate(registerSchema), AuthController.register);
router.post('/auth/request-otp', otpRateLimiter, validate(requestOtpSchema), AuthController.requestOtp);
router.post('/auth/verify-otp', validate(verifyOtpSchema), AuthController.verifyOtp);

// Authenticated endpoints
router.get('/auth/me', authenticate, AuthController.getProfile);

module.exports = router;
