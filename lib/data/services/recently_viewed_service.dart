import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class RecentlyViewedService {
  static const String _key = 'gb_recently_viewed_products';
  static const int _maxItems = 20;

  static Future<void> addProduct(ProductModel product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> rawList = prefs.getStringList(_key) ?? [];
      
      // Remove any existing entry with the same ID
      rawList.removeWhere((itemStr) {
        try {
          final map = json.decode(itemStr);
          return map['id'] == product.id;
        } catch (_) {
          return false;
        }
      });

      // Add to front
      final productMap = {
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'regular_price': product.regularPrice,
        'sale_price': product.salePrice,
        'on_sale': product.onSale,
        'discount_percentage': product.discountPercentage,
        'image': product.image,
        'brands': product.brands,
        'categories': product.categories,
      };

      rawList.insert(0, json.encode(productMap));

      // Limit to _maxItems
      if (rawList.length > _maxItems) {
        rawList.removeRange(_maxItems, rawList.length);
      }

      await prefs.setStringList(_key, rawList);
    } catch (_) {}
  }

  static Future<List<ProductModel>> getRecentlyViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> rawList = prefs.getStringList(_key) ?? [];
      final List<ProductModel> products = [];

      for (var str in rawList) {
        try {
          final map = json.decode(str) as Map<String, dynamic>;
          products.add(ProductModel.fromJson(map));
        } catch (_) {}
      }
      return products;
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }
}
