# Digital Agricultural Networking Platform — Development Specification

## 1. Project Scope & Context

**Theme:** Design and implementation of a digital agricultural networking platform for producer connectivity and agricultural value chain integration.

**What it is:** A marketplace connecting agricultural producers (farmers) directly with end consumers, supported by logistics coordination and platform administration — digitizing and integrating the agricultural value chain from farm to consumer.

**Tech stack:**
- **Backend:** Node.js + Express
- **ORM:** Sequelize
- **Database:** MySQL
- **Frontend:** Flutter (Cross-platform: Web, Mobile, Desktop)
- **External integrations:** Payment API (transactions), Geolocation API (delivery matching)

**Actors and their core behaviors:**

| Actor | Responsibilities |
|---|---|
| **Visitor** | Browses public landing page, registers an account |
| **Farmer (Producer)** | Manages profile, posts agricultural goods for sale, tracks value chain status |
| **Consumer** | Views landing page/catalog, adds products to basket, pays via Payment API |
| **Logistician** | Contacts producer for pickup, locates consumer via Geolocation API, delivers goods, updates delivery status |
| **Admin** | Manages system settings, accounts, users; moderates content |

**External systems:** Payment API (charge, status check), Geolocation API (locate, distance).

**Reference artifacts** (treat as source of truth for domain modeling): use case diagram (5 actors: Visitor, Farmer, Consumer, Logistician, Admin), class diagram (`User`, `Product`/`AgriculturalGood`, `Order`, `Payment`, `Basket`, `Delivery`), and sequence diagrams for auth (OTP), checkout, and delivery flows.

---

## 2. Sequelize Association Map

Use this as the exact reference when generating models and migrations — no ambiguity should remain.

```
User (id, fullName, phoneNumber, role, createdAt)
  hasOne     Session          (via userId)
  hasMany    Product          (via farmerId)      — only if role = farmer
  hasMany    Basket           (via consumerId)     — only if role = consumer
  hasMany    Delivery         (via logisticianId)  — only if role = logistician
  hasMany    ValueChainEvent  (via farmerId)       — only if role = farmer

Session (id, userId FK, otpCode, deviceId, createdAt, expiresAt, isActive)
  belongsTo  User             (via userId)

Product / AgriculturalGood (id, name, price, quantity, category, harvestDate, farmerId FK)
  belongsTo  User             (via farmerId, as 'farmer')
  hasMany    OrderItem        (via productId)

ValueChainEvent (id, farmerId FK, productId FK nullable, status, timestamp, notes)
  belongsTo  User             (via farmerId, as 'farmer')
  belongsTo  Product          (via productId, optional)

Basket (id, consumerId FK)
  belongsTo  User             (via consumerId, as 'consumer')
  hasMany    BasketItem       (via basketId)

BasketItem (id, basketId FK, productId FK, quantity)
  belongsTo  Basket           (via basketId)
  belongsTo  Product          (via productId)

Order (id, consumerId FK, orderDate, totalAmount, status)
  belongsTo  User             (via consumerId, as 'consumer')
  hasMany    OrderItem        (via orderId)
  hasOne     Payment          (via orderId)
  hasOne     Delivery         (via orderId)

OrderItem (id, orderId FK, productId FK, qty, subtotal)
  belongsTo  Order            (via orderId)
  belongsTo  Product          (via productId)

Payment (id, orderId FK, amount, status, method, providerReference)
  belongsTo  Order            (via orderId)

Delivery (id, orderId FK, logisticianId FK nullable, pickupPoint, dropoffPoint, status)
  belongsTo  Order            (via orderId)
  belongsTo  User             (via logisticianId, as 'logistician')
```

**Notes for the agent:**
- `role` on `User` is an ENUM: `visitor`, `farmer`, `consumer`, `logistician`, `admin`. `admin` has no dedicated FK relations — it operates via authorization checks on the same tables as everyone else.
- `Basket → Order` is a one-way transition (checkout converts basket contents into an Order + OrderItems); the Basket is cleared or marked consumed afterward, not deleted for audit purposes if you want that trail.
- `Order hasOne Payment` and `Order hasOne Delivery` are both 1:1 — enforce with a unique FK constraint on `orderId` in both tables.
- External API calls (Payment, Geolocation) are **not** Sequelize models — they are service classes (`PaymentService`, `GeolocationService`) called from controllers, wrapping HTTP calls to the external providers.

