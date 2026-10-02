import 'product_model.dart';
import 'user_model.dart';

class OrderItemModel {
  final int id;
  final int orderId;
  final int productId;
  final int qty;
  final double subtotal;
  final ProductModel? product;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.qty,
    required this.subtotal,
    this.product,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      orderId: json['orderId'] is int ? json['orderId'] : int.tryParse(json['orderId']?.toString() ?? '0') ?? 0,
      productId: json['productId'] is int ? json['productId'] : int.tryParse(json['productId']?.toString() ?? '0') ?? 0,
      qty: json['qty'] is int ? json['qty'] : int.tryParse(json['qty']?.toString() ?? '1') ?? 1,
      subtotal: json['subtotal'] != null ? double.tryParse(json['subtotal'].toString()) ?? 0.0 : 0.0,
      product: json['product'] != null ? ProductModel.fromJson(json['product']) : null,
    );
  }
}

class PaymentModel {
  final int id;
  final int orderId;
  final double amount;
  final String status;
  final String method;
  final String? providerReference;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.status,
    required this.method,
    this.providerReference,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      orderId: json['orderId'] is int ? json['orderId'] : int.tryParse(json['orderId']?.toString() ?? '0') ?? 0,
      amount: json['amount'] != null ? double.tryParse(json['amount'].toString()) ?? 0.0 : 0.0,
      status: json['status'] ?? 'pending',
      method: json['method'] ?? 'card',
      providerReference: json['providerReference'],
    );
  }
}

class OrderModel {
  final int id;
  final int consumerId;
  final DateTime orderDate;
  final double totalAmount;
  final String status;
  final String? deliveryAddress;
  final List<OrderItemModel> items;
  final PaymentModel? payment;
  final UserModel? consumer;

  OrderModel({
    required this.id,
    required this.consumerId,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    this.deliveryAddress,
    this.items = const [],
    this.payment,
    this.consumer,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      consumerId: json['consumerId'] is int ? json['consumerId'] : int.tryParse(json['consumerId']?.toString() ?? '0') ?? 0,
      orderDate: json['orderDate'] != null ? DateTime.tryParse(json['orderDate']) ?? DateTime.now() : DateTime.now(),
      totalAmount: json['totalAmount'] != null ? double.tryParse(json['totalAmount'].toString()) ?? 0.0 : 0.0,
      status: json['status'] ?? 'pending',
      deliveryAddress: json['deliveryAddress'],
      items: json['items'] != null
          ? (json['items'] as List).map((i) => OrderItemModel.fromJson(i)).toList()
          : [],
      payment: json['payment'] != null ? PaymentModel.fromJson(json['payment']) : null,
      consumer: json['consumer'] != null ? UserModel.fromJson(json['consumer']) : null,
    );
  }
}
