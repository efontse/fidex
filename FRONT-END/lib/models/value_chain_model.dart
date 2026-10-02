class ValueChainModel {
  final int id;
  final int farmerId;
  final int? productId;
  final String status;
  final String? notes;
  final DateTime timestamp;
  final String? productName;

  ValueChainModel({
    required this.id,
    required this.farmerId,
    this.productId,
    required this.status,
    this.notes,
    required this.timestamp,
    this.productName,
  });

  factory ValueChainModel.fromJson(Map<String, dynamic> json) {
    return ValueChainModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      farmerId: json['farmerId'] is int ? json['farmerId'] : int.tryParse(json['farmerId']?.toString() ?? '0') ?? 0,
      productId: json['productId'] != null ? int.tryParse(json['productId'].toString()) : null,
      status: json['status'] ?? '',
      notes: json['notes'],
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : (json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() : DateTime.now()),
      productName: json['product'] != null ? json['product']['name'] : json['productName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'productId': productId,
      'status': status,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
