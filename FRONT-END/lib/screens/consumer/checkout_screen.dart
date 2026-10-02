import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/basket_provider.dart';
import '../../providers/order_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  String _selectedPaymentMethod = 'card';

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser?.address != null && auth.currentUser!.address!.isNotEmpty) {
      _addressController.text = auth.currentUser!.address!;
    } else {
      _addressController.text = '42 Marina Street, Central Lagos';
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _handleCheckout() async {
    if (_formKey.currentState?.validate() ?? false) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final basketProvider = Provider.of<BasketProvider>(context, listen: false);

      final result = await orderProvider.checkout(
        deliveryAddress: _addressController.text.trim(),
        paymentMethod: _selectedPaymentMethod,
      );

      if (!mounted) return;

      if (result != null) {
        basketProvider.clearLocalBasket();
        final orderId = result['order'] != null ? result['order']['id'] : null;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.statusSuccess, size: 24),
                SizedBox(width: 8),
                Text('Order Placed!'),
              ],
            ),
            content: Text(
              'Your payment via $_selectedPaymentMethod was successful. A fleet logistician is now being assigned for farm pickup.',
              style: const TextStyle(fontSize: 13.5, height: 1.4),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // dismiss dialog
                  if (orderId != null) {
                    Navigator.pushReplacementNamed(
                      context,
                      '/order-tracking',
                      arguments: orderId,
                    );
                  } else {
                    Navigator.pushReplacementNamed(context, '/consumer');
                  }
                },
                child: const Text('Track Shipment'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderProvider.errorMessage ?? 'Checkout failed'),
            backgroundColor: AppColors.statusError,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final basket = basketProvider.basket;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout & Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Step 1: Delivery Address Card
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
                            Icon(Icons.local_shipping_outlined, color: AppColors.primaryDark, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Delivery Destination',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _addressController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            hintText: 'Enter street, building, city and state...',
                            prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Delivery address is required' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Step 2: Payment Method Selector
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
                            Icon(Icons.payment_outlined, color: AppColors.primaryDark, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Payment Method',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentTile('card', 'Debit / Credit Card', 'Instant secure charge via Payment Gateway', Icons.credit_card),
                        const SizedBox(height: 8),
                        _buildPaymentTile('mobile_money', 'Mobile Money / Bank Transfer', 'Direct USSD or mobile transfer confirmation', Icons.phone_android),
                        const SizedBox(height: 8),
                        _buildPaymentTile('cash_on_delivery', 'Pay on Delivery', 'Settle via verified logistics handler on receipt', Icons.money),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Order Summary Breakdown
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.limeTint,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryLight.withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Total',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${basket?.totalItemCount ?? 0} Harvest item(s)',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                            Text(
                              '${(basket?.totalAmount ?? 0.0).toStringAsFixed(0)} FCFA',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Pay Button
                  ElevatedButton(
                    onPressed: orderProvider.isLoading ? null : _handleCheckout,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: orderProvider.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : Text(
                            'Pay ${(basket?.totalAmount ?? 0.0).toStringAsFixed(0)} FCFA & Confirm Order',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentTile(String id, String title, String subtitle, IconData icon) {
    final isSelected = _selectedPaymentMethod == id;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.limeTint : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primaryDark : AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Icon(icon, size: 22, color: AppColors.primaryDark),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
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
