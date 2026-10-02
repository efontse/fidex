const express = require('express');
const router = express.Router();
const LogisticsController = require('../controllers/logisticsController');
const { authenticate, authorize } = require('../middlewares/auth');
const validate = require('../middlewares/validate');
const { updateDeliveryStatusSchema } = require('../validations/schemas');

// Logistician routes
router.get(
  '/logistician/deliveries',
  authenticate,
  authorize('logistician', 'admin'),
  LogisticsController.getDeliveries
);

router.post(
  '/logistician/deliveries/:id/claim',
  authenticate,
  authorize('logistician', 'admin'),
  LogisticsController.claimDelivery
);

router.post(
  '/logistician/deliveries/:id/contact-producer',
  authenticate,
  authorize('logistician', 'admin'),
  LogisticsController.contactProducer
);

router.post(
  '/logistician/deliveries/:id/locate-consumer',
  authenticate,
  authorize('logistician', 'admin'),
  LogisticsController.locateConsumer
);

router.patch(
  '/logistician/deliveries/:id/status',
  authenticate,
  authorize('logistician', 'admin'),
  validate(updateDeliveryStatusSchema),
  LogisticsController.updateStatus
);

// Consumer/public tracking for confirmed order
router.get(
  '/deliveries/order/:orderId',
  authenticate,
  LogisticsController.getOrderDelivery
);

module.exports = router;
