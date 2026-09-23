import 'package:flutter/material.dart';
import '../data/models/product_model.dart';
import '../data/services/local_storage_service.dart';

class WishlistProvider with ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  final List<ProductModel> _items = [];
  bool _isInitialized = false;

  WishlistProvider() {
    _loadWishlistFromStorage();
  }

  List<ProductModel> get items => _items;

  bool isFavorite(int productId) {
    return _items.any((item) => item.id == productId);
  }

  Future<void> _loadWishlistFromStorage() async {
    if (_isInitialized) return;
    try {
      final rawList = await _storage.getWishlistRaw();
      if (rawList.isNotEmpty) {
        _items.clear();
        for (var raw in rawList) {
          try {
            _items.add(ProductModel.fromJson(raw));
          } catch (e) {
            debugPrint('Error restoring wishlist item: $e');
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
    } finally {
      _isInitialized = true;
    }
  }

  void _persistWishlist() {
    try {
      final rawList = _items.map((p) => p.toJson()).toList();
      _storage.saveWishlistRaw(rawList);
      _storage.saveWishlistIds(_items.map((p) => p.id).toList());
    } catch (e) {
      debugPrint('Error saving wishlist: $e');
    }
  }

  void toggleFavorite(ProductModel product) {
    if (isFavorite(product.id)) {
      _items.removeWhere((item) => item.id == product.id);
    } else {
      _items.add(product);
    }
    _persistWishlist();
    notifyListeners();
  }
}
