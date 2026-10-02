# FIDEX — Digital Agricultural Networking Platform (Flutter Frontend)

This is the official cross-platform Flutter frontend for the **FIDEX Digital Agricultural Networking Platform**, connecting agricultural producers (farmers), consumers (buyers), logistics coordinators, and administrators.

---

## 🎨 Design System & Aesthetics
- **Theme**: Professional Clean White with Balanced Lime Green (`#7CB342` / `#558B2F`)
- **Typography**: Clean, high-legibility sans-serif with distinct weight hierarchy
- **Components**: Card tiles with subtle green-tinted borders, status badges, interactive step indicators, responsive multi-column layouts

---

## 📱 User Roles & Features Supported
1. **Visitor / Guest**:
   - Explore agricultural produce catalog (Tubers, Grains, Vegetables, Fruits, Cash Crops).
   - Filter and search live harvest.
   - Quick sign-up & OTP verification.
2. **Producer (Farmer)**:
   - Dashboard with listed goods & inventory stock volume.
   - Post new agricultural goods with pricing, units, and harvest date.
   - Farm-to-fork value chain milestone tracker (Harvested, Washed, Inspected, Cold Stored, Dispatched).
3. **Consumer (Buyer)**:
   - Product catalog with real-time stock indicators.
   - Detailed product view with farmer profile and full value chain history.
   - Real-time shopping basket with quantity controls.
   - Multi-method checkout (Card, Mobile Money, Cash on Delivery).
   - Live order delivery tracking with geolocation & stage milestones.
4. **Logistician Fleet**:
   - Deliveries dispatch board (Assigned, In Transit, Delivered).
   - "Contact Producer" automated SMS trigger.
   - "Locate Consumer" automated Geolocation distance calculator.
   - Live delivery status progression.
5. **Platform Admin**:
   - System KPIs (Users, Listed Lots, Orders GMV, Active Shipments).
   - User account management (Role assignment, deactivate / activate).
   - System infrastructure & health diagnostics.

---

## 🚀 Running the Flutter App

### 1. Prerequisites
- Flutter SDK (version `>= 3.0.0`)
- Backend running on `http://localhost:5000` (Node.js + XAMPP MySQL)

### 2. Launching

```bash
# Get dependencies
flutter pub get

# Run on Web (Chrome)
flutter run -d chrome

# Run on Android Emulator
flutter run -d android

# Run on Windows Desktop
flutter run -d windows
```

### 3. Demo Quick Logins (OTP: `123456`)
- **Farmer**: `+2348011111111`
- **Consumer**: `+2348033333333`
- **Logistician**: `+2348055555555`
- **Admin**: `+2348099999999`
