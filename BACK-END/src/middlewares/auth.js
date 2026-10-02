const jwt = require('jsonwebtoken');
const config = require('../config/config');
const { User } = require('../models');

/**
 * Middleware to verify JWT and attach authenticated User to req.user
 */
const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        error: {
          message: 'Access denied. Missing or malformed authorization token.',
          code: 'UNAUTHORIZED'
        }
      });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, config.jwtSecret);

    const user = await User.findByPk(decoded.id);
    if (!user) {
      return res.status(401).json({
        success: false,
        error: {
          message: 'User belonging to this token no longer exists.',
          code: 'USER_NOT_FOUND'
        }
      });
    }

    req.user = user;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        error: {
          message: 'Token has expired. Please log in again.',
          code: 'TOKEN_EXPIRED'
        }
      });
    }
    return res.status(401).json({
      success: false,
      error: {
        message: 'Invalid authorization token.',
        code: 'INVALID_TOKEN'
      }
    });
  }
};

/**
 * Role-Based Access Control (RBAC) guard
 * @param {...string} allowedRoles - 'farmer', 'consumer', 'logistician', 'admin'
 */
const authorize = (...allowedRoles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: {
          message: 'Unauthenticated request.',
          code: 'UNAUTHENTICATED'
        }
      });
    }

    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        error: {
          message: `Forbidden. Role '${req.user.role}' is not authorized to access this resource. Requires one of: [${allowedRoles.join(', ')}].`,
          code: 'FORBIDDEN_ROLE'
        }
      });
    }

    next();
  };
};

module.exports = {
  authenticate,
  authorize
};
