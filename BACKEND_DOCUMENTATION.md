# FIDEX — Digital Agricultural Networking Platform
## Complete Backend Architecture & Implemented Functionalities Documentation

---

### 1. Executive Overview

**FIDEX** is a digital agricultural networking platform designed to connect agricultural producers (farmers) directly with end consumers, supported by logisticians for order fulfillment and platform administrators for governance.

This platform digitizes and integrates the agricultural value chain ("farm-to-fork"), minimizing post-harvest loss, eliminating unnecessary intermediaries, and providing full traceability from harvest to doorstep.

#### Core Technology Stack
- **Runtime & Framework:** Node.js (v24.11+) + Express.js (v4.21+)
- **ORM:** Sequelize (v6.37+)
- **Database Engine:** MySQL (via `mysql2`)
- **Authentication:** Phone-number-based OTP (One-Time Password) with 3-attempt brute-force lockout + signed JWT bearer tokens
- **Security & Reliability:** Helmet, CORS, Joi schema validation, Express Rate Limiting, Centralized Error Handling, ACID database transactions

---

### 2. Domain Entities & Database Relational Map

The schema strictly implements the **Association Map** defined in the technical specification:

```
User (id, fullName, phoneNumber, role, createdAt)
 ├── 1:1 ── Session (userId, otpCode, deviceId, expiresAt, isActive)
 ├── 1:N ── Product (farmerId)              [Role: farmer]
 ├── 1:N ── ValueChainEvent (farmerId, productId) [Role: farmer]
 ├── 1:N ── Basket (consumerId)             [Role: consumer]
 └── 1:N ── Delivery (logisticianId)        [Role: logistician]

Basket (id, consumerId)
 └── 1:N ── BasketItem (basketId, productId, quantity)

Order (id, consumerId, orderDate, totalAmount, status)
 ├── 1:N ── OrderItem (orderId, productId, qty, subtotal)
 ├── 1:1 ── Payment (orderId [UNIQUE], amount, status, method, providerReference)
 └── 1:1 ── Delivery (orderId [UNIQUE], logisticianId, pickupPoint, dropoffPoint, status)
```

#### Relational Rules & Invariants:
1. **1:1 Enforced Constraints:** Both `Payment.orderId` and `Delivery.orderId` carry a unique foreign key index to guarantee that each order is strictly matched to one payment attempt and one shipment lifecycle.
2. **Actor Polymorphism via Roles:** All system actors share the unified `User` table governed by an ENUM (`visitor`, `farmer`, `consumer`, `logistician`, `admin`).
3. **Draft State vs. Immutable Contract:** `Basket` represents a mutable shopping session. Checking out permanently freezes items into immutable `Order` and `OrderItem` records with snapshot prices.

---

### 3. Actor Roles & Permissions Matrix

| Actor Role | Responsibilities & Capabilities | Accessible API Scope |
| :--- | :--- | :--- |
| **Visitor** | Browses public catalog, landing page, and registers an account | `/api/products`, `/api/value-chain/product/:id`, `/api/register`, `/api/auth/*` |
| **Farmer (Producer)** | Creates and updates agricultural goods, adjusts stock levels, and logs value chain milestones | `/api/farmer/products`, `/api/products/:id/stock`, `/api/farmer/value-chain` |
| **Consumer** | Browses goods, manages basket items, executes checkout, and tracks orders | `/api/basket/**`, `/api/checkout`, `/api/orders/**`, `/api/deliveries/order/:id` |
| **Logistician** | Claims available shipments, retrieves producer pickup contacts, geocodes consumer locations, and updates delivery status | `/api/logistician/deliveries/**` |
| **Admin** | Manages user accounts, moderates inappropriate content, configures platform fees, and views GMV/analytics | `/api/admin/**` |

---

### 4. Detailed Module Breakdown & Implemented Endpoints

#### Module 1: Identity, Access & OTP Authentication
- **Registration (`POST /api/register`):**
  - Accepts `fullName`, `phoneNumber`, and optional `role` (default: `consumer`).
  - Automatically initializes a linked `Session` record and dispatches an OTP.
- **Request OTP (`POST /api/auth/request-otp`):**
  - Generates a secure 6-digit numeric OTP valid for 5 minutes.
  - Protected by IP-based rate limiting (`express-rate-limit`) to prevent SMS flooding.
  - Logs dispatched code via SMS service stub (exposed in debug mode during development).
