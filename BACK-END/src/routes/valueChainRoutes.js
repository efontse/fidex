const express = require('express');
const router = express.Router();
const ValueChainController = require('../controllers/valueChainController');
const { authenticate, authorize } = require('../middlewares/auth');
const validate = require('../middlewares/validate');
const { createValueChainEventSchema } = require('../validations/schemas');

// Public traceability timeline for consumers
router.get('/value-chain/product/:productId', ValueChainController.getProductTimeline);

// Farmer value chain management routes
router.get(
  '/farmer/value-chain',
  authenticate,
  authorize('farmer', 'admin'),
  ValueChainController.getFarmerEvents
);

router.post(
  '/farmer/value-chain',
  authenticate,
  authorize('farmer', 'admin'),
  validate(createValueChainEventSchema),
  ValueChainController.createEvent
);

module.exports = router;
