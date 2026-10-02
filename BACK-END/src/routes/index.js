const express = require('express');
const router = express.Router();
const { sequelize } = require('../config/database');
const UploadController = require('../controllers/uploadController');
const { authenticate } = require('../middlewares/auth');

const authRoutes = require('./authRoutes');
const productRoutes = require('./productRoutes');
const valueChainRoutes = require('./valueChainRoutes');
const basketRoutes = require('./basketRoutes');
const checkoutRoutes = require('./checkoutRoutes');
const logisticsRoutes = require('./logisticsRoutes');
const adminRoutes = require('./adminRoutes');

// Health Check Endpoint
router.get('/health', async (req, res) => {
  let dbStatus = 'healthy';
  try {
    await sequelize.authenticate();
  } catch (error) {
    dbStatus = `degraded: ${error.message}`;
  }

  res.status(200).json({
    success: true,
    service: 'Farmora Agricultural Networking Platform API',
    status: 'ONLINE',
    dialect: sequelize.getDialect(),
    database: dbStatus,
    timestamp: new Date().toISOString()
  });
});

// Image Upload Endpoint (Public or authenticated)
router.post('/upload', UploadController.uploadImage);

// Mount domain routes
router.use('/', authRoutes);
router.use('/', productRoutes);
router.use('/', valueChainRoutes);
router.use('/', basketRoutes);
router.use('/', checkoutRoutes);
router.use('/', logisticsRoutes);
router.use('/', adminRoutes);

module.exports = router;