- **Verify OTP (`POST /api/auth/verify-otp`):**
  - Validates code against active session.
  - **3-Attempt Lockout Logic:** Tracks `failedAttempts`. On the 3rd consecutive failed attempt, the session is locked with HTTP `423 Locked` for a 15-minute cooldown period.
  - Upon successful verification, resets `failedAttempts`, sets `isActive: true`, and signs a JWT containing `{ id, role, phoneNumber }`.
- **Current User (`GET /api/auth/me`):**
  - Protected by `authenticate` middleware. Returns authenticated actor profile.

---

#### Module 2: Farmer Agricultural Catalog & Inventory
- **Post Agricultural Good (`POST /api/farmer/products`):**
  - Restricted to `farmer` and `admin`.
  - Captures `name`, `description`, `price`, `quantity`, `category`, `harvestDate`, `unit` (e.g. kg, ton, bag), and optional image.
  - Automatically appends a `"Catalog Listed"` milestone to the product's value chain.
- **Public Catalog (`GET /api/products`):**
  - Publicly accessible.
  - Filters by `category`, fuzzy `search` name matching, and `minPrice`/`maxPrice` ranges.
  - Supports server-side pagination (`page`, `limit`).
  - Automatically excludes moderated/flagged listings (`isModerated: false`).
- **Product Details (`GET /api/products/:id`):**
  - Returns product specifications, linked farmer profile, and historical value chain timeline.
- **Stock Management (`PATCH /api/products/:id/stock`):**
  - Allows farmers to adjust available inventory.
  - Verifies ownership (only the listing farmer or admin can edit).
  - Automatically logs a `"Stock Adjusted"` entry to the value chain audit trail.
- **Delete Product (`DELETE /api/farmer/products/:id`):**
  - Soft or hard removal by the owner or administrator.

---

#### Module 3: Value Chain & Farm-to-Fork Traceability
- **Log Milestone (`POST /api/farmer/value-chain`):**
  - Farmers log stage milestones such as:
    - `"Harvested"`
    - `"Washed & Graded"`
    - `"Quality Tested"`
    - `"Cold Storage"`
    - `"Ready for Pickup"`
  - Validates that the farmer owns the referenced product.
- **Farmer Timeline (`GET /api/farmer/value-chain`):**
  - Chronological history of all events logged by the authenticated farmer.
- **Consumer Traceability (`GET /api/value-chain/product/:productId`):**
  - Public endpoint allowing consumers to trace the complete chronological lifecycle of the food they buy.

---

#### Module 4: Consumer Commerce & ACID Checkout
- **Basket Operations:**
  - `GET /api/basket` — Retrieves cart items, product details, unit prices, line totals, and order subtotal.
  - `POST /api/basket/items` — Adds an agricultural item or increments quantity. **Validates live inventory before adding**.
  - `DELETE /api/basket/items/:id` — Removes an item from the basket.
  - `DELETE /api/basket` — Clears all items in the basket.
- **Checkout Process (`POST /api/checkout`):**
  - Wrapped entirely inside an **ACID database transaction** (`sequelize.transaction()`):
    1. Validates that the basket is not empty.
    2. Re-verifies live stock availability for every basket item.
    3. Calculates total amount.
    4. Creates `Order` with `status: 'pending_payment'`.
    5. Creates `OrderItem` snapshots preserving the purchase price.
    6. Decrements product inventory in the database.
    7. Clears consumer basket.
    8. Calls `PaymentService.charge()`.
    9. Creates 1:1 `Payment` record with unique constraint on `orderId`.
    10. If payment is approved: transitions `Order.status` to `'paid'` and **automatically creates the 1:1 `Delivery` record** with geocoded coordinates.
    11. Commits transaction. If payment or stock fails, rolls back all changes safely.
- **Order History:**
  - `GET /api/orders` — List of past orders with items, payments, and fulfillment status.
  - `GET /api/orders/:id` — Single order breakdown.

---

#### Module 5: Logistics & Geolocation Routing
- **List Deliveries (`GET /api/logistician/deliveries`):**
  - Filterable by `?filter=available` (unassigned shipments awaiting a driver) or `?filter=my` (assigned to caller).
- **Claim Delivery (`POST /api/logistician/deliveries/:id/claim`):**
  - Logistician assigns an unassigned delivery to themselves, moving status to `'assigned'`.
- **Contact Producer (`POST /api/logistician/deliveries/:id/contact-producer`):**
  - Returns producer names, phone numbers, and pickup location for pickup coordination.
- **Locate Consumer (`POST /api/logistician/deliveries/:id/locate-consumer`):**
  - Uses `GeolocationService` to resolve destination coordinates and calculate driving distance and estimated transit time.
