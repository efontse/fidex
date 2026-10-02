import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/asset_images.dart';
import '../../models/product_model.dart';
import '../../models/value_chain_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/value_chain_service.dart';
import '../../widgets/app_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/value_chain_timeline.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ValueChainModel> _farmerEvents = [];
  bool _isLoadingEvents = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFarmerData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFarmerData() async {
    Provider.of<ProductProvider>(context, listen: false).fetchFarmerProducts();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoadingEvents = true);
    final res = await ValueChainService.getEvents();
    if (mounted) {
      setState(() {
        _isLoadingEvents = false;
        if (res.success && res.data != null) {
          _farmerEvents = res.data!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final myProducts = productProvider.farmerProducts;
    final totalStock = myProducts.fold(0, (sum, p) => sum + p.quantity);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Producer Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadFarmerData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/farmer/add-product');
          if (result == true) {
            _loadFarmerData();
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Post Good', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Farmer Sector Banner
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    final user = auth.currentUser;
                    final field = user?.farmingField ?? 'Horticulture';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.limeTint,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              AppAssetImages.getSectorIconEmoji(field),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Farming Field: $field',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: AppColors.border),
                                      ),
                                      child: const Text('Verified', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Producer: ${user?.fullName ?? "Farmer"} • FARMORA',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // KPI Metric Cards Row
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    return isWide
                        ? Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  title: 'Listed Goods',
                                  value: '${myProducts.length}',
                                  icon: Icons.inventory_2_outlined,
                                  subtitle: 'Active market lots',
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: StatCard(
                                  title: 'Stock Volume',
                                  value: '$totalStock units',
                                  icon: Icons.warehouse_outlined,
                                  subtitle: 'Ready for fulfillment',
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: StatCard(
                                  title: 'Traceability Logs',
                                  value: '${_farmerEvents.length}',
                                  icon: Icons.timeline_rounded,
                                  subtitle: 'Value chain checkpoints',
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              StatCard(
                                title: 'Listed Goods',
                                value: '${myProducts.length}',
                                icon: Icons.inventory_2_outlined,
                                subtitle: 'Active market lots',
                              ),
                              const SizedBox(height: 10),
                              StatCard(
                                title: 'Stock Volume',
                                value: '$totalStock units',
                                icon: Icons.warehouse_outlined,
                                subtitle: 'Ready for fulfillment',
                              ),
                              const SizedBox(height: 10),
                              StatCard(
                                title: 'Traceability Logs',
                                value: '${_farmerEvents.length}',
                                icon: Icons.timeline_rounded,
                                subtitle: 'Value chain checkpoints',
                              ),
                            ],
                          );
                  },
                ),
                const SizedBox(height: 24),

                // Tabs: My Products & Value Chain Logs
                Container(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.divider)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'My Agricultural Goods'),
                      Tab(text: 'Value Chain Traceability Logs'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tab Content
                SizedBox(
                  height: 650,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProductsList(myProducts, productProvider),
                      _buildValueChainTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStockAdjustDialog(BuildContext context, dynamic product) {
    final controller = TextEditingController(text: product.quantity.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warehouse_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Adjust Stock: ${product.name}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current listed inventory: ${product.quantity} ${product.unit}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'New Stock Quantity (${product.unit})',
                prefixIcon: const Icon(Icons.inventory_2_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newQty = int.tryParse(controller.text.trim());
              if (newQty != null && newQty >= 0) {
                Navigator.pop(ctx);
                final success = await Provider.of<ProductProvider>(context, listen: false)
                    .updateStock(product.id, newQty);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Stock updated to $newQty ${product.unit}'
                            : 'Failed to update stock',
                      ),
                      backgroundColor:
                          success ? AppColors.statusSuccess : AppColors.statusError,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save Stock', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, dynamic product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.statusError),
            SizedBox(width: 8),
            Text('Remove Good Listing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          'Are you sure you want to remove "${product.name}" from your catalog and online marketplace? Visitors and buyers will no longer see this lot.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Listing'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await Provider.of<ProductProvider>(context, listen: false)
                  .deleteProduct(product.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '"${product.name}" removed from marketplace'
                          : 'Failed to delete listing',
                    ),
                    backgroundColor:
                        success ? AppColors.statusSuccess : AppColors.statusError,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusError),
            child: const Text('Delete Listing', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(List myProducts, ProductProvider productProvider) {
    if (productProvider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (myProducts.isEmpty) {
      return const EmptyState(
        icon: Icons.grass_rounded,
        title: 'No Agricultural Goods Listed',
        message: 'Tap the Post Good button below to publish your first harvest for buyers.',
      );
    }

    return ListView.separated(
      itemCount: myProducts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = myProducts[index];
        final bool hasImage = product.imageUrl != null && product.imageUrl!.isNotEmpty;
        final String fallbackAsset = AppAssetImages.getImageForSector(product.category);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Produce Thumbnail Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 68,
                      height: 68,
                      child: hasImage
                          ? (product.imageUrl!.startsWith('assets/')
                              ? Image.asset(
                                  product.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Image.asset(fallbackAsset, fit: BoxFit.cover),
                                )
                              : Image.network(
                                  product.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Image.asset(fallbackAsset, fit: BoxFit.cover),
                                ))
                          : Image.asset(fallbackAsset, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${product.price.toStringAsFixed(0)} FCFA / ${product.unit}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark,
                                fontSize: 14.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.limeTint,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                '${AppAssetImages.getSectorIconEmoji(product.category)} ${product.category}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                            Text(
                              'Harvest: ${product.harvestDate ?? "Recent"}',
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.statusSuccessBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.visibility_outlined, size: 11, color: AppColors.statusSuccess),
                                  SizedBox(width: 4),
                                  Text(
                                    'Visible to Visitors',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.statusSuccess,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (product.description.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            product.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 10),
              // Controls Row
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.quantity > 0 ? AppColors.surface : AppColors.statusErrorBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'Stock: ${product.quantity} ${product.unit}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: product.quantity > 0
                            ? AppColors.textPrimary
                            : AppColors.statusError,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit Good Button
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/farmer/add-product',
                            arguments: product,
                          );
                          if (result == true) {
                            _loadFarmerData();
                          }
                        },
                        icon: const Icon(Icons.edit_outlined, size: 14, color: Colors.white),
                        label: const Text(
                          'Edit Good',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Adjust Stock Button
                      OutlinedButton.icon(
                        onPressed: () => _showStockAdjustDialog(context, product),
                        icon: const Icon(Icons.tune_rounded, size: 14),
                        label: const Text('Stock', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Log Step Button
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/farmer/log-event',
                            arguments: product,
                          ).then((_) => _loadEvents());
                        },
                        icon: const Icon(Icons.add_task, size: 14),
                        label: const Text('Log Step', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Delete Listing Button
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 19,
                          color: AppColors.textMuted,
                        ),
                        tooltip: 'Remove Listing',
                        onPressed: () => _showDeleteDialog(context, product),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildValueChainTab() {
    if (_isLoadingEvents) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Timeline of Production Milestones',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/farmer/log-event').then((_) => _loadEvents());
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Milestone', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Expanded(
          child: SingleChildScrollView(
            child: ValueChainTimeline(events: _farmerEvents),
          ),
        ),
      ],
    );
  }
}
