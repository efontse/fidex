const { ValueChainEvent, Product, User } = require('../models');

class ValueChainController {
  /**
   * Farmer records a new status event in the value chain
   * POST /api/farmer/value-chain
   */
  static async createEvent(req, res, next) {
    try {
      const { productId, status, notes, timestamp } = req.body;

      if (productId) {
        const product = await Product.findByPk(productId);
        if (!product) {
          return res.status(404).json({
            success: false,
            error: { message: 'Referenced product not found', code: 'PRODUCT_NOT_FOUND' }
          });
        }
        if (req.user.role !== 'admin' && product.farmerId !== req.user.id) {
          return res.status(403).json({
            success: false,
            error: { message: 'You can only log value chain events for your own products', code: 'UNAUTHORIZED' }
          });
        }
      }

      const event = await ValueChainEvent.create({
        farmerId: req.user.id,
        productId: productId || null,
        status,
        notes: notes || null,
        timestamp: timestamp || new Date()
      });

      return res.status(201).json({
        success: true,
        message: 'Value chain event recorded successfully',
        data: { event }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * List all value chain events for the logged-in Farmer
   * GET /api/farmer/value-chain
   */
  static async getFarmerEvents(req, res, next) {
    try {
      const events = await ValueChainEvent.findAll({
        where: { farmerId: req.user.id },
        order: [['timestamp', 'DESC']],
        include: [
          {
            model: Product,
            as: 'product',
            attributes: ['id', 'name', 'category', 'unit']
          }
        ]
      });

      return res.status(200).json({
        success: true,
        data: { events }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Public traceability view: retrieve chronological lifecycle events for a specific product
   * GET /api/value-chain/product/:productId
   */
  static async getProductTimeline(req, res, next) {
    try {
      const { productId } = req.params;

      const product = await Product.findByPk(productId, {
        attributes: ['id', 'name', 'category', 'harvestDate', 'farmerId'],
        include: [
          {
            model: User,
            as: 'farmer',
            attributes: ['id', 'fullName']
          }
        ]
      });

      if (!product) {
        return res.status(404).json({
          success: false,
          error: { message: 'Product not found', code: 'PRODUCT_NOT_FOUND' }
        });
      }

      const events = await ValueChainEvent.findAll({
        where: { productId },
        order: [['timestamp', 'ASC']]
      });

      return res.status(200).json({
        success: true,
        data: {
          product,
          timeline: events
        }
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = ValueChainController;