- **Status Progression (`PATCH /api/logistician/deliveries/:id/status`):**
  - Transitions status through lifecycle:
    - `'pending'` → `'assigned'` → `'picked_up'` → `'in_transit'` → `'delivered'`.
  - Automatically synchronizes the corresponding `Order.status`.
- **Consumer Tracking (`GET /api/deliveries/order/:orderId`):**
  - Real-time fulfillment progress tracker for consumers.

---

#### Module 6: Admin Platform Governance & Analytics
- **User Account Management:**
  - `GET /api/admin/users` — Paginated list of users with role and name search.
  - `PATCH /api/admin/users/:id/role` — Promote or adjust user role.
  - `DELETE /api/admin/users/:id` — Remove user accounts (with self-deletion guard).
- **Content Moderation (`PATCH /api/admin/products/:id/moderate`):**
  - Moderates and hides reported or inappropriate agricultural goods from public view.
- **Platform Configuration (`GET/PATCH /api/admin/settings`):**
  - Manages platform fee percentages, payout intervals, and operational settings.
- **Executive Analytics Dashboard (`GET /api/admin/analytics`):**
  - Aggregates:
    - User distribution across all 5 roles.
    - Total and active catalog inventory.
    - Gross Merchandise Value (GMV), paid order counts, and platform revenue.
    - Active and completed delivery fulfillment metrics.

---

### 5. External Services Layer (Encapsulated Adapters)

1. **`OtpService` (`src/services/otpService.js`):**
   - Implements SMS provider abstraction.
   - Handles expiration timers and lockout counters.
2. **`PaymentService` (`src/services/paymentService.js`):**
   - Wraps external payment gateways (Stripe/Flutterwave/PayPal).
   - Generates unique transaction references (`fidex_txn_...`).
   - Supports negative test simulation ($999.99 triggers payment decline for test coverage).
3. **`GeolocationService` (`src/services/geolocationService.js`):**
   - Geocodes physical addresses into latitude/longitude coordinates.
   - Computes real-world distances using the **Haversine formula**:
     $$d = 2R \arcsin\left(\sqrt{\sin^2\left(\frac{\Delta\varphi}{2}\right) + \cos(\varphi_1)\cos(\varphi_2)\sin^2\left(\frac{\Delta\lambda}{2}\right)}\right)$$
   - Calculates estimated transit durations.

---

### 6. Pre-Configured Demo Accounts (Seeder)

Run `npm run seed` inside `BACK-END/` to populate the database with complete fixtures:

| Role | Name | Phone Number | Default OTP |
| :--- | :--- | :--- | :--- |
| **Farmer** | Amadou Diallo | `+2348011111111` | `123456` |
| **Farmer** | Grace Adewale | `+2348022222222` | `123456` |
| **Consumer** | Sarah Johnson | `+2348033333333` | `123456` |
| **Consumer** | Michael Chen | `+2348044444444` | `123456` |
| **Logistician**| David Okonkwo | `+2348055555555` | `123456` |
| **Admin** | Amina Bello (Admin) | `+2348099999999` | `123456` |
| **Visitor** | John Visitor | `+2348077777777` | `123456` |

*Pre-seeded catalog includes Organic Cassava Roots, Yellow Maize Grain, Roma Tomatoes, Premium Cocoa Beans, and White Yams with associated value chain tracking events and historical orders.*

---

### 7. Verification & Automated Test Suites

The backend includes a comprehensive Jest and Supertest suite:
- **`tests/auth.test.js`:** Tests registration, OTP delivery, 3-attempt brute force lockout protection, and JWT token issuance.
- **`tests/checkout.test.js`:** Tests basket management, stock verification, ACID transaction checkout, Payment creation, and inventory deduction.
- **`tests/delivery.test.js`:** Tests delivery dispatch, logistician claiming, geolocation calculation, and status progression to `'delivered'`.

#### Test Execution Result:
```
PASS tests/delivery.test.js
PASS tests/auth.test.js
PASS tests/checkout.test.js

Test Suites: 3 passed, 3 total
Tests:       14 passed, 14 total
Snapshots:   0 total
Time:        2.857 s
```

---

### 8. Quick Start Guide

```bash
# 1. Navigate to backend directory
cd BACK-END

# 2. Install dependencies (if not already installed)
npm install

# 3. Seed demo accounts, products, and value chain data
npm run seed

# 4. Run automated test suite
npm test

# 5. Start live server
npm run dev
# Server listening on http://localhost:5000
# Health check: http://localhost:5000/api/health
```
