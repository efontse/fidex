const bcrypt = require('bcryptjs');
const {
  connectDatabase,
  sequelize,
  User,
  Session,
  Product,
  ValueChainEvent,
  Order,
  OrderItem,
  Payment,
  Delivery
} = require('../models');

const seedDatabase = async () => {
  try {
    console.log('[Seed] Connecting to database...');
    await connectDatabase();

    console.log('[Seed] Synchronizing schema (force reset)...');
    await sequelize.sync({ force: true });

    console.log('[Seed] Hashing demo passwords...');
    const defaultPasswordHash = await bcrypt.hash('Farmora123!', 10);
    const adminPasswordHash = await bcrypt.hash('Admin123!', 10);
    const farmerPasswordHash = await bcrypt.hash('Farmer123!', 10);
    const logisticsPasswordHash = await bcrypt.hash('Logistics123!', 10);
    const consumerPasswordHash = await bcrypt.hash('Consumer123!', 10);

    console.log('[Seed] Creating demo actors (Users)...');
    
    // 1. Admin
    const admin = await User.create({
      fullName: 'Amina Bello (Platform Admin)',
      email: 'admin@farmora.com',
      password: adminPasswordHash,
      phoneNumber: '+2348000000001',
      role: 'admin',
      address: 'Farmora Headquarters, Victoria Island, Lagos',
      isActive: true
    });

    // 2. Farmers across the 5 core agricultural sectors
    const farmerHorticulture = await User.create({
      fullName: 'Amadou Diallo',
      email: 'farmer.amadou@farmora.com',
      password: farmerPasswordHash,
      phoneNumber: '+2348011111111',
      role: 'farmer',
      farmingField: 'Horticulture',
      address: 'Green Valley Organic Farms, Oyo State',
      isActive: true
    });

    const farmerPoultry = await User.create({
      fullName: 'Grace Adewale',
      email: 'farmer.grace@farmora.com',
      password: farmerPasswordHash,
      phoneNumber: '+2348022222222',
      role: 'farmer',
      farmingField: 'Poultry Farm',
      address: 'Graceful Feathers Broiler Farm, Ogun State',
      isActive: true
    });

    const farmerPisciculture = await User.create({
      fullName: 'Kofi Mensah',
      email: 'farmer.kofi@farmora.com',
      password: farmerPasswordHash,
      phoneNumber: '+2348033333331',
      role: 'farmer',
      farmingField: 'Pisciculture',
      address: 'Lagoon Fresh Aquaculture Basins, Badagry, Lagos',
      isActive: true
    });

    const farmerApiculture = await User.create({
      fullName: 'Zainab Al-Mansoor',
      email: 'farmer.zainab@farmora.com',
      password: farmerPasswordHash,
      phoneNumber: '+2348033333332',
      role: 'farmer',
      farmingField: 'Apiculture',
      address: 'Savanna Honey Groves, Zaria, Kaduna State',
      isActive: true
    });

    const farmerDairy = await User.create({
      fullName: 'Bello Danladi',
      email: 'farmer.bello@farmora.com',
      password: farmerPasswordHash,
      phoneNumber: '+2348033333334',
      role: 'farmer',
      farmingField: 'Dairy Farming',
      address: 'Plateau Pastures Dairy Estate, Jos, Plateau State',
      isActive: true
    });

    // 3. Logistician with company name
    const logistician = await User.create({
      fullName: 'David Okonkwo',
      email: 'logistics.david@farmora.com',
      password: logisticsPasswordHash,
      phoneNumber: '+2348055555555',
      role: 'logistician',
      companyName: 'AgroFleet Express Logistics',
      address: 'Central Logistics Hub, Ikeja, Lagos',
      isActive: true
    });

    // 4. Consumers
    const consumer1 = await User.create({
      fullName: 'Sarah Johnson',
      email: 'consumer.sarah@farmora.com',
      password: consumerPasswordHash,
      phoneNumber: '+2348033333333',
      role: 'consumer',
      address: '42 Marina Street, Central Lagos',
      isActive: true
    });

    const consumer2 = await User.create({
      fullName: 'Michael Chen',
      email: 'consumer.michael@farmora.com',
      password: consumerPasswordHash,
      phoneNumber: '+2348044444444',
      role: 'consumer',
      address: '15 Admiralty Way, Lekki Phase 1, Lagos',
      isActive: true
    });

    // 5. Visitor
    const visitor = await User.create({
      fullName: 'John Visitor',
      email: 'visitor.john@farmora.com',
      password: defaultPasswordHash,
      phoneNumber: '+2348077777777',
      role: 'visitor',
      isActive: true
    });

    // Active session records
    const allUsers = [
      admin,
      farmerHorticulture,
      farmerPoultry,
      farmerPisciculture,
      farmerApiculture,
      farmerDairy,
      logistician,
      consumer1,
      consumer2,
      visitor
    ];

    for (const u of allUsers) {
      await Session.create({
        userId: u.id,
        otpCode: '123456',
        deviceId: 'demo-suite',
        failedAttempts: 0,
        expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
        isActive: true
      });
    }

    console.log('[Seed] Creating realistic products across the 5 agricultural sectors...');
    
    // Pisciculture Products
    const catfish = await Product.create({
      name: 'Fresh African Catfish (Live & Cleaned)',
      description: 'Plump, healthy African catfish farm-raised in natural freshwater aeration ponds with biological filtration.',
      price: 45.00,
      quantity: 800,
      category: 'Pisciculture',
      harvestDate: '2026-09-20',
      farmerId: farmerPisciculture.id,
      unit: 'kg',
      imageUrl: 'assets/images/pisciculture.jpg'
    });

    const tilapia = await Product.create({
      name: 'Freshwater Tilapia (Whole Farm-Fresh)',
      description: 'Sweet, tender whole tilapia caught at peak size in clean earthen aquaculture enclosures.',
      price: 38.00,
      quantity: 1200,
      category: 'Pisciculture',
      harvestDate: '2026-09-22',
      farmerId: farmerPisciculture.id,
      unit: 'kg',
      imageUrl: 'assets/images/pisciculture.jpg'
    });

    // Horticulture Products
    const tomatoes = await Product.create({
      name: 'Greenhouse Vine-Ripened Roma Tomatoes',
      description: 'Sweet, thick-fleshed Roma tomatoes naturally ripened under controlled greenhouse humidity without toxic sprays.',
      price: 26.00,
      quantity: 950,
      category: 'Horticulture',
      harvestDate: '2026-09-21',
      farmerId: farmerHorticulture.id,
      unit: 'crate',
      imageUrl: 'assets/images/horticulture.jpg'
    });

    const peppers = await Product.create({
      name: 'Crisp Bell Peppers & Farm Fresh Vegetables',
      description: 'Vibrant bell peppers, leafy greens, and aromatic farm vegetables harvested fresh every morning.',
      price: 18.50,
      quantity: 700,
      category: 'Horticulture',
      harvestDate: '2026-09-23',
      farmerId: farmerHorticulture.id,
      unit: 'kg',
      imageUrl: 'assets/images/horticulture.jpg'
    });

    // Apiculture Products
    const honey = await Product.create({
      name: 'Raw Forest Wild Honey (100% Unpasteurized)',
      description: 'Amber, nutrient-dense wild blossom honey collected straight from sustainable wooden apiary hives.',
      price: 55.00,
      quantity: 400,
      category: 'Apiculture',
      harvestDate: '2026-09-18',
      farmerId: farmerApiculture.id,
      unit: 'jar (1kg)',
      imageUrl: 'assets/images/apiculture.jpg'
    });

    const honeycomb = await Product.create({
      name: 'Natural Wax Honeycomb Cut',
      description: 'Pure edible wax honeycomb filled with aromatic raw honey, rich in natural pollen and propolis.',
      price: 75.00,
      quantity: 250,
      category: 'Apiculture',
      harvestDate: '2026-09-15',
      farmerId: farmerApiculture.id,
      unit: 'box',
      imageUrl: 'assets/images/apiculture.jpg'
    });

    // Dairy Farming Products
    const milk = await Product.create({
      name: 'Fresh Whole Cow Milk (Pasteurized Grade A)',
      description: 'Rich, creamy unhomogenized whole milk sourced daily from free-grazing Holstein and White Fulani cattle.',
      price: 14.50,
      quantity: 1500,
      category: 'Dairy Farming',
      harvestDate: '2026-09-24',
      farmerId: farmerDairy.id,
      unit: 'liter',
      imageUrl: 'assets/images/dairy.jpg'
    });

    const cheese = await Product.create({
      name: 'Artisanal Fresh Farm Cheese (Wara / Paneer)',
      description: 'Handcrafted mild white cottage cheese produced fresh using traditional coagulating plant extracts.',
      price: 32.00,
      quantity: 350,
      category: 'Dairy Farming',
      harvestDate: '2026-09-23',
      farmerId: farmerDairy.id,
      unit: 'kg',
      imageUrl: 'assets/images/dairy.jpg'
    });

    // Poultry Farm Products
    const eggs = await Product.create({
      name: 'Farm-Fresh Golden Yolk Eggs',
      description: 'Large, clean brown table eggs from free-roaming hens fed on natural grains and calcium supplements.',
      price: 35.00,
      quantity: 1100,
      category: 'Poultry Farm',
      harvestDate: '2026-09-23',
      farmerId: farmerPoultry.id,
      unit: 'crate (30 eggs)',
      imageUrl: 'assets/images/poultry.jpg'
    });

    const chicken = await Product.create({
      name: 'Whole Dressed Broiler Chicken (Cleaned & Chilled)',
      description: 'Tender grain-fed broiler chicken, humanely slaughtered, cleaned, vacuum-sealed, and kept chilled.',
      price: 48.00,
      quantity: 600,
      category: 'Poultry Farm',
      harvestDate: '2026-09-22',
      farmerId: farmerPoultry.id,
      unit: 'bird (2.2kg)',
      imageUrl: 'assets/images/poultry.jpg'
    });

    console.log('[Seed] Creating value chain tracking events across sectors...');
    await ValueChainEvent.bulkCreate([
      {
        farmerId: farmerPisciculture.id,
        productId: catfish.id,
        status: 'Aquaculture Harvest',
        notes: 'Seine net harvest from Pond #3. Average fish weight 1.4kg.',
        timestamp: new Date('2026-09-20T07:30:00Z')
      },
      {
        farmerId: farmerPisciculture.id,
        productId: catfish.id,
        status: 'Aerated Tank Depot',
        notes: 'Transferred into holding oxygen tanks ready for cold-chain transport.',
        timestamp: new Date('2026-09-20T11:00:00Z')
      },
      {
        farmerId: farmerHorticulture.id,
        productId: tomatoes.id,
        status: 'Greenhouse Harvested',
        notes: 'Handpicked at 85% color break for optimal transport shelf life.',
        timestamp: new Date('2026-09-21T06:00:00Z')
      },
      {
        farmerId: farmerApiculture.id,
        productId: honey.id,
        status: 'Centrifugal Extraction',
        notes: 'Cold extracted without heat processing to preserve beneficial enzymes.',
        timestamp: new Date('2026-09-18T14:00:00Z')
      },
      {
        farmerId: farmerDairy.id,
        productId: milk.id,
        status: 'Morning Milking & Chill',
        notes: 'Milked at 05:30 AM, chilled within 20 minutes to 4°C in bulk tank.',
        timestamp: new Date('2026-09-24T06:00:00Z')
      },
      {
        farmerId: farmerPoultry.id,
        productId: eggs.id,
        status: 'Collected & Candled',
        notes: 'Graded and candled for internal quality; zero cracks observed.',
        timestamp: new Date('2026-09-23T08:00:00Z')
      }
    ]);

    console.log('[Seed] Creating demo Order, Payment & Delivery...');
    const demoOrder = await Order.create({
      consumerId: consumer1.id,
      orderDate: new Date(),
      totalAmount: 161.00,
      status: 'in_transit',
      deliveryAddress: '42 Marina Street, Central Lagos'
    });

    await OrderItem.create({
      orderId: demoOrder.id,
      productId: catfish.id,
      qty: 2,
      subtotal: 90.00
    });

    await OrderItem.create({
      orderId: demoOrder.id,
      productId: eggs.id,
      qty: 1,
      subtotal: 35.00
    });

    await OrderItem.create({
      orderId: demoOrder.id,
      productId: tomatoes.id,
      qty: 1,
      subtotal: 26.00
    });

    await Payment.create({
      orderId: demoOrder.id,
      amount: 161.00,
      status: 'completed',
      method: 'card',
      providerReference: 'farmora_txn_demo_reference_123'
    });

    await Delivery.create({
      orderId: demoOrder.id,
      logisticianId: logistician.id,
      pickupPoint: 'Lagoon Fresh Aquaculture Basins, Badagry',
      dropoffPoint: '42 Marina Street, Central Lagos',
      pickupCoordinates: '6.4311,2.8876',
      dropoffCoordinates: '6.4549,3.4246',
      estimatedDistanceKm: 28.4,
      status: 'in_transit'
    });

    console.log('====================================================');
    console.log(' [Seed] Farmora Database Seeded Successfully!       ');
    console.log(' All accounts use Email & Password authentication:  ');
    console.log(' -------------------------------------------------- ');
    console.log(' [Admin]                                            ');
    console.log('   Email:    admin@farmora.com                      ');
    console.log('   Password: Admin123!                              ');
    console.log(' -------------------------------------------------- ');
    console.log(' [Farmer - Horticulture]                            ');
    console.log('   Email:    farmer.amadou@farmora.com              ');
    console.log('   Password: Farmer123!                             ');
    console.log('   Field:    Horticulture                           ');
    console.log(' -------------------------------------------------- ');
    console.log(' [Farmer - Poultry Farm]                            ');
    console.log('   Email:    farmer.grace@farmora.com               ');
    console.log('   Password: Farmer123!                             ');
    console.log('   Field:    Poultry Farm                           ');
    console.log(' -------------------------------------------------- ');
    console.log(' [Farmer - Pisciculture]                            ');
    console.log('   Email:    farmer.kofi@farmora.com                ');
    console.log('   Password: Farmer123!                             ');
    console.log('   Field:    Pisciculture                           ');
    console.log(' -------------------------------------------------- ');
    console.log(' [Farmer - Apiculture]                              ');
    console.log('   Email:    farmer.zainab@farmora.com              ');
    console.log('   Password: Farmer123!                             ');
    console.log('   Field:    Apiculture                             ');
    console.log(' -------------------------------------------------- ');
    console.log(' [Farmer - Dairy Farming]                           ');
    console.log('   Email:    farmer.bello@farmora.com               ');
    console.log('   Password: Farmer123!                             ');
    console.log('   Field:    Dairy Farming                          ');
    console.log(' -------------------------------------------------- ');
    console.log(' [Logistician]                                      ');
    console.log('   Email:    logistics.david@farmora.com            ');
    console.log('   Password: Logistics123!                          ');
    console.log('   Company:  AgroFleet Express Logistics            ');
    console.log(' -------------------------------------------------- ');
    console.log(' [Consumer]                                         ');
    console.log('   Email:    consumer.sarah@farmora.com             ');
    console.log('   Password: Consumer123!                           ');
    console.log('====================================================');

    process.exit(0);
  } catch (error) {
    console.error('[Seed] Failed to seed Farmora database:', error);
    process.exit(1);
  }
};

if (require.main === module) {
  seedDatabase();
}

module.exports = seedDatabase;
