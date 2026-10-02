import 'user_model.dart';
import 'value_chain_model.dart';

class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final String category;
  final String? harvestDate;
  final String unit;
  final int farmerId;
  final String? imageUrl;
  final bool isApproved;
  final UserModel? farmer;
  final List<ValueChainModel> valueChainEvents;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.category,
    this.harvestDate,
    required this.unit,
    required this.farmerId,
    this.imageUrl,
    this.isApproved = true,
    this.farmer,
    this.valueChainEvents = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      category: json['category'] ?? 'Other',
      harvestDate: json['harvestDate']?.toString(),
      unit: json['unit'] ?? 'kg',
      farmerId: json['farmerId'] is int ? json['farmerId'] : int.tryParse(json['farmerId']?.toString() ?? '0') ?? 0,
      imageUrl: json['imageUrl'],
      isApproved: json['isApproved'] == 1 || json['isApproved'] == true,
      farmer: json['farmer'] != null ? UserModel.fromJson(json['farmer']) : null,
      valueChainEvents: json['valueChainEvents'] != null
          ? (json['valueChainEvents'] as List).map((e) => ValueChainModel.fromJson(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'category': category,
      'harvestDate': harvestDate,
      'unit': unit,
      'farmerId': farmerId,
      'imageUrl': imageUrl,
      'isApproved': isApproved,
    };
  }

  bool get inStock => quantity > 0;
}
