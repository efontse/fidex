const { Op } = require('sequelize');
const { Delivery, Order, OrderItem, Product, User } = require('../models');
const GeolocationService = require('../services/geolocationService');

class LogisticsController {
  /**
   * Get deliveries for logisticians: both unassigned (available to claim) and assigned to caller
   * GET /api/logistician/deliveries
   */
  static async getDeliveries(req, res, next) {
    try {
      const { status, filter } = req.query;

      let where = {};

      if (filter === 'available') {
        where.logisticianId = null;
        where.status = 'pending';
      } else if (filter === 'my') {
        where.logisticianId = req.user.id;
      } else {
        // Show both available and assigned to this logistician
        where = {
          [Op.or]: [
            { logisticianId: null },
            { logisticianId: req.user.id }
          ]
        };
      }

      if (status) {
        where.status = status;
      }

      const deliveries = await Delivery.findAll({
        where,
        include: [
          {
            model: Order,
            as: 'order',
            include: [
              {
                model: User,
                as: 'consumer',
                attributes: ['id', 'fullName', 'phoneNumber']
              },
              {
                model: OrderItem,
                as: 'items',
                include: [
                  {
                    model: Product,
                    as: 'product',
                    include: [{ model: User, as: 'farmer', attributes: ['id', 'fullName', 'phoneNumber'] }]
                  }
                ]
              }
            ]
          }
        ],
        order: [['createdAt', 'DESC']]
      });

      return res.status(200).json({
        success: true,
        data: { deliveries }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Logistician claims an available delivery
   * POST /api/logistician/deliveries/:id/claim
   */
  static async claimDelivery(req, res, next) {
    try {
      const { id } = req.params;

      const delivery = await Delivery.findByPk(id);
      if (!delivery) {
        return res.status(404).json({
          success: false,
          error: { message: 'Delivery not found', code: 'DELIVERY_NOT_FOUND' }
        });
      }

      if (delivery.logisticianId && delivery.logisticianId !== req.user.id) {
        return res.status(409).json({
          success: false,
          error: { message: 'This delivery has already been assigned to another logistician', code: 'DELIVERY_ALREADY_ASSIGNED' }
        });
      }

      delivery.logisticianId = req.user.id;
      delivery.status = 'assigned';
      await delivery.save();

      return res.status(200).json({
        success: true,
        message: 'Delivery claimed successfully',
        data: { delivery }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Contact producer for pickup coordination
   * POST /api/logistician/deliveries/:id/contact-producer
   */
  static async contactProducer(req, res, next) {
    try {
      const { id } = req.params;

      const delivery = await Delivery.findByPk(id, {
        include: [
          {
            model: Order,
            as: 'order',
            include: [
              {
                model: OrderItem,
                as: 'items',
                include: [
                  {
                    model: Product,
                    as: 'product',
                    include: [{ model: User, as: 'farmer', attributes: ['id', 'fullName', 'phoneNumber'] }]
                  }
                ]
              }
            ]
          }
        ]
      });

      if (!delivery) {
        return res.status(404).json({
          success: false,
          error: { message: 'Delivery not found', code: 'DELIVERY_NOT_FOUND' }
        });
      }

      // Extract unique producer(s) contact info from order items
      const producers = [];
      const seen = new Set();

      if (delivery.order && delivery.order.items) {
        for (const item of delivery.order.items) {
          if (item.product && item.product.farmer && !seen.has(item.product.farmer.id)) {
            seen.add(item.product.farmer.id);
            producers.push({
              producerId: item.product.farmer.id,
              producerName: item.product.farmer.fullName,
              phoneNumber: item.product.farmer.phoneNumber,
              productSupplied: item.product.name,
              pickupPoint: delivery.pickupPoint
            });
          }
        }
      }

      return res.status(200).json({
        success: true,
        message: 'Producer contact details retrieved for pickup coordination',
        data: {
          deliveryId: delivery.id,
          pickupPoint: delivery.pickupPoint,
          producers
        }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Locate consumer using Geolocation API
   * POST /api/logistician/deliveries/:id/locate-consumer
   */
  static async locateConsumer(req, res, next) {
    try {
      const { id } = req.params;

      const delivery = await Delivery.findByPk(id, {
        include: [
          {
            model: Order,
            as: 'order',
            include: [{ model: User, as: 'consumer', attributes: ['id', 'fullName', 'phoneNumber'] }]
          }
        ]
      });

      if (!delivery) {
        return res.status(404).json({
          success: false,
          error: { message: 'Delivery not found', code: 'DELIVERY_NOT_FOUND' }
        });
      }

      const consumerLocation = await GeolocationService.locate(delivery.dropoffPoint);
      const pickupLocation = await GeolocationService.locate(delivery.pickupPoint);
      const distanceKm = GeolocationService.getDistance(pickupLocation, consumerLocation);

      return res.status(200).json({
        success: true,
        data: {
          deliveryId: delivery.id,
          consumer: delivery.order ? delivery.order.consumer : null,
          dropoffPoint: delivery.dropoffPoint,
          coordinates: consumerLocation,
          distanceFromPickupKm: distanceKm,
          estimatedTransitMinutes: Math.round((distanceKm / 35) * 60 + 15)
        }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update shipment status
   * PATCH /api/logistician/deliveries/:id/status
   */
  static async updateStatus(req, res, next) {
    try {
      const { id } = req.params;
      const { status } = req.body;

      const delivery = await Delivery.findByPk(id, {
        include: [{ model: Order, as: 'order' }]
      });

      if (!delivery) {
        return res.status(404).json({
          success: false,
          error: { message: 'Delivery not found', code: 'DELIVERY_NOT_FOUND' }
        });
      }

      if (req.user.role !== 'admin' && delivery.logisticianId !== req.user.id) {
        return res.status(403).json({
          success: false,
          error: { message: 'You are not assigned to this delivery', code: 'UNAUTHORIZED_DELIVERY' }
        });
      }

      delivery.status = status;
      if (status === 'delivered') {
        delivery.deliveredAt = new Date();
      }
      await delivery.save();

      // Synchronize order status
      if (delivery.order) {
        if (status === 'picked_up' || status === 'in_transit') {
          delivery.order.status = 'in_transit';
        } else if (status === 'delivered') {
          delivery.order.status = 'delivered';
        } else if (status === 'cancelled') {
          delivery.order.status = 'cancelled';
        }
        await delivery.order.save();
      }

      return res.status(200).json({
        success: true,
        message: `Shipment status updated to '${status}'`,
        data: { delivery }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Consumer delivery tracking
   * GET /api/deliveries/order/:orderId
   */
  static async getOrderDelivery(req, res, next) {
    try {
      const { orderId } = req.params;

      const delivery = await Delivery.findOne({
        where: { orderId },
        include: [
          {
            model: Order,
            as: 'order',
            include: [{ model: User, as: 'consumer', attributes: ['id', 'fullName'] }]
          },
          {
            model: User,
            as: 'logistician',
            attributes: ['id', 'fullName', 'phoneNumber']
          }
        ]
      });

      if (!delivery) {
        return res.status(404).json({
          success: false,
          error: { message: 'No delivery record found for this order', code: 'DELIVERY_NOT_FOUND' }
        });
      }

      // Check permission: consumer owner, logistician, or admin
      if (
        req.user.role !== 'admin' &&
        req.user.role !== 'logistician' &&
        delivery.order &&
        delivery.order.consumerId !== req.user.id
      ) {
        return res.status(403).json({
          success: false,
          error: { message: 'Unauthorized tracking access', code: 'UNAUTHORIZED' }
        });
      }

      return res.status(200).json({
        success: true,
        data: { delivery }
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = LogisticsController;
