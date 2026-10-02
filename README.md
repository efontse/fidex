# Farmora — Digital Agricultural Networking Platform

An end-to-end digital agricultural marketplace connecting producers directly with consumers, supported by integrated logistics coordination, value chain traceability, and platform administration.

---

## 🌾 Core Agricultural Sectors

Farmora is purpose-built to support five specialized agricultural sectors with authentic local photography:

1. **🐟 Pisciculture** — Catfish aquaculture, whole freshwater tilapia, aeration tanks, and fingerlings.
2. **🥬 Horticulture** — Vine-ripened Roma greenhouse tomatoes, crisp sweet bell peppers, leafy vegetables, and carrots.
3. **🍯 Apiculture** — Wild forest unpasteurized blossom honey, natural honeycomb cuts, and organic beeswax.
4. **🥛 Dairy Farming** — Grade A pasteurized whole cow milk, artisanal farmhouse white cheese (Wara), and yogurt.
5. **🐔 Poultry Farm** — Clean jumbo brown farm eggs, dressed free-range broiler chickens, and poultry feed.

---

## 🏗️ Architecture

- **Backend**: Node.js, Express, Sequelize ORM (MySQL)
- **Frontend**: Flutter (Cross-platform: Web, Mobile, Desktop) with Lime Green & Modern White Theme
- **Authentication**: Email & Password with bcrypt hashing and JWT tokens
- **Role Precision**:
  - **Farmers**: Can specify/update their primary farming field (Pisciculture, Horticulture, Apiculture, Dairy Farming, Poultry Farm).
  - **Logisticians**: Can specify/update their employer fleet company name.
- **Product Media**: Upload produce pictures via live **Camera** snapshot or **Registered Sector Pictures** gallery.

---

## 🔑 Demo Accounts (Email & Password Authentication)

All accounts log in using **Email and Password**:

| Role | Name | Email | Password | Details |
|---|---|---|---|---|
| **Platform Admin** | Amina Bello | `admin@farmora.com` | `Admin123!` | System Settings, User & Role Management, Product Moderation |
| **Farmer (Horticulture)** | Amadou Diallo | `farmer.amadou@farmora.com` | `Farmer123!` | Greenhouse Tomatoes & Crisp Peppers |
| **Farmer (Poultry Farm)** | Grace Adewale | `farmer.grace@farmora.com` | `Farmer123!` | Farm-Fresh Eggs & Dressed Broiler Chicken |
| **Farmer (Pisciculture)** | Kofi Mensah | `farmer.kofi@farmora.com` | `Farmer123!` | African Catfish & Tilapia Aquaculture |
| **Farmer (Apiculture)** | Zainab Al-Mansoor | `farmer.zainab@farmora.com` | `Farmer123!` | Raw Wild Honey & Honeycomb Cuts |
| **Farmer (Dairy Farming)** | Bello Danladi | `farmer.bello@farmora.com` | `Farmer123!` | Fresh Whole Milk & Artisanal Farmhouse Cheese |
| **Logistician (Fleet)** | David Okonkwo | `logistics.david@farmora.com` | `Logistics123!` | Company: **AgroFleet Express Logistics** |
| **Consumer (Buyer)** | Sarah Johnson | `consumer.sarah@farmora.com` | `Consumer123!` | Catalog Browsing, Basket, Checkout & Order Tracking |
| **Consumer (Buyer)** | Michael Chen | `consumer.michael@farmora.com` | `Consumer123!` | Alternate Consumer Account |

---

## 🚀 Getting Started

### 1. Backend Server Setup
```bash
cd BACK-END
npm install
npm run seed     # Seeds Admin, the 5 sector farmers, logistician, and authentic products
npm run dev      # Starts server on http://localhost:5000
```

### 2. Frontend Flutter Setup
```bash
cd FRONT-END
flutter pub get
flutter run -d chrome   # Or edge / windows / mobile device
```
