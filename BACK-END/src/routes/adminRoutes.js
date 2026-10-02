const express = require('express');
const router = express.Router();
const AdminController = require('../controllers/adminController');
const { authenticate, authorize } = require('../middlewares/auth');
const validate = require('../middlewares/validate');
const { updateUserRoleSchema, moderateProductSchema } = require('../validations/schemas');

// All admin routes require admin authentication and authorization
router.use(authenticate, authorize('admin'));

// Account governance
router.get('/admin/users', AdminController.getUsers);
router.patch('/admin/users/:id/role', validate(updateUserRoleSchema), AdminController.updateUserRole);
router.delete('/admin/users/:id', AdminController.deleteUser);

// Content moderation
router.patch('/admin/products/:id/moderate', validate(moderateProductSchema), AdminController.moderateProduct);

// Platform configuration & settings
router.get('/admin/settings', AdminController.getSettings);
router.patch('/admin/settings', AdminController.updateSettings);

// Business analytics
router.get('/admin/analytics', AdminController.getAnalytics);

module.exports = router;