---

## 3. Development Phases & Tasks

### **Phase 0 — Project Setup & Foundations**
- [ ] Initialize Express app (`npm init`, `express`) with folder structure: `models/`, `routes/`, `controllers/`, `services/`, `middlewares/`
- [ ] Install and configure Sequelize with MySQL dialect (`sequelize`, `mysql2`)
- [ ] Set up Sequelize CLI config (`config/config.js`, `migrations/`, `seeders/`)
- [ ] Initialize React frontend (Vite) with routing (React Router), state management, and an Axios/Fetch API client wrapper
- [ ] Configure `.env` for DB credentials, JWT secret, Payment API key, Geolocation API key (mocked initially)
- [ ] Set up version control, `.env.example`, and basic CI (lint + test run on push)
- [ ] Define REST API conventions: route naming, response shape, error format

**End-of-phase deliverable:** Express server running, Sequelize connected to MySQL with a working migration, React app successfully calling a `/api/health` endpoint.

---

### **Phase 1 — Identity & Access (User, Session, Auth)**
- [ ] Sequelize model + migration: `User` (id, fullName, phoneNumber, role ENUM, createdAt)
- [ ] Sequelize model + migration: `Session` (id, userId FK, otpCode, deviceId, createdAt, expiresAt, isActive), `belongsTo User`
- [ ] `POST /api/register` — creates User via Sequelize
- [ ] `POST /api/auth/request-otp` — generates OTP, stores in Session, sends via SMS gateway stub
- [ ] `POST /api/auth/verify-otp` — validates OTP against Session, issues JWT, sets `isActive`
- [ ] Lockout logic after 3 failed OTP attempts
- [ ] Express middleware: `authenticate` (JWT verify) and `authorize(role)` (role guard)
- [ ] React: registration form, OTP entry screen, auth context (stores JWT), protected route wrapper per role

**End-of-phase deliverable:** Full register → OTP → JWT → role-based dashboard flow working against MySQL via Sequelize.

---

### **Phase 2 — Product Catalog (Farmer)**
- [ ] Sequelize model + migration: `Product`/`AgriculturalGood` (id, name, price, quantity, category, harvestDate, farmerId FK), `belongsTo User as farmer`
- [ ] `POST /api/farmer/products` — Farmer posts a product
- [ ] `GET /api/products` — public catalog listing (filter by category)
- [ ] `PATCH /api/products/:id/stock` — updateStock()
- [ ] React: Farmer "post good" form, public catalog browse page

**End-of-phase deliverable:** Farmers can list agricultural goods; catalog is publicly browsable.

---

### **Phase 3 — Value Chain Tracking**
- [ ] Sequelize model + migration: `ValueChainEvent` (id, farmerId FK, productId FK nullable, status, timestamp, notes)
- [ ] `GET /api/farmer/value-chain` — list events for the logged-in Farmer
- [ ] `POST /api/farmer/value-chain` — record a new status event
- [ ] React: Farmer-side value chain status view/timeline

**End-of-phase deliverable:** Farmer can see and update value chain progress for their goods.

---

### **Phase 4 — Consumer Commerce & Payment API**
- [ ] Sequelize model + migration: `Basket` (id, consumerId FK), `belongsTo User as consumer`
- [ ] Sequelize model + migration: `BasketItem` (id, basketId FK, productId FK, quantity)
- [ ] Sequelize model + migration: `Order` (id, consumerId FK, orderDate, totalAmount, status), `hasMany OrderItem`, `hasOne Payment`, `hasOne Delivery`
- [ ] Sequelize model + migration: `OrderItem` (id, orderId FK, productId FK, qty, subtotal)
- [ ] Sequelize model + migration: `Payment` (id, orderId FK unique, amount, status, method, providerReference)
- [ ] `PaymentService` — service class wrapping external Payment API: `charge(amount, method)`, `getStatus(reference)`
- [ ] `POST /api/basket/items` — addToBasket
- [ ] `POST /api/checkout` — creates Order + OrderItems from Basket, calls PaymentService, handles approved/declined branching
- [ ] Webhook or polling endpoint for async payment confirmation
- [ ] React: basket UI, checkout flow, payment status screen, order confirmation/receipt

