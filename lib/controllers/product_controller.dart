import 'package:flutter/material.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';

class ProductController extends ChangeNotifier {
  final ProductRepository _repository;

  ProductController(this._repository);

  List<Product> _products = [];
  List<Product> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _hasFetched = false;

  Future<void> loadProducts({bool forceRefresh = false}) async {
    // Evitar recarregamento desnecessário se não for um pull-to-refresh
    if (!forceRefresh && _hasFetched) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _repository.fetchProducts();
      _hasFetched = true;
    } catch (e) {
      _errorMessage = 'Falha ao carregar produtos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
