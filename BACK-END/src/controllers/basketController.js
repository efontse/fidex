const { Basket, BasketItem, Product, User } = require('../models');

class BasketController {
  /**
   * Helper to find or create the active basket for a consumer
   */
  static async getOrCreateConsumerBasket(consumerId) {
    let basket = await Basket.findOne({ where: { consumerId } });
    if (!basket) {
      basket = await Basket.create({ consumerId });
    }
    return basket;
  }

  /**
   * Get current consumer basket with items and calculated totals
   * GET /api/basket
   */
  static async getBasket(req, res, next) {
    try {
      const basket = await BasketController.getOrCreateConsumerBasket(req.user.id);

      const items = await BasketItem.findAll({
        where: { basketId: basket.id },
        include: [
          {
            model: Product,
            as: 'product',
            include: [
              {
                model: User,
                as: 'farmer',
                attributes: ['id', 'fullName']
              }
            ]
          }
        ]
      });

      let subtotal = 0;
      const formattedItems = items.map((item) => {
        const itemPrice = item.product ? Number(item.product.price) : 0;
        const lineTotal = itemPrice * item.quantity;
        subtotal += lineTotal;

        return {
          id: item.id,
          productId: item.productId,
          quantity: item.quantity,
          unitPrice: itemPrice,
          lineTotal: parseFloat(lineTotal.toFixed(2)),
          product: item.product
        };
      });

      return res.status(200).json({
        success: true,
        data: {
          basketId: basket.id,
          itemCount: formattedItems.length,
          subtotal: parseFloat(subtotal.toFixed(2)),
          items: formattedItems
        }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Add item to basket or increment quantity
   * POST /api/basket/items
   */
  static async addToBasket(req, res, next) {
    try {
      const { productId, quantity = 1 } = req.body;

      const product = await Product.findByPk(productId);
      if (!product) {
        return res.status(404).json({
          success: false,
          error: { message: 'Product not found', code: 'PRODUCT_NOT_FOUND' }
        });
      }

      if (product.quantity < quantity) {
        return res.status(400).json({
          success: false,
          error: {
            message: `Requested quantity exceeds available stock (${product.quantity} ${product.unit} available)`,
            code: 'INSUFFICIENT_STOCK'
          }
        });
      }

      const basket = await BasketController.getOrCreateConsumerBasket(req.user.id);

      let item = await BasketItem.findOne({
        where: { basketId: basket.id, productId }
      });

      if (item) {
        const newQty = item.quantity + quantity;
        if (product.quantity < newQty) {
          return res.status(400).json({
            success: false,
            error: {
              message: `Total requested quantity (${newQty}) exceeds available stock (${product.quantity})`,
              code: 'INSUFFICIENT_STOCK'
            }
          });
        }
        item.quantity = newQty;
        await item.save();
      } else {
        item = await BasketItem.create({
          basketId: basket.id,
          productId,
          quantity
        });
      }

      return res.status(200).json({
        success: true,
        message: 'Item added to basket',
        data: { item }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update quantity of an item in basket
   * PATCH/PUT /api/basket/items/:id
   */
  static async updateItemQuantity(req, res, next) {
    try {
      const { id } = req.params;
      const { quantity } = req.body;

      if (!quantity || quantity < 1) {
        return res.status(400).json({
          success: false,
          error: { message: 'Quantity must be at least 1', code: 'INVALID_QUANTITY' }
        });
      }

      const basket = await BasketController.getOrCreateConsumerBasket(req.user.id);
      const item = await BasketItem.findOne({
        where: { id, basketId: basket.id },
        include: [{ model: Product, as: 'product' }]
      });

      if (!item) {
        return res.status(404).json({
          success: false,
          error: { message: 'Basket item not found', code: 'ITEM_NOT_FOUND' }
        });
      }

      if (item.product && item.product.quantity < quantity) {
        return res.status(400).json({
          success: false,
          error: {
            message: `Requested quantity exceeds available stock (${item.product.quantity} ${item.product.unit} available)`,
            code: 'INSUFFICIENT_STOCK'
          }
        });
      }

      item.quantity = quantity;
      await item.save();

      return res.status(200).json({
        success: true,
        message: 'Basket item updated',
        data: { item }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Remove item from basket
   * DELETE /api/basket/items/:id
   */
  static async removeFromBasket(req, res, next) {
    try {
      const { id } = req.params;
      const basket = await BasketController.getOrCreateConsumerBasket(req.user.id);

      const item = await BasketItem.findOne({
        where: { id, basketId: basket.id }
      });

      if (!item) {
        return res.status(404).json({
          success: false,
          error: { message: 'Basket item not found', code: 'ITEM_NOT_FOUND' }
        });
      }

      await item.destroy();

      return res.status(200).json({
        success: true,
        message: 'Item removed from basket'
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Clear all items in consumer basket
   * DELETE /api/basket
   */
  static async clearBasket(req, res, next) {
    try {
      const basket = await BasketController.getOrCreateConsumerBasket(req.user.id);
      await BasketItem.destroy({ where: { basketId: basket.id } });

      return res.status(200).json({
        success: true,
        message: 'Basket cleared successfully'
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = BasketController;
