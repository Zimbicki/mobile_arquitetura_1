import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_state.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductRepository _repository;

  ProductState _state = const ProductState();
  ProductState get state => _state;

  bool _hasFetched = false;
  Set<int> _favoriteIds = {};
  static const String _favKey = 'favorite_ids';

  ProductViewModel(this._repository);

  Future<void> init() async {
    await _loadFavorites();
  }

  Future<void> loadProducts({bool forceRefresh = false}) async {
    if (!forceRefresh && _hasFetched) return;

    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final products = await _repository.fetchProducts();
      final withFavorites = _applyFavorites(products);
      _state = _state.copyWith(isLoading: false, products: withFavorites);
      _hasFetched = true;
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Falha ao carregar produtos: $e',
      );
    }
    notifyListeners();
  }

  Future<Product> fetchProductById(int id) async {
    final product = await _repository.fetchProductById(id);
    return product.copyWith(isFavorite: _favoriteIds.contains(id));
  }

  void toggleFavorite(int productId) {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }

    final updated = _applyFavorites(_state.products);
    _state = _state.copyWith(products: updated);
    notifyListeners();
    _persistFavorites();
  }

  bool isFavorite(int productId) => _favoriteIds.contains(productId);

  void reset() {
    _state = const ProductState();
    _hasFetched = false;
    notifyListeners();
  }

  List<Product> _applyFavorites(List<Product> products) {
    return products
        .map((p) => p.copyWith(isFavorite: _favoriteIds.contains(p.id)))
        .toList();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_favKey) ?? [];
    _favoriteIds = ids.map((e) => int.parse(e)).toSet();
  }

  Future<void> _persistFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _favKey,
      _favoriteIds.map((e) => e.toString()).toList(),
    );
  }
}
