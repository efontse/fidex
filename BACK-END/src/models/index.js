const { sequelize, connectDatabase } = require('../config/database');

const UserModel = require('./User');
const SessionModel = require('./Session');
const ProductModel = require('./Product');
const ValueChainEventModel = require('./ValueChainEvent');
const BasketModel = require('./Basket');
const BasketItemModel = require('./BasketItem');
const OrderModel = require('./Order');
const OrderItemModel = require('./OrderItem');
const PaymentModel = require('./Payment');
const DeliveryModel = require('./Delivery');

// Initialize models with the current sequelize instance
const User = UserModel(sequelize);
const Session = SessionModel(sequelize);
const Product = ProductModel(sequelize);
const ValueChainEvent = ValueChainEventModel(sequelize);
const Basket = BasketModel(sequelize);
const BasketItem = BasketItemModel(sequelize);
const Order = OrderModel(sequelize);
const OrderItem = OrderItemModel(sequelize);
const Payment = PaymentModel(sequelize);
const Delivery = DeliveryModel(sequelize);

// User Associations
User.hasOne(Session, { foreignKey: 'userId', as: 'session', onDelete: 'CASCADE' });
Session.belongsTo(User, { foreignKey: 'userId', as: 'user' });

User.hasMany(Product, { foreignKey: 'farmerId', as: 'products' });
Product.belongsTo(User, { foreignKey: 'farmerId', as: 'farmer' });

User.hasMany(ValueChainEvent, { foreignKey: 'farmerId', as: 'valueChainEvents' });
ValueChainEvent.belongsTo(User, { foreignKey: 'farmerId', as: 'farmer' });

User.hasMany(Basket, { foreignKey: 'consumerId', as: 'baskets' });
Basket.belongsTo(User, { foreignKey: 'consumerId', as: 'consumer' });

User.hasMany(Delivery, { foreignKey: 'logisticianId', as: 'deliveries' });
Delivery.belongsTo(User, { foreignKey: 'logisticianId', as: 'logistician' });

// Product Associations
Product.hasMany(OrderItem, { foreignKey: 'productId', as: 'orderItems' });
OrderItem.belongsTo(Product, { foreignKey: 'productId', as: 'product' });

Product.hasMany(BasketItem, { foreignKey: 'productId', as: 'basketItems' });
BasketItem.belongsTo(Product, { foreignKey: 'productId', as: 'product' });

Product.hasMany(ValueChainEvent, { foreignKey: 'productId', as: 'valueChainEvents' });
ValueChainEvent.belongsTo(Product, { foreignKey: 'productId', as: 'product' });

// Basket Associations
Basket.hasMany(BasketItem, { foreignKey: 'basketId', as: 'items', onDelete: 'CASCADE' });
BasketItem.belongsTo(Basket, { foreignKey: 'basketId', as: 'basket' });

// Order Associations
User.hasMany(Order, { foreignKey: 'consumerId', as: 'orders' });
Order.belongsTo(User, { foreignKey: 'consumerId', as: 'consumer' });

Order.hasMany(OrderItem, { foreignKey: 'orderId', as: 'items', onDelete: 'CASCADE' });
OrderItem.belongsTo(Order, { foreignKey: 'orderId', as: 'order' });

Order.hasOne(Payment, { foreignKey: 'orderId', as: 'payment', onDelete: 'CASCADE' });
Payment.belongsTo(Order, { foreignKey: 'orderId', as: 'order' });

Order.hasOne(Delivery, { foreignKey: 'orderId', as: 'delivery', onDelete: 'CASCADE' });
Delivery.belongsTo(Order, { foreignKey: 'orderId', as: 'order' });

module.exports = {
  sequelize,
  connectDatabase,
  User,
  Session,
  Product,
  ValueChainEvent,
  Basket,
  BasketItem,
  Order,
  OrderItem,
  Payment,
  Delivery
};