**End-of-phase deliverable:** Consumer can browse → add to basket → checkout → pay → receive confirmation, with failure handling.

---

### **Phase 5 — Logistics & Delivery (Geolocation API)**
- [ ] Sequelize model + migration: `Delivery` (id, orderId FK unique, logisticianId FK nullable, pickupPoint, dropoffPoint, status), `belongsTo Order`, `belongsTo User as logistician`
- [ ] `GeolocationService` — service class wrapping external Geolocation API: `locate(address)`, `getDistance(a, b)`
- [ ] `GET /api/logistician/deliveries` — assigned/available deliveries
- [ ] `POST /api/logistician/deliveries/:id/contact-producer` — contactProducer()
- [ ] `POST /api/logistician/deliveries/:id/locate-consumer` — calls GeolocationService.locate()
- [ ] `PATCH /api/logistician/deliveries/:id/status` — updateShipmentStatus()
- [ ] Trigger: confirmed Order auto-creates a Delivery record
- [ ] React: Logistician dashboard, map view, status controls; Consumer-facing delivery tracking

**End-of-phase deliverable:** Confirmed orders generate deliveries; Logistician can locate the consumer and progress delivery status; Consumer can track it.

---

### **Phase 6 — Admin & Platform Governance**
- [ ] `GET/PATCH/DELETE /api/admin/users` — manageAccounts
- [ ] `PATCH /api/admin/settings` — manageSystemSettings
- [ ] `PATCH /api/admin/products/:id/moderate` — moderateContent
- [ ] `GET /api/admin/analytics` — viewAnalyticsDashboard (orders, users, GMV, active deliveries)
- [ ] React: Admin panel — user table with actions, settings form, moderation queue, analytics dashboard

**End-of-phase deliverable:** Admin can fully govern users, content, and settings, and view platform health metrics.

---

### **Phase 7 — Cross-Cutting Concerns & Hardening**
- [ ] Input validation on every endpoint (Joi or express-validator)
- [ ] Authorization checks per role on every route (no cross-role data leaks)
- [ ] Standardized error response shape across all endpoints
- [ ] Audit logging for sensitive actions (Admin actions, Payments)
- [ ] Rate limiting on auth endpoints (OTP abuse prevention)
- [ ] Automated tests: per-phase endpoint tests, plus one full-flow integration test per sequence diagram (auth, checkout, delivery)
- [ ] API documentation (OpenAPI/Swagger or Postman collection)
- [ ] Seed data/fixtures for demo (sample Farmers, products, orders)

**End-of-phase deliverable:** Tested, documented, secured backend and frontend.

---

### **Phase 8 — Deployment & Defense-Readiness**
- [ ] Dockerize backend + frontend (or deploy: Render/Railway + Vercel/Netlify)
- [ ] Environment separation (local/staging/prod configs)
- [ ] Final smoke test of core flows: registration/login, checkout, delivery
- [ ] Prepare demo script/dataset aligned with the use case and class diagrams for committee defense

**End-of-phase deliverable:** Deployed, demo-ready application matching the modeled design.

---

## 4. Design Artifacts to Reference During Implementation

- **Use case diagram** — 5 actors only (Visitor, Farmer, Consumer, Logistician, Admin); every endpoint should map to a use case.
- **Class diagram** — `User`, `Product`/`AgriculturalGood`, `Order`, `Payment`, `Basket`, `Delivery`; this is the schema blueprint — see the Sequelize Association Map in Section 2.
- **Sequence diagrams** — auth (OTP), checkout, delivery. Each should become an integration test in Phase 7.
