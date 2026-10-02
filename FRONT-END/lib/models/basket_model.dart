import 'product_model.dart';

class BasketItemModel {
  final int id;
  final int basketId;
  final int productId;
  int quantity;
  final ProductModel? product;

  BasketItemModel({
    required this.id,
    required this.basketId,
    required this.productId,
    required this.quantity,
    this.product,
  });

  factory BasketItemModel.fromJson(Map<String, dynamic> json) {
    return BasketItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      basketId: json['basketId'] is int ? json['basketId'] : int.tryParse(json['basketId']?.toString() ?? '0') ?? 0,
      productId: json['productId'] is int ? json['productId'] : int.tryParse(json['productId']?.toString() ?? '0') ?? 0,
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      product: json['product'] != null ? ProductModel.fromJson(json['product']) : null,
    );
  }

  double get subtotal => (product?.price ?? 0.0) * quantity;
}

class BasketModel {
  final int id;
  final int consumerId;
  final List<BasketItemModel> items;

  BasketModel({
    required this.id,
    required this.consumerId,
    this.items = const [],
  });

  factory BasketModel.fromJson(Map<String, dynamic> json) {
    return BasketModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      consumerId: json['consumerId'] is int ? json['consumerId'] : int.tryParse(json['consumerId']?.toString() ?? '0') ?? 0,
      items: json['items'] != null
          ? (json['items'] as List).map((i) => BasketItemModel.fromJson(i)).toList()
          : [],
    );
  }

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  int get totalItemCount {
    return items.fold(0, (count, item) => count + item.quantity);
  }
}
