class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role; // visitor, farmer, consumer, logistician, admin
  final String? farmingField; // Pisciculture, Horticulture, Apiculture, Dairy Farming, Poultry Farm
  final String? companyName; // For logistician
  final bool isActive;
  final String? address;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    this.email = '',
    this.phoneNumber = '',
    required this.role,
    this.farmingField,
    this.companyName,
    this.isActive = true,
    this.address,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? 'consumer',
      farmingField: json['farmingField'],
      companyName: json['companyName'],
      isActive: json['isActive'] == 1 || json['isActive'] == true,
      address: json['address'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'farmingField': farmingField,
      'companyName': companyName,
      'isActive': isActive,
      'address': address,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  bool get isFarmer => role == 'farmer';
  bool get isConsumer => role == 'consumer';
  bool get isLogistician => role == 'logistician';
  bool get isAdmin => role == 'admin';
  bool get isVisitor => role == 'visitor';

  String get roleDisplay {
    switch (role) {
      case 'farmer':
        return farmingField != null ? 'Producer ($farmingField)' : 'Producer / Farmer';
      case 'consumer':
        return 'Consumer / Buyer';
      case 'logistician':
        return companyName != null ? 'Logistics ($companyName)' : 'Logistics Coordinator';
      case 'admin':
        return 'Platform Administrator';
      case 'visitor':
      default:
        return 'Guest Explorer';
    }
  }
}
