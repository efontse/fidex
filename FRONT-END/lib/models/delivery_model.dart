import 'order_model.dart';
import 'user_model.dart';

class DeliveryModel {
  final int id;
  final int orderId;
  final int? logisticianId;
  final String pickupPoint;
  final String dropoffPoint;
  final String? pickupCoordinates;
  final String? dropoffCoordinates;
  final double? estimatedDistanceKm;
  final String status;
  final OrderModel? order;
  final UserModel? logistician;

  DeliveryModel({
    required this.id,
    required this.orderId,
    this.logisticianId,
    required this.pickupPoint,
    required this.dropoffPoint,
    this.pickupCoordinates,
    this.dropoffCoordinates,
    this.estimatedDistanceKm,
    required this.status,
    this.order,
    this.logistician,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      orderId: json['orderId'] is int ? json['orderId'] : int.tryParse(json['orderId']?.toString() ?? '0') ?? 0,
      logisticianId: json['logisticianId'] != null ? int.tryParse(json['logisticianId'].toString()) : null,
      pickupPoint: json['pickupPoint'] ?? '',
      dropoffPoint: json['dropoffPoint'] ?? '',
      pickupCoordinates: json['pickupCoordinates'],
      dropoffCoordinates: json['dropoffCoordinates'],
      estimatedDistanceKm: json['estimatedDistanceKm'] != null ? double.tryParse(json['estimatedDistanceKm'].toString()) : null,
      status: json['status'] ?? 'pending',
      order: json['order'] != null ? OrderModel.fromJson(json['order']) : null,
      logistician: json['logistician'] != null ? UserModel.fromJson(json['logistician']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'logisticianId': logisticianId,
      'pickupPoint': pickupPoint,
      'dropoffPoint': dropoffPoint,
      'pickupCoordinates': pickupCoordinates,
      'dropoffCoordinates': dropoffCoordinates,
      'estimatedDistanceKm': estimatedDistanceKm,
      'status': status,
    };
  }
}
