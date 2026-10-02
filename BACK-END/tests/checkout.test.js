const request = require('supertest');
const jwt = require('jsonwebtoken');
const app = require('../src/app');
const config = require('../src/config/config');
const { sequelize, User, Product, Order, Payment, Delivery } = require('../src/models');

let farmerToken;
let consumerToken;
let farmerId;
let consumerId;
let productId;

beforeAll(async () => {
  process.env.NODE_ENV = 'test';
  await sequelize.sync({ force: true });

  // Create Farmer
  const farmer = await User.create({
    fullName: 'Farmer Joe',
    phoneNumber: '+2348000000010',
    role: 'farmer'
  });
  farmerId = farmer.id;
  farmerToken = jwt.sign({ id: farmer.id, role: 'farmer', phoneNumber: farmer.phoneNumber }, config.jwtSecret);

  // Create Consumer
  const consumer = await User.create({
    fullName: 'Buyer Alice',
    phoneNumber: '+2348000000020',
    role: 'consumer'
  });
  consumerId = consumer.id;
  consumerToken = jwt.sign({ id: consumer.id, role: 'consumer', phoneNumber: consumer.phoneNumber }, config.jwtSecret);

  // Farmer creates a product
  const productRes = await request(app)
    .post('/api/farmer/products')
    .set('Authorization', `Bearer ${farmerToken}`)
    .send({
      name: 'Organic Sweet Potatoes',
      description: 'Rich orange fleshed sweet potatoes',
      price: 50.00,
      quantity: 100,
      category: 'Tubers',
      unit: 'kg'
    });

  productId = productRes.body.data.product.id;
});

afterAll(async () => {
  await sequelize.close();
});

describe('Phase 4 Integration: Consumer Commerce & Checkout Flow', () => {
  test('1. Consumer adds agricultural product to basket', async () => {
    const res = await request(app)
      .post('/api/basket/items')
      .set('Authorization', `Bearer ${consumerToken}`)
      .send({
        productId,
        quantity: 5
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
  });

  test('2. Consumer views basket with calculated totals', async () => {
    const res = await request(app)
      .get('/api/basket')
      .set('Authorization', `Bearer ${consumerToken}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.data.subtotal).toBe(250.00); // 5 * 50.00
    expect(res.body.data.items.length).toBe(1);
  });

  test('3. Checkout executes ACID transaction: creates Order, Payment, auto-creates Delivery and decrements stock', async () => {
    const res = await request(app)
      .post('/api/checkout')
      .set('Authorization', `Bearer ${consumerToken}`)
      .send({
        deliveryAddress: '15 Admiralty Way, Lekki Phase 1, Lagos',
        paymentMethod: 'card'
      });

    expect(res.statusCode).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.order.status).toBe('paid');
    expect(res.body.data.payment.status).toBe('completed');
    expect(res.body.data.delivery.status).toBe('pending');
    expect(res.body.data.delivery.dropoffPoint).toBe('15 Admiralty Way, Lekki Phase 1, Lagos');

    // Verify stock deduction in DB (100 - 5 = 95)
    const product = await Product.findByPk(productId);
    expect(product.quantity).toBe(95);

    // Verify basket is cleared
    const basketRes = await request(app)
      .get('/api/basket')
      .set('Authorization', `Bearer ${consumerToken}`);
    expect(basketRes.body.data.items.length).toBe(0);
  });
});
