const { Op } = require('sequelize');
const { User, Product, Order, Delivery, Payment } = require('../models');

// In-memory system settings store with sensible platform defaults
let systemSettings = {
  platformFeePercentage: 3.5,
  payoutSchedule: 'weekly',
  maintenanceMode: false,
  allowedCategories: ['Pisciculture', 'Horticulture', 'Apiculture', 'Dairy Farming', 'Poultry Farm', 'Tubers', 'Grains', 'Vegetables', 'Fruits', 'Cash Crops'],
  autoAssignDeliveries: false
};

class AdminController {
  /**
   * Get list of users with optional role filtering and search
   * GET /api/admin/users
   */
  static async getUsers(req, res, next) {
    try {
      const { role, search, page = 1, limit = 50 } = req.query;

      const where = {};
      if (role) {
        where.role = role;
      }
      if (search) {
        where[Op.or] = [
          { fullName: { [Op.like]: `%${search}%` } },
          { email: { [Op.like]: `%${search}%` } },
          { phoneNumber: { [Op.like]: `%${search}%` } }
        ];
      }

      const offset = (parseInt(page, 10) - 1) * parseInt(limit, 10);

      const { count, rows } = await User.findAndCountAll({
        where,
        attributes: ['id', 'fullName', 'email', 'phoneNumber', 'role', 'farmingField', 'companyName', 'createdAt'],
        limit: parseInt(limit, 10),
        offset,
        order: [['createdAt', 'DESC']]
      });

      return res.status(200).json({
        success: true,
        data: {
          total: count,
          page: parseInt(page, 10),
          totalPages: Math.ceil(count / parseInt(limit, 10)),
          users: rows
        }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update user role
   * PATCH /api/admin/users/:id/role
   */
  static async updateUserRole(req, res, next) {
    try {
      const { id } = req.params;
      const { role } = req.body;

      const user = await User.findByPk(id);
      if (!user) {
        return res.status(404).json({
          success: false,
          error: { message: 'User not found', code: 'USER_NOT_FOUND' }
        });
      }

      user.role = role;
      await user.save();

      return res.status(200).json({
        success: true,
        message: `User role updated to '${role}'`,
        data: {
          user: {
            id: user.id,
            fullName: user.fullName,
            phoneNumber: user.phoneNumber,
            role: user.role
          }
        }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Delete a user account
   * DELETE /api/admin/users/:id
   */
  static async deleteUser(req, res, next) {
    try {
      const { id } = req.params;

      if (parseInt(id, 10) === req.user.id) {
        return res.status(400).json({
          success: false,
          error: { message: 'Cannot delete your own admin account', code: 'SELF_DELETE_FORBIDDEN' }
        });
      }

      const user = await User.findByPk(id);
      if (!user) {
        return res.status(404).json({
          success: false,
          error: { message: 'User not found', code: 'USER_NOT_FOUND' }
        });
      }

      await user.destroy();

      return res.status(200).json({
        success: true,
        message: 'User deleted successfully'
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Moderate agricultural products (flag/unflag or hide inappropriate listings)
   * PATCH /api/admin/products/:id/moderate
   */
  static async moderateProduct(req, res, next) {
    try {
      const { id } = req.params;
      const { isModerated } = req.body;

      const product = await Product.findByPk(id);
      if (!product) {
        return res.status(404).json({
          success: false,
          error: { message: 'Product not found', code: 'PRODUCT_NOT_FOUND' }
        });
      }

      product.isModerated = Boolean(isModerated);
      await product.save();

      return res.status(200).json({
        success: true,
        message: `Product ${product.isModerated ? 'moderated and hidden from public view' : 'approved and unhidden'}`,
        data: {
          product: {
            id: product.id,
            name: product.name,
            isModerated: product.isModerated
          }
        }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update platform settings
   * PATCH /api/admin/settings
   */
  static async updateSettings(req, res, next) {
    try {
      systemSettings = {
        ...systemSettings,
        ...req.body
      };

      return res.status(200).json({
        success: true,
        message: 'Platform settings updated successfully',
        data: { settings: systemSettings }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get platform settings
   * GET /api/admin/settings
   */
  static async getSettings(req, res, next) {
    try {
      return res.status(200).json({
        success: true,
        data: { settings: systemSettings }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Platform Analytics Dashboard (GMV, orders count, users count by role, active deliveries)
   * GET /api/admin/analytics
   */
  static async getAnalytics(req, res, next) {
    try {
      const [totalUsers, farmersCount, consumersCount, logisticiansCount] = await Promise.all([
        User.count(),
        User.count({ where: { role: 'farmer' } }),
        User.count({ where: { role: 'consumer' } }),
        User.count({ where: { role: 'logistician' } })
      ]);

      const totalProducts = await Product.count();
      const activeProducts = await Product.count({ where: { isModerated: false } });

      const totalOrders = await Order.count();
      const paidOrders = await Order.findAll({ where: { status: { [Op.in]: ['paid', 'in_transit', 'delivered'] } } });

      const gmv = paidOrders.reduce((sum, order) => sum + Number(order.totalAmount || 0), 0);

      const [pendingDeliveries, activeDeliveries, deliveredCount] = await Promise.all([
        Delivery.count({ where: { status: 'pending' } }),
        Delivery.count({ where: { status: { [Op.in]: ['assigned', 'picked_up', 'in_transit'] } } }),
        Delivery.count({ where: { status: 'delivered' } })
      ]);

      return res.status(200).json({
        success: true,
        data: {
          metrics: {
            users: {
              total: totalUsers,
              farmers: farmersCount,
              consumers: consumersCount,
              logisticians: logisticiansCount
            },
            inventory: {
              totalProducts,
              activeProducts
            },
            financials: {
              totalOrders,
              paidOrdersCount: paidOrders.length,
              grossMerchandiseValue: parseFloat(gmv.toFixed(2)),
              estimatedPlatformRevenue: parseFloat((gmv * (systemSettings.platformFeePercentage / 100)).toFixed(2))
            },
            fulfillment: {
              pendingDeliveries,
              activeDeliveries,
              deliveredCount
            }
          }
        }
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = AdminController;
