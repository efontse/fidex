const Joi = require('joi');

const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(4).max(128).required(),
  farmingField: Joi.string().max(64).allow('', null).optional(),
  companyName: Joi.string().max(128).allow('', null).optional()
});

const registerSchema = Joi.object({
  fullName: Joi.string().min(2).max(128).required(),
  email: Joi.string().email().required(),
  password: Joi.string().min(4).max(128).required(),
  phoneNumber: Joi.string().pattern(/^\+?[0-9]{7,15}$/).allow('', null).optional(),
  role: Joi.string().valid('visitor', 'farmer', 'consumer', 'logistician', 'admin').default('consumer'),
  farmingField: Joi.string().max(64).allow('', null).optional(),
  companyName: Joi.string().max(128).allow('', null).optional(),
  address: Joi.string().max(255).allow('', null).optional()
});

const requestOtpSchema = Joi.object({
  phoneNumber: Joi.string().pattern(/^\+?[0-9]{7,15}$/).required(),
  deviceId: Joi.string().max(128).optional().default('web-client')
});

const verifyOtpSchema = Joi.object({
  phoneNumber: Joi.string().pattern(/^\+?[0-9]{7,15}$/).required(),
  otpCode: Joi.string().length(6).required()
});

const createProductSchema = Joi.object({
  name: Joi.string().min(2).max(128).required(),
  description: Joi.string().max(1000).allow('', null).optional(),
  price: Joi.number().positive().precision(2).required(),
  quantity: Joi.number().integer().min(0).required(),
  category: Joi.string().min(2).max(64).required(),
  harvestDate: Joi.date().iso().optional().allow(null),
  unit: Joi.string().max(32).default('kg'),
  imageUrl: Joi.string().allow('', null).optional()
});

const updateStockSchema = Joi.object({
  quantity: Joi.number().integer().min(0).required()
});

const updateProductSchema = Joi.object({
  name: Joi.string().min(2).max(128).optional(),
  description: Joi.string().max(1000).allow('', null).optional(),
  price: Joi.number().positive().precision(2).optional(),
  quantity: Joi.number().integer().min(0).optional(),
  category: Joi.string().min(2).max(64).optional(),
  harvestDate: Joi.date().iso().optional().allow(null),
  unit: Joi.string().max(32).optional(),
  imageUrl: Joi.string().allow('', null).optional()
}).min(1);

const createValueChainEventSchema = Joi.object({
  productId: Joi.number().integer().optional().allow(null),
  status: Joi.string().min(2).max(64).required(),
  notes: Joi.string().max(1000).optional().allow('', null),
  timestamp: Joi.date().iso().optional()
});

const addToBasketSchema = Joi.object({
  productId: Joi.number().integer().required(),
  quantity: Joi.number().integer().min(1).default(1)
});

const checkoutSchema = Joi.object({
  deliveryAddress: Joi.string().min(5).max(255).required(),
  paymentMethod: Joi.string().valid('card', 'mobile_money', 'bank_transfer').default('card'),
  notes: Joi.string().max(500).optional().allow('', null)
});

const updateDeliveryStatusSchema = Joi.object({
  status: Joi.string().valid('pending', 'assigned', 'picked_up', 'in_transit', 'delivered', 'cancelled').required()
});

const updateUserRoleSchema = Joi.object({
  role: Joi.string().valid('visitor', 'farmer', 'consumer', 'logistician', 'admin').required()
});

const moderateProductSchema = Joi.object({
  isModerated: Joi.boolean().required()
});

module.exports = {
  loginSchema,
  registerSchema,
  requestOtpSchema,
  verifyOtpSchema,
  createProductSchema,
  updateStockSchema,
  updateProductSchema,
  createValueChainEventSchema,
  addToBasketSchema,
  checkoutSchema,
  updateDeliveryStatusSchema,
  updateUserRoleSchema,
  moderateProductSchema
};
