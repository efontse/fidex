const express = require('express');
const router = express.Router();
const CheckoutController = require('../controllers/checkoutController');
const { authenticate, authorize } = require('../middlewares/auth');
const validate = require('../middlewares/validate');
const { checkoutSchema } = require('../validations/schemas');

// Checkout routes
router.post(
  '/checkout',
  authenticate,
  authorize('consumer', 'admin'),
  validate(checkoutSchema),
  CheckoutController.checkout
);

// Consumer order history
router.get(
  '/orders',
  authenticate,
  authorize('consumer', 'admin'),
  CheckoutController.getConsumerOrders
);

router.get(
  '/orders/:id',
  authenticate,
  CheckoutController.getOrderById
);

module.exports = router;
