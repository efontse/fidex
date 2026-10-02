const request = require('supertest');
const jwt = require('jsonwebtoken');
const app = require('../src/app');
const config = require('../src/config/config');
const { sequelize, User, Product, Order, Delivery } = require('../src/models');

let logisticianToken;
let logisticianId;
let orderId;
let deliveryId;

beforeAll(async () => {
  process.env.NODE_ENV = 'test';
  await sequelize.sync({ force: true });

  // Create Farmer
  const farmer = await User.create({
    fullName: 'Farmer Ben',
    phoneNumber: '+2348000000031',
    role: 'farmer'
  });

  // Create Consumer
  const consumer = await User.create({
    fullName: 'Consumer Clara',
    phoneNumber: '+2348000000032',
    role: 'consumer'
  });

  // Create Logistician
  const logistician = await User.create({
    fullName: 'Driver Dan',
    phoneNumber: '+2348000000033',
    role: 'logistician'
  });
  logisticianId = logistician.id;
  logisticianToken = jwt.sign({ id: logistician.id, role: 'logistician', phoneNumber: logistician.phoneNumber }, config.jwtSecret);

  // Create Product
  const product = await Product.create({
    name: 'Fresh Carrots',
    price: 15.00,
    quantity: 50,
    category: 'Vegetables',
    farmerId: farmer.id
  });

  // Create Paid Order
  const order = await Order.create({
    consumerId: consumer.id,
    orderDate: new Date(),
    totalAmount: 150.00,
    status: 'paid',
    deliveryAddress: '20 Broad Street, Lagos Island'
  });
  orderId = order.id;

  // Create Delivery
  const delivery = await Delivery.create({
    orderId: order.id,
    logisticianId: null,
    pickupPoint: 'Farm Zone A, Oyo State',
    dropoffPoint: '20 Broad Street, Lagos Island',
    status: 'pending'
  });
  deliveryId = delivery.id;
});

afterAll(async () => {
  await sequelize.close();
});

describe('Phase 5 Integration: Logistics & Delivery Flow (Claim -> Geolocation -> Status Transition)', () => {
  test('1. Logistician views available unassigned deliveries', async () => {
    const res = await request(app)
      .get('/api/logistician/deliveries?filter=available')
      .set('Authorization', `Bearer ${logisticianToken}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.deliveries.length).toBeGreaterThanOrEqual(1);
  });

  test('2. Logistician claims delivery', async () => {
    const res = await request(app)
      .post(`/api/logistician/deliveries/${deliveryId}/claim`)
      .set('Authorization', `Bearer ${logisticianToken}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.delivery.logisticianId).toBe(logisticianId);
    expect(res.body.data.delivery.status).toBe('assigned');
  });

  test('3. Logistician contacts producer for pickup', async () => {
    const res = await request(app)
      .post(`/api/logistician/deliveries/${deliveryId}/contact-producer`)
      .set('Authorization', `Bearer ${logisticianToken}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.pickupPoint).toBeDefined();
  });

  test('4. Logistician locates consumer using Geolocation API', async () => {
    const res = await request(app)
      .post(`/api/logistician/deliveries/${deliveryId}/locate-consumer`)
      .set('Authorization', `Bearer ${logisticianToken}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.coordinates.lat).toBeDefined();
    expect(res.body.data.coordinates.lng).toBeDefined();
    expect(res.body.data.distanceFromPickupKm).toBeGreaterThan(0);
  });

  test('5. Logistician progresses delivery status to delivered', async () => {
    // Picked up
    await request(app)
      .patch(`/api/logistician/deliveries/${deliveryId}/status`)
      .set('Authorization', `Bearer ${logisticianToken}`)
      .send({ status: 'picked_up' });

    // Delivered
    const res = await request(app)
      .patch(`/api/logistician/deliveries/${deliveryId}/status`)
      .set('Authorization', `Bearer ${logisticianToken}`)
      .send({ status: 'delivered' });

    expect(res.statusCode).toBe(200);
    expect(res.body.data.delivery.status).toBe('delivered');
    expect(res.body.data.delivery.deliveredAt).toBeDefined();

    // Verify Order status synchronized to delivered
    const updatedOrder = await Order.findByPk(orderId);
    expect(updatedOrder.status).toBe('delivered');
  });
});
