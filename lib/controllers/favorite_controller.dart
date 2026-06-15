import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteController extends ChangeNotifier {
  final Set<int> _favoriteIds = {};
  static const String _favKey = 'favorite_ids';

  Set<int> get favoriteIds => {..._favoriteIds};

  bool isFavorite(int productId) => _favoriteIds.contains(productId);

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_favKey) ?? [];
    _favoriteIds.clear();
    _favoriteIds.addAll(ids.map((e) => int.parse(e)));
    notifyListeners();
  }

  Future<void> toggleFavorite(int productId) async {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _favKey,
      _favoriteIds.map((e) => e.toString()).toList(),
    );
  }
}
