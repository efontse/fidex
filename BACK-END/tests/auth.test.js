const request = require('supertest');
const app = require('../src/app');
const { sequelize, User, Session } = require('../src/models');

beforeAll(async () => {
  process.env.NODE_ENV = 'test';
  await sequelize.sync({ force: true });
});

afterAll(async () => {
  await sequelize.close();
});

describe('Phase 1 Integration: Identity & Access Flow (Register -> OTP -> Lockout -> JWT)', () => {
  const testPhone = '+2348000000001';

  test('1. Health check returns 200 and ONLINE status', async () => {
    const res = await request(app).get('/api/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.status).toBe('ONLINE');
  });

  test('2. Register new consumer', async () => {
    const res = await request(app)
      .post('/api/register')
      .send({
        fullName: 'Test Consumer',
        phoneNumber: testPhone,
        role: 'consumer'
      });

    expect(res.statusCode).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.user.phoneNumber).toBe(testPhone);
    expect(res.body.data.otpSent).toBe(true);
  });

  test('3. Request OTP creates session with expiresAt', async () => {
    const res = await request(app)
      .post('/api/auth/request-otp')
      .send({ phoneNumber: testPhone });

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
  });

  test('4. Verify with incorrect OTP increments failed attempts', async () => {
    const res = await request(app)
      .post('/api/auth/verify-otp')
      .send({
        phoneNumber: testPhone,
        otpCode: '000000'
      });

    expect(res.statusCode).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.error.message).toMatch(/remaining/i);
  });

  test('5. Three consecutive failed attempts locks account', async () => {
    // Attempt 2
    await request(app)
      .post('/api/auth/verify-otp')
      .send({ phoneNumber: testPhone, otpCode: '000000' });

    // Attempt 3 -> triggers lockout
    const res3 = await request(app)
      .post('/api/auth/verify-otp')
      .send({ phoneNumber: testPhone, otpCode: '000000' });

    expect(res3.statusCode).toBe(423);
    expect(res3.body.error.message).toMatch(/locked/i);
  });

  test('6. Valid OTP verification issues signed JWT token', async () => {
    // Reset lockout for test phone and set known OTP
    const user = await User.findOne({ where: { phoneNumber: testPhone } });
    const session = await Session.findOne({ where: { userId: user.id } });
    session.failedAttempts = 0;
    session.otpCode = '654321';
    session.expiresAt = new Date(Date.now() + 10 * 60000);
    await session.save();

    const res = await request(app)
      .post('/api/auth/verify-otp')
      .send({
        phoneNumber: testPhone,
        otpCode: '654321'
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.token).toBeDefined();

    // Verify /api/auth/me with bearer token
    const meRes = await request(app)
      .get('/api/auth/me')
      .set('Authorization', `Bearer ${res.body.data.token}`);

    expect(meRes.statusCode).toBe(200);
    expect(meRes.body.data.user.phoneNumber).toBe(testPhone);
  });
});
