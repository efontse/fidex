const express = require('express');
const router = express.Router();
const ProductController = require('../controllers/productController');
const { authenticate, authorize } = require('../middlewares/auth');
const validate = require('../middlewares/validate');
const { createProductSchema, updateStockSchema, updateProductSchema } = require('../validations/schemas');

// Public catalog routes
router.get('/products', ProductController.getProducts);
router.get('/products/:id', ProductController.getProductById);

// Farmer product management routes
router.get(
  '/farmer/products',
  authenticate,
  authorize('farmer', 'admin'),
  ProductController.getFarmerProducts
);

router.post(
  '/farmer/products',
  authenticate,
  authorize('farmer', 'admin'),
  validate(createProductSchema),
  ProductController.createProduct
);

router.put(
  '/farmer/products/:id',
  authenticate,
  authorize('farmer', 'admin'),
  validate(updateProductSchema),
  ProductController.updateProduct
);

router.patch(
  '/farmer/products/:id',
  authenticate,
  authorize('farmer', 'admin'),
  validate(updateProductSchema),
  ProductController.updateProduct
);

router.put(
  '/products/:id',
  authenticate,
  authorize('farmer', 'admin'),
  validate(updateProductSchema),
  ProductController.updateProduct
);

router.patch(
  '/products/:id/stock',
  authenticate,
  authorize('farmer', 'admin'),
  validate(updateStockSchema),
  ProductController.updateStock
);

router.delete(
  '/farmer/products/:id',
  authenticate,
  authorize('farmer', 'admin'),
  ProductController.deleteProduct
);

module.exports = router;
