import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/asset_images.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/empty_state.dart';

class VisitorHomeScreen extends StatefulWidget {
  const VisitorHomeScreen({super.key});

  @override
  State<VisitorHomeScreen> createState() => _VisitorHomeScreenState();
}

class _VisitorHomeScreenState extends State<VisitorHomeScreen> {
  final _searchController = TextEditingController();

  final List<Map<String, String>> _sectors = [
    {
      'title': 'Pisciculture',
      'desc': 'Fresh Catfish, Tilapia & Fingerlings',
      'image': AppAssetImages.pisciculture,
      'emoji': '🐟',
    },
    {
      'title': 'Horticulture',
      'desc': 'Roma Tomatoes, Peppers & Greens',
      'image': AppAssetImages.horticulture,
      'emoji': '🥬',
    },
    {
      'title': 'Apiculture',
      'desc': 'Raw Wild Honey & Pure Honeycomb',
      'image': AppAssetImages.apiculture,
      'emoji': '🍯',
    },
    {
      'title': 'Dairy Farming',
      'desc': 'Fresh Milk, Artisanal Cheese & Yogurt',
      'image': AppAssetImages.dairy,
      'emoji': '🥛',
    },
    {
      'title': 'Poultry Farm',
      'desc': 'Brown Eggs, Broilers & Poultry Feed',
      'image': AppAssetImages.poultry,
      'emoji': '🐔',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSectorShowcase(ProductProvider productProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.category, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Five Core Agricultural Sectors',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Explore verified local produce across fish farming, horticulture, apiculture, dairy, and poultry with full value chain traceability.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sectors.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final sector = _sectors[index];
                    final isSelected = productProvider.selectedCategory == sector['title'];

                    return InkWell(
                      onTap: () => productProvider.setCategory(sector['title']!),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 170,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: isSelected ? 2.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Image.asset(
                                sector['image']!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(11),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              left: 10,
                              right: 10,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(sector['emoji']!, style: const TextStyle(fontSize: 14)),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          sector['title']!,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    sector['desc']!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  radius: 11,
                                  backgroundColor: AppColors.primary,
                                  child: Icon(Icons.check, size: 13, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/farmora_logo.jpg',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.eco_rounded, color: Colors.white, size: 18),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'FARMORA',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Produce Feed',
            onPressed: () => productProvider.fetchProducts(),
          ),
          const SizedBox(width: 4),
          TextButton.icon(
            icon: const Icon(Icons.login_rounded, size: 18),
            label: const Text('Sign In'),
            onPressed: () => Navigator.pushNamed(context, '/login'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Join Free', style: TextStyle(fontSize: 13)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => productProvider.fetchProducts(),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.limeTint,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_outlined, size: 14, color: AppColors.primaryDark),
                            SizedBox(width: 6),
                            Text(
                              'Direct Farm-to-Fork Agricultural Network',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Connecting Producers Directly with Consumers & Logistics',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Explore fresh, certified harvest from verified local producers in Pisciculture, Horticulture, Apiculture, Dairy Farming, and Poultry with full value chain traceability.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Search Bar
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: (query) => productProvider.setSearchQuery(query),
                          decoration: InputDecoration(
                            hintText: 'Search fresh catfish, tomatoes, raw honey, fresh milk, brown eggs...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.arrow_forward_rounded, size: 20, color: AppColors.primary),
                              onPressed: () => productProvider.setSearchQuery(_searchController.text),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Sector Showcase Cards with Realistic Photography
            _buildSectorShowcase(productProvider),

            // Value Chain Feature Highlights
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 650;
                      return isWide
                          ? Row(
                              children: [
                                _buildFeatureCard(
                                  Icons.agriculture,
                                  'Producers (Farmers)',
                                  'List harvest directly, specify farming field, and log processing stages on the value chain.',
                                ),
                                const SizedBox(width: 16),
                                _buildFeatureCard(
                                  Icons.local_shipping,
                                  'Fleet Logistics',
                                  'Route optimization with employer fleet coordination for farm pickups and consumer drop-offs.',
                                ),
                                const SizedBox(width: 16),
                                _buildFeatureCard(
                                  Icons.verified_user,
                                  '100% Traceability',
                                  'Transparent milestone logs from initial harvest to storage, cold chain, and dispatch.',
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _buildFeatureCard(
                                  Icons.agriculture,
                                  'Producers (Farmers)',
                                  'List harvest directly, specify farming field, and log processing stages on the value chain.',
                                ),
                                const SizedBox(height: 12),
                                _buildFeatureCard(
                                  Icons.local_shipping,
                                  'Fleet Logistics',
                                  'Route optimization with employer fleet coordination for farm pickups and consumer drop-offs.',
                                ),
                                const SizedBox(height: 12),
                                _buildFeatureCard(
                                  Icons.verified_user,
                                  '100% Traceability',
                                  'Transparent milestone logs from initial harvest to storage, cold chain, and dispatch.',
                                ),
                              ],
                            );
                    },
                  ),
                ),
              ),
            ),

            // Category Filter Pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: productProvider.categories.map((cat) {
                        final isSelected = productProvider.selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8, bottom: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (_) => productProvider.setCategory(cat),
                            selectedColor: AppColors.limeTint,
                            backgroundColor: AppColors.surface,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 12.5,
                            ),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.border,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Product Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 9,
                                height: 9,
                                decoration: const BoxDecoration(
                                  color: AppColors.statusSuccess,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Live Farm Catalog • Verified Producers',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${productProvider.products.length} lot${productProvider.products.length == 1 ? "" : "s"} listed online',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      productProvider.isLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(48),
                                child: CircularProgressIndicator(color: AppColors.primary),
                              ),
                            )
                          : productProvider.products.isEmpty
                              ? EmptyState(
                                  icon: Icons.inventory_2_outlined,
                                  title: 'No Agricultural Goods Found',
                                  message: 'No active produce found for the selected category filter.',
                                  buttonText: 'Reset Filter',
                                  onButtonPressed: () => productProvider.setCategory('All'),
                                )
                              : LayoutBuilder(
                                  builder: (context, constraints) {
                                    int crossAxisCount = constraints.maxWidth > 900
                                        ? 3
                                        : (constraints.maxWidth > 550 ? 2 : 1);
                                    return GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        mainAxisSpacing: 16,
                                        crossAxisSpacing: 16,
                                        mainAxisExtent: 350,
                                      ),
                                      itemCount: productProvider.products.length,
                                      itemBuilder: (context, index) {
                                        final item = productProvider.products[index];
                                        return ProductCard(
                                          product: item,
                                          showAddToCart: true,
                                          onAddToCart: () {
                                            Navigator.pushNamed(context, '/login');
                                          },
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/product-detail',
                                              arguments: item,
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildFeatureCard(IconData icon, String title, String desc) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.limeTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppColors.primaryDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
