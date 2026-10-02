import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/product_model.dart';
import '../../models/value_chain_model.dart';
import '../../providers/basket_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/value_chain_service.dart';
import '../../widgets/value_chain_timeline.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  List<ValueChainModel> _events = [];
  bool _isLoadingEvents = false;

  @override
  void initState() {
    super.initState();
    _loadValueChain();
  }

  Future<void> _loadValueChain() async {
    setState(() => _isLoadingEvents = true);
    final response = await ValueChainService.getEvents(productId: widget.product.id);
    if (mounted) {
      setState(() {
        _isLoadingEvents = false;
        if (response.success && response.data != null) {
          _events = response.data!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final basket = Provider.of<BasketProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => Navigator.pushNamed(context, '/basket'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            // Quantity Selector
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                  ),
                  Text(
                    '$_quantity ${product.unit}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: _quantity < product.quantity ? () => setState(() => _quantity++) : null,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Add to Basket CTA
            Expanded(
              child: ElevatedButton.icon(
                onPressed: product.inStock
                    ? () async {
                        final auth = Provider.of<AuthProvider>(context, listen: false);
                        if (!auth.isAuthenticated) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Please sign in or create an account to purchase produce.'),
                              backgroundColor: AppColors.primary,
                              action: SnackBarAction(
                                label: 'Sign In',
                                textColor: Colors.white,
                                onPressed: () => Navigator.pushNamed(context, '/login'),
                              ),
                            ),
                          );
                          return;
                        }
                        final success = await basket.addToBasket(product.id, quantity: _quantity);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Added $_quantity ${product.unit} to basket'
                                    : (basket.errorMessage ?? 'Failed to add item'),
                              ),
                              backgroundColor: success ? AppColors.primaryDark : AppColors.statusError,
                            ),
                          );
                        }
                      }
                    : null,
                icon: const Icon(Icons.shopping_basket_outlined, size: 18),
                label: Text(
                  product.inStock
                      ? 'Add to Basket • ${(product.price * _quantity).toStringAsFixed(0)} FCFA'
                      : 'Out of Stock',
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product Summary Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.limeTint,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              product.category,
                              style: const TextStyle(
                                color: AppColors.primaryDark,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: product.inStock ? AppColors.statusSuccessBg : AppColors.statusErrorBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product.inStock ? '${product.quantity} ${product.unit} available' : 'Out of Stock',
                              style: TextStyle(
                                color: product.inStock ? AppColors.statusSuccess : AppColors.statusError,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${product.price.toStringAsFixed(0)} FCFA / ${product.unit}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Description',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      // Meta Info Grid
                      Row(
                        children: [
                          if (product.harvestDate != null)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Harvest Date', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                  const SizedBox(height: 2),
                                  Text(product.harvestDate!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          if (product.farmer != null)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Producer / Farmer', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                  const SizedBox(height: 2),
                                  Text(product.farmer!.fullName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Value Chain Traceability Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.timeline_rounded, color: AppColors.primaryDark, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Farm-to-Fork Traceability Log',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Verified milestone records registered by the producer along the agricultural value chain.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 18),
                      _isLoadingEvents
                          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                          : ValueChainTimeline(events: _events),
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
}
