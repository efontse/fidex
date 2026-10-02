import 'dart:convert';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/asset_images.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool showAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.showAddToCart = true,
  });

  Widget _buildProductImage() {
    final fallbackAsset = AppAssetImages.getImageForSector(product.category);

    Widget imageWidget;
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      final img = product.imageUrl!;
      if (img.startsWith('data:image')) {
        try {
          final base64String = img.substring(img.indexOf(',') + 1);
          final bytes = base64Decode(base64String);
          imageWidget = Image.memory(
            bytes,
            height: 130,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Image.asset(
              fallbackAsset,
              height: 130,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          );
        } catch (_) {
          imageWidget = Image.asset(
            fallbackAsset,
            height: 130,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        }
      } else if (img.startsWith('http://') || img.startsWith('https://')) {
        imageWidget = Image.network(
          img,
          height: 130,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            fallbackAsset,
            height: 130,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      } else {
        // Local asset path
        imageWidget = Image.asset(
          img.startsWith('assets/') ? img : fallbackAsset,
          height: 130,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            fallbackAsset,
            height: 130,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      }
    } else {
      imageWidget = Image.asset(
        fallbackAsset,
        height: 130,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
          child: imageWidget,
        ),
        // Sector overlay tag
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppAssetImages.getSectorIconEmoji(product.category),
                  style: const TextStyle(fontSize: 11),
                ),
                const SizedBox(width: 4),
                Text(
                  product.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (product.harvestDate != null)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Harvest: ${product.harvestDate}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Realistic Sector / Product Image
            _buildProductImage(),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Price and Stock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${product.price.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'per ${product.unit}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: product.inStock ? AppColors.statusSuccessBg : AppColors.statusErrorBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.inStock ? '${product.quantity} in stock' : 'Out of stock',
                          style: TextStyle(
                            color: product.inStock ? AppColors.statusSuccess : AppColors.statusError,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (showAddToCart && onAddToCart != null) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: product.inStock ? onAddToCart : null,
                        icon: const Icon(Icons.shopping_basket_outlined, size: 15),
                        label: const Text('Add to Basket', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          backgroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
