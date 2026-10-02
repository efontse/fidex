import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  List<ProductModel> _farmerProducts = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String? _errorMessage;

  List<ProductModel> get products => _products;
  List<ProductModel> get farmerProducts => _farmerProducts;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;

  final List<String> categories = [
    'All',
    'Horticulture',
    'Pisciculture',
    'Apiculture',
    'Dairy Farming',
    'Poultry Farm',
    'Cereals',
    'Vegetables',
    'Fruits',
    'Seeds & Seedlings',
    'Fertilizers & Agricultural Inputs',
    'Agricultural Equipment',
  ];

  Future<void> fetchProducts({String? category, String? search}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (category != null) _selectedCategory = category;
    if (search != null) _searchQuery = search;

    final response = await ProductService.getProducts(
      category: _selectedCategory,
      search: _searchQuery,
    );

    _isLoading = false;
    if (response.success && response.data != null) {
      _products = response.data!;
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    fetchProducts(category: category, search: _searchQuery);
  }

  void setSearchQuery(String search) {
    _searchQuery = search;
    fetchProducts(category: _selectedCategory, search: search);
  }

  Future<void> fetchFarmerProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ProductService.getFarmerProducts();
    _isLoading = false;

    if (response.success && response.data != null) {
      _farmerProducts = response.data!;
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }

  Future<bool> createProduct({
    required String name,
    required String description,
    required double price,
    required int quantity,
    required String category,
    String? harvestDate,
    required String unit,
    String? imageUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ProductService.createProduct(
      name: name,
      description: description,
      price: price,
      quantity: quantity,
      category: category,
      harvestDate: harvestDate,
      unit: unit,
      imageUrl: imageUrl,
    );

    _isLoading = false;
    if (response.success) {
      await fetchFarmerProducts();
      await fetchProducts();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct({
    required int id,
    required String name,
    required String description,
    required double price,
    required int quantity,
    required String category,
    String? harvestDate,
    required String unit,
    String? imageUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ProductService.updateProduct(
      id: id,
      name: name,
      description: description,
      price: price,
      quantity: quantity,
      category: category,
      harvestDate: harvestDate,
      unit: unit,
      imageUrl: imageUrl,
    );

    _isLoading = false;
    if (response.success) {
      await fetchFarmerProducts();
      await fetchProducts();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(int productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ProductService.deleteProduct(productId);
    _isLoading = false;
    if (response.success) {
      await fetchFarmerProducts();
      await fetchProducts();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStock(int productId, int quantity) async {
    final response = await ProductService.updateStock(productId, quantity);
    if (response.success) {
      await fetchFarmerProducts();
      await fetchProducts();
      return true;
    }
    return false;
  }
}
