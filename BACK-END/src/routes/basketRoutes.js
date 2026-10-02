const express = require('express');
const router = express.Router();
const BasketController = require('../controllers/basketController');
const { authenticate, authorize } = require('../middlewares/auth');
const validate = require('../middlewares/validate');
const { addToBasketSchema } = require('../validations/schemas');

// Consumer basket routes
router.get(
  '/basket',
  authenticate,
  authorize('consumer', 'farmer', 'logistician', 'admin'),
  BasketController.getBasket
);

router.post(
  '/basket/items',
  authenticate,
  authorize('consumer', 'farmer', 'logistician', 'admin'),
  validate(addToBasketSchema),
  BasketController.addToBasket
);

router.patch(
  '/basket/items/:id',
  authenticate,
  authorize('consumer', 'farmer', 'logistician', 'admin'),
  BasketController.updateItemQuantity
);

router.put(
  '/basket/items/:id',
  authenticate,
  authorize('consumer', 'farmer', 'logistician', 'admin'),
  BasketController.updateItemQuantity
);

router.delete(
  '/basket/items/:id',
  authenticate,
  authorize('consumer', 'farmer', 'logistician', 'admin'),
  BasketController.removeFromBasket
);

router.delete(
  '/basket',
  authenticate,
  authorize('consumer', 'farmer', 'logistician', 'admin'),
  BasketController.clearBasket
);

module.exports = router;
