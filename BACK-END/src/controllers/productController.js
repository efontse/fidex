const { Op } = require('sequelize');
const { Product, User, ValueChainEvent } = require('../models');

class ProductController {
  /**
   * Farmer posts a new product
   * POST /api/farmer/products
   */
  static async createProduct(req, res, next) {
    try {
      const { name, description, price, quantity, category, harvestDate, unit, imageUrl } = req.body;

      const product = await Product.create({
        name,
        description,
        price,
        quantity,
        category,
        harvestDate: harvestDate || null,
        unit: unit || 'kg',
        imageUrl: imageUrl || null,
        farmerId: req.user.id
      });

      // Auto-log initial value chain event for the newly created product
      await ValueChainEvent.create({
        farmerId: req.user.id,
        productId: product.id,
        status: 'Catalog Listed',
        notes: `Initial stock of ${quantity} ${unit || 'kg'} listed by producer ${req.user.fullName}.`
      });

      return res.status(201).json({
        success: true,
        message: 'Product listed successfully',
        data: { product }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Public catalog listing with filtering, searching, and pagination
   * GET /api/products
   */
  static async getProducts(req, res, next) {
    try {
      const { category, search, minPrice, maxPrice, farmerId, page = 1, limit = 50 } = req.query;

      const where = {
        isModerated: false // Exclude flagged/moderated products
      };

      if (category && category !== 'All') {
        where.category = category;
      }

      if (farmerId) {
        where.farmerId = farmerId;
      }

      if (search) {
        where.name = { [Op.like]: `%${search}%` };
      }

      if (minPrice || maxPrice) {
        where.price = {};
        if (minPrice) where.price[Op.gte] = Number(minPrice);
        if (maxPrice) where.price[Op.lte] = Number(maxPrice);
      }

      const offset = (parseInt(page, 10) - 1) * parseInt(limit, 10);

      const { count, rows } = await Product.findAndCountAll({
        where,
        limit: parseInt(limit, 10),
        offset,
        order: [
          ['updatedAt', 'DESC'],
          ['createdAt', 'DESC']
        ],
        include: [
          {
            model: User,
            as: 'farmer',
            attributes: ['id', 'fullName', 'phoneNumber', 'farmingField']
          }
        ]
      });

      return res.status(200).json({
        success: true,
        data: {
          total: count,
          page: parseInt(page, 10),
          totalPages: Math.ceil(count / parseInt(limit, 10)),
          products: rows
        }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get single product details by ID
   * GET /api/products/:id
   */
  static async getProductById(req, res, next) {
    try {
      const { id } = req.params;

      const product = await Product.findByPk(id, {
        include: [
          {
            model: User,
            as: 'farmer',
            attributes: ['id', 'fullName', 'phoneNumber']
          },
          {
            model: ValueChainEvent,
            as: 'valueChainEvents',
            order: [['timestamp', 'ASC']]
          }
        ]
      });

      if (!product) {
        return res.status(404).json({
          success: false,
          error: {
            message: 'Product not found',
            code: 'PRODUCT_NOT_FOUND'
          }
        });
      }

      return res.status(200).json({
        success: true,
        data: { product }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Farmer retrieves their listed products
   * GET /api/farmer/products
   */
  static async getFarmerProducts(req, res, next) {
    try {
      const where = req.user.role === 'admin' ? {} : { farmerId: req.user.id };

      const products = await Product.findAll({
        where,
        order: [
          ['updatedAt', 'DESC'],
          ['createdAt', 'DESC']
        ],
        include: [
          {
            model: User,
            as: 'farmer',
            attributes: ['id', 'fullName', 'phoneNumber', 'email', 'farmingField']
          },
          {
            model: ValueChainEvent,
            as: 'valueChainEvents',
            order: [['timestamp', 'ASC']]
          }
        ]
      });

      return res.status(200).json({
        success: true,
        data: {
          total: products.length,
          products
        }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Farmer updates an existing agricultural good
   * PUT /api/farmer/products/:id or PATCH /api/farmer/products/:id
   */
  static async updateProduct(req, res, next) {
    try {
      const { id } = req.params;
      const { name, description, price, quantity, category, harvestDate, unit, imageUrl } = req.body;

      const product = await Product.findByPk(id);
      if (!product) {
        return res.status(404).json({
          success: false,
          error: { message: 'Product not found', code: 'PRODUCT_NOT_FOUND' }
        });
      }

      // Check ownership (only the farmer who created it or admin can edit)
      if (req.user.role !== 'admin' && product.farmerId !== req.user.id) {
        return res.status(403).json({
          success: false,
          error: { message: 'You are not authorized to update this product', code: 'UNAUTHORIZED_PRODUCT_ACCESS' }
        });
      }

      const previousPrice = Number(product.price);
      const previousQty = Number(product.quantity);

      if (name !== undefined) product.name = name;
      if (description !== undefined) product.description = description;
      if (price !== undefined) product.price = price;
      if (quantity !== undefined) product.quantity = quantity;
      if (category !== undefined) product.category = category;
      if (harvestDate !== undefined) product.harvestDate = harvestDate || null;
      if (unit !== undefined) product.unit = unit;
      if (imageUrl !== undefined) product.imageUrl = imageUrl || null;

      await product.save();

      // Log milestone to value chain traceability
      const changeNotes = [];
      if (price !== undefined && Number(price) !== previousPrice) {
        changeNotes.push(`Price: ${previousPrice} -> ${price} FCFA`);
      }
      if (quantity !== undefined && Number(quantity) !== previousQty) {
        changeNotes.push(`Stock: ${previousQty} -> ${quantity} ${product.unit}`);
      }
      if (name !== undefined) changeNotes.push(`Title: "${name}"`);

      await ValueChainEvent.create({
        farmerId: product.farmerId,
        productId: product.id,
        status: 'Listing Updated',
        notes: `Product updated by producer ${req.user.fullName}.${changeNotes.length ? ' Changes: ' + changeNotes.join(', ') : ''}`
      });

      // Reload product with farmer and events
      const updatedProduct = await Product.findByPk(product.id, {
        include: [
          {
            model: User,
            as: 'farmer',
            attributes: ['id', 'fullName', 'phoneNumber', 'farmingField']
          },
          {
            model: ValueChainEvent,
            as: 'valueChainEvents'
          }
        ]
      });

      return res.status(200).json({
        success: true,
        message: 'Product updated successfully',
        data: { product: updatedProduct }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Farmer updates product stock
   * PATCH /api/products/:id/stock
   */
  static async updateStock(req, res, next) {
    try {
      const { id } = req.params;
      const { quantity } = req.body;

      const product = await Product.findByPk(id);
      if (!product) {
        return res.status(404).json({
          success: false,
          error: { message: 'Product not found', code: 'PRODUCT_NOT_FOUND' }
        });
      }

      // Check ownership (only the farmer who created it or admin can edit)
      if (req.user.role !== 'admin' && product.farmerId !== req.user.id) {
        return res.status(403).json({
          success: false,
          error: { message: 'You are not authorized to modify this product', code: 'UNAUTHORIZED_PRODUCT_ACCESS' }
        });
      }

      const previousQty = product.quantity;
      product.quantity = quantity;
      await product.save();

      // Log stock update to value chain
      await ValueChainEvent.create({
        farmerId: product.farmerId,
        productId: product.id,
        status: 'Stock Adjusted',
        notes: `Inventory updated from ${previousQty} to ${quantity} ${product.unit}.`
      });

      return res.status(200).json({
        success: true,
        message: 'Stock updated successfully',
        data: {
          product: {
            id: product.id,
            name: product.name,
            quantity: product.quantity,
            unit: product.unit
          }
        }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Farmer deletes their product
   * DELETE /api/farmer/products/:id
   */
  static async deleteProduct(req, res, next) {
    try {
      const { id } = req.params;

      const product = await Product.findByPk(id);
      if (!product) {
        return res.status(404).json({
          success: false,
          error: { message: 'Product not found', code: 'PRODUCT_NOT_FOUND' }
        });
      }

      if (req.user.role !== 'admin' && product.farmerId !== req.user.id) {
        return res.status(403).json({
          success: false,
          error: { message: 'You are not authorized to delete this product', code: 'UNAUTHORIZED' }
        });
      }

      await product.destroy();

      return res.status(200).json({
        success: true,
        message: 'Product deleted successfully'
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = ProductController;
