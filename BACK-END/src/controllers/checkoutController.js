const { sequelize, Basket, BasketItem, Product, Order, OrderItem, Payment, Delivery, User } = require('../models');
const PaymentService = require('../services/paymentService');
const GeolocationService = require('../services/geolocationService');

class CheckoutController {
  /**
   * Process Checkout: Converts consumer basket into an Order + OrderItems, charges Payment API,
   * updates inventory, and auto-dispatches Delivery upon approved payment within an ACID transaction.
   * POST /api/checkout
   */
  static async checkout(req, res, next) {
    const t = await sequelize.transaction();

    try {
      const { deliveryAddress, paymentMethod = 'card', notes } = req.body;

      // 1. Fetch consumer basket with items
      const basket = await Basket.findOne({
        where: { consumerId: req.user.id },
        include: [
          {
            model: BasketItem,
            as: 'items',
            include: [{ model: Product, as: 'product' }]
          }
        ],
        transaction: t
      });

      if (!basket || !basket.items || basket.items.length === 0) {
        await t.rollback();
        return res.status(400).json({
          success: false,
          error: { message: 'Your basket is empty. Add products before checking out.', code: 'BASKET_EMPTY' }
        });
      }

      // 2. Validate stock and compute totalAmount
      let totalAmount = 0;
      const orderItemsData = [];
      const stockUpdates = [];
      let pickupLocation = 'Central Farm Depot, Sector 4'; // Default pickup

      for (const item of basket.items) {
        const product = item.product;
        if (!product) {
          await t.rollback();
          return res.status(400).json({
            success: false,
            error: { message: `Product for basket item ${item.id} is no longer available`, code: 'PRODUCT_UNAVAILABLE' }
          });
        }

        if (product.quantity < item.quantity) {
          await t.rollback();
          return res.status(400).json({
            success: false,
            error: {
              message: `Insufficient stock for '${product.name}'. Available: ${product.quantity}, requested: ${item.quantity}`,
              code: 'INSUFFICIENT_STOCK'
            }
          });
        }

        const subtotal = Number(product.price) * item.quantity;
        totalAmount += subtotal;

        orderItemsData.push({
          productId: product.id,
          qty: item.quantity,
          subtotal: parseFloat(subtotal.toFixed(2))
        });

        stockUpdates.push({
          product,
          newQuantity: product.quantity - item.quantity
        });
      }

      totalAmount = parseFloat(totalAmount.toFixed(2));

      // 3. Create Order
      const order = await Order.create({
        consumerId: req.user.id,
        orderDate: new Date(),
        totalAmount,
        status: 'pending_payment',
        deliveryAddress,
        notes: notes || null
      }, { transaction: t });

      // 4. Create OrderItems & Decrement Stock
      for (const itemData of orderItemsData) {
        await OrderItem.create({
          orderId: order.id,
          ...itemData
        }, { transaction: t });
      }

      for (const update of stockUpdates) {
        update.product.quantity = update.newQuantity;
        await update.product.save({ transaction: t });
      }

      // 5. Clear consumer basket items
      await BasketItem.destroy({
        where: { basketId: basket.id },
        transaction: t
      });

      // 6. Call external Payment API
      const paymentResult = await PaymentService.charge({
        amount: totalAmount,
        method: paymentMethod,
        orderId: order.id,
        metadata: { consumerId: req.user.id }
      });

      // 7. Record Payment (1:1 with Order)
      const payment = await Payment.create({
        orderId: order.id,
        amount: totalAmount,
        status: paymentResult.success ? 'completed' : 'failed',
        method: paymentMethod,
        providerReference: paymentResult.providerReference
      }, { transaction: t });

      let delivery = null;

      // 8. If Payment Approved: transition Order to 'paid' and auto-create Delivery record
      if (paymentResult.success) {
        order.status = 'paid';
        await order.save({ transaction: t });

        // Calculate geolocation and route
        const route = await GeolocationService.calculateDeliveryRoute(pickupLocation, deliveryAddress);

        delivery = await Delivery.create({
          orderId: order.id,
          logisticianId: null, // Available for logisticians to claim
          pickupPoint: pickupLocation,
          dropoffPoint: deliveryAddress,
          pickupCoordinates: `${route.pickup.lat},${route.pickup.lng}`,
          dropoffCoordinates: `${route.dropoff.lat},${route.dropoff.lng}`,
          estimatedDistanceKm: route.distanceKm,
          status: 'pending'
        }, { transaction: t });
      }

      await t.commit();

      if (!paymentResult.success) {
        return res.status(402).json({
          success: false,
          error: {
            message: paymentResult.reason || 'Payment charge was declined.',
            code: 'PAYMENT_DECLINED'
          },
          data: {
            orderId: order.id,
            totalAmount,
            status: order.status,
            paymentStatus: payment.status
          }
        });
      }

      return res.status(201).json({
        success: true,
        message: 'Order created and payment completed successfully. Delivery has been queued.',
        data: {
          order: {
            id: order.id,
            totalAmount: order.totalAmount,
            status: order.status,
            orderDate: order.orderDate,
            deliveryAddress: order.deliveryAddress
          },
          payment: {
            id: payment.id,
            status: payment.status,
            providerReference: payment.providerReference,
            method: payment.method
          },
          delivery: {
            id: delivery.id,
            status: delivery.status,
            pickupPoint: delivery.pickupPoint,
            dropoffPoint: delivery.dropoffPoint,
            estimatedDistanceKm: delivery.estimatedDistanceKm
          }
        }
      });
    } catch (error) {
      await t.rollback();
      next(error);
    }
  }

  /**
   * Get orders for the logged-in consumer
   * GET /api/orders
   */
  static async getConsumerOrders(req, res, next) {
    try {
      const orders = await Order.findAll({
        where: { consumerId: req.user.id },
        include: [
          {
            model: OrderItem,
            as: 'items',
            include: [{ model: Product, as: 'product' }]
          },
          {
            model: Payment,
            as: 'payment'
          },
          {
            model: Delivery,
            as: 'delivery'
          }
        ],
        order: [['createdAt', 'DESC']]
      });

      return res.status(200).json({
        success: true,
        data: { orders }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get single order by ID
   * GET /api/orders/:id
   */
  static async getOrderById(req, res, next) {
    try {
      const { id } = req.params;

      const order = await Order.findByPk(id, {
        include: [
          {
            model: OrderItem,
            as: 'items',
            include: [{ model: Product, as: 'product' }]
          },
          {
            model: Payment,
            as: 'payment'
          },
          {
            model: Delivery,
            as: 'delivery',
            include: [{ model: User, as: 'logistician', attributes: ['id', 'fullName', 'phoneNumber'] }]
          }
        ]
      });

      if (!order) {
        return res.status(404).json({
          success: false,
          error: { message: 'Order not found', code: 'ORDER_NOT_FOUND' }
        });
      }

      if (req.user.role !== 'admin' && order.consumerId !== req.user.id) {
        return res.status(403).json({
          success: false,
          error: { message: 'Access denied to this order', code: 'UNAUTHORIZED' }
        });
      }

      return res.status(200).json({
        success: true,
        data: { order }
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = CheckoutController;
