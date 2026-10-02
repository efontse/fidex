import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/delivery_model.dart';
import '../../providers/logistics_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';

class LogisticianDashboardScreen extends StatefulWidget {
  const LogisticianDashboardScreen({super.key});

  @override
  State<LogisticianDashboardScreen> createState() => _LogisticianDashboardScreenState();
}

class _LogisticianDashboardScreenState extends State<LogisticianDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LogisticsProvider>(context, listen: false).fetchDeliveries();
    });
  }

  void _handleContactProducer(int deliveryId) async {
    final logistics = Provider.of<LogisticsProvider>(context, listen: false);
    final success = await logistics.contactProducer(deliveryId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(logistics.lastActionResult ?? 'Producer contacted via SMS dispatch.'),
        backgroundColor: success ? AppColors.statusSuccess : AppColors.statusError,
      ),
    );
  }

  void _handleLocateConsumer(int deliveryId) async {
    final logistics = Provider.of<LogisticsProvider>(context, listen: false);
    final result = await logistics.locateConsumer(deliveryId);
    if (!mounted) return;

    if (result != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.gps_fixed_rounded, color: AppColors.primaryDark),
              SizedBox(width: 8),
              Text('Consumer Geolocation'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Calculated Coordinates: ${result['coordinates'] ?? "6.5244, 3.3792"}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Distance to Target: ${result['distanceKm'] ?? "12.8"} km'),
              const SizedBox(height: 6),
              Text('Estimated Transit ETA: ${result['estimatedDurationMinutes'] ?? "35"} minutes'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close Map View'),
            ),
          ],
        ),
      );
    }
  }

  void _handleUpdateStatus(int deliveryId, String nextStatus) async {
    final logistics = Provider.of<LogisticsProvider>(context, listen: false);
    final success = await logistics.updateStatus(deliveryId, nextStatus);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Delivery status updated to $nextStatus' : 'Update failed'),
        backgroundColor: success ? AppColors.statusSuccess : AppColors.statusError,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logistics = Provider.of<LogisticsProvider>(context);
    final deliveries = logistics.deliveries;

    final inTransitCount = deliveries.where((d) => d.status == 'in_transit').length;
    final pendingCount = deliveries.where((d) => d.status == 'pending' || d.status == 'assigned').length;
    final deliveredCount = deliveries.where((d) => d.status == 'delivered').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Logistics Fleet Board',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => logistics.fetchDeliveries(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Employer Company Name Banner
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    final user = auth.currentUser;
                    final company = user?.companyName ?? 'AgroFleet Express Logistics';
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
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.business_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      company,
                                      style: const TextStyle(
                                        fontSize: 14.5,
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
                                      child: const Text('Authorized Fleet', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Logistician: ${user?.fullName ?? "David Okonkwo"} • Dedicated Value Chain Fleet',
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

                // KPI Metric Cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    return isWide
                        ? Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  title: 'Pending Pickups',
                                  value: '$pendingCount',
                                  icon: Icons.pending_actions,
                                  subtitle: 'Awaiting dispatch',
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: StatCard(
                                  title: 'In Transit',
                                  value: '$inTransitCount',
                                  icon: Icons.local_shipping_outlined,
                                  subtitle: 'Active on route',
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: StatCard(
                                  title: 'Delivered',
                                  value: '$deliveredCount',
                                  icon: Icons.check_circle_outline,
                                  subtitle: 'Fulfilled orders',
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              StatCard(
                                title: 'Pending Pickups',
                                value: '$pendingCount',
                                icon: Icons.pending_actions,
                                subtitle: 'Awaiting dispatch',
                              ),
                              const SizedBox(height: 10),
                              StatCard(
                                title: 'In Transit',
                                value: '$inTransitCount',
                                icon: Icons.local_shipping_outlined,
                                subtitle: 'Active on route',
                              ),
                              const SizedBox(height: 10),
                              StatCard(
                                title: 'Delivered',
                                value: '$deliveredCount',
                                icon: Icons.check_circle_outline,
                                subtitle: 'Fulfilled orders',
                              ),
                            ],
                          );
                  },
                ),
                const SizedBox(height: 24),

                const Text(
                  'Fulfillment & Delivery Dispatches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                logistics.isLoading
                    ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.primary)))
                    : deliveries.isEmpty
                        ? EmptyState(
                            icon: Icons.local_shipping_outlined,
                            title: 'No Deliveries Assigned',
                            message: 'New orders will automatically appear here for farm pickup and consumer routing.',
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: deliveries.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final delivery = deliveries[index];
                              return _buildDeliveryCard(delivery);
                            },
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryCard(DeliveryModel delivery) {
    return Container(
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
              Text(
                'Shipment #${delivery.id} (Order #${delivery.orderId})',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              StatusBadge(status: delivery.status),
            ],
          ),
          const SizedBox(height: 14),

          // Route Points
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.place_outlined, color: AppColors.primaryDark, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pickup Hub', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    Text(delivery.pickupPoint, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.home_outlined, color: AppColors.primaryDark, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Consumer Drop-off', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    Text(delivery.dropoffPoint, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Action Triggers Row
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () => _handleContactProducer(delivery.id),
                icon: const Icon(Icons.phone_in_talk_outlined, size: 16),
                label: const Text('Contact Producer', style: TextStyle(fontSize: 12)),
              ),
              OutlinedButton.icon(
                onPressed: () => _handleLocateConsumer(delivery.id),
                icon: const Icon(Icons.my_location_rounded, size: 16),
                label: const Text('Locate Consumer (GPS)', style: TextStyle(fontSize: 12)),
              ),
              if (delivery.status == 'pending' || delivery.status == 'assigned')
                ElevatedButton.icon(
                  onPressed: () => _handleUpdateStatus(delivery.id, 'in_transit'),
                  icon: const Icon(Icons.departure_board_rounded, size: 16),
                  label: const Text('Start Transit', style: TextStyle(fontSize: 12)),
                ),
              if (delivery.status == 'in_transit')
                ElevatedButton.icon(
                  onPressed: () => _handleUpdateStatus(delivery.id, 'delivered'),
                  icon: const Icon(Icons.done_all_rounded, size: 16),
                  label: const Text('Mark as Delivered', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusSuccess),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
