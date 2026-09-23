import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static const String _keyToken = 'gb_auth_token';
  static const String _keyUser = 'gb_user_profile';
  static const String _keyCart = 'gb_saved_cart';
  static const String _keyWishlist = 'gb_saved_wishlist';
  static const String _keyLanguage = 'gb_app_language';

  // Language Preference (Defaults to 'en')
  Future<void> saveLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, code);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage) ?? 'en';
  }

  // Auth Token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }

  // User Profile
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, json.encode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyUser);
    if (str != null) {
      try {
        return UserModel.fromJson(json.decode(str));
      } catch (_) {}
    }
    return null;
  }

  // Cart Data
  Future<void> saveCartRaw(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCart, json.encode(items));
  }

  Future<List<Map<String, dynamic>>> getCartRaw() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyCart);
    if (str != null) {
      try {
        final List list = json.decode(str);
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      } catch (_) {}
    }
    return [];
  }

  // Wishlist Data
  Future<void> saveWishlistIds(List<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyWishlist, ids.map((id) => id.toString()).toList());
  }

  Future<List<int>> getWishlistIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyWishlist);
    if (list != null) {
      return list.map((id) => int.tryParse(id) ?? 0).where((id) => id > 0).toList();
    }
    return [];
  }

  Future<void> saveWishlistRaw(List<Map<String, dynamic>> products) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_keyWishlist}_raw', json.encode(products));
  }

  Future<List<Map<String, dynamic>>> getWishlistRaw() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('${_keyWishlist}_raw');
    if (str != null) {
      try {
        final List list = json.decode(str);
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      } catch (_) {}
    }
    return [];
  }

  static const String _keyAddresses = 'gb_saved_addresses';

  Future<void> saveAddressesRaw(List<Map<String, dynamic>> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAddresses, json.encode(addresses));
  }

  Future<List<Map<String, dynamic>>> getAddressesRaw() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyAddresses);
    if (str != null) {
      try {
        final List list = json.decode(str);
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      } catch (_) {}
    }
    return [];
  }
}
