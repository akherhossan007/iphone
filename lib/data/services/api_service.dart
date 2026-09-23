import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_endpoints.dart';
import 'local_storage_service.dart';
import '../models/affiliate_model.dart';
import '../models/banner_model.dart';
import '../models/brand_model.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../models/voucher_model.dart';
import '../models/payment_settings_model.dart';
import '../models/review_model.dart';

class ApiService {
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Cryptographically safe Auth headers (HMAC Token)
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await LocalStorageService().getToken();
    final headers = Map<String, String>.from(defaultHeaders);
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static const Duration requestTimeout = Duration(seconds: 15);

  static Future<http.Response> _get(
    Uri uri, {
    Map<String, String>? headers,
    Duration? timeout,
  }) {
    return http
        .get(uri, headers: headers ?? defaultHeaders)
        .timeout(timeout ?? requestTimeout);
  }

  static Future<http.Response> _post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
  }) {
    return http
        .post(uri, headers: headers ?? defaultHeaders, body: body, encoding: encoding)
        .timeout(timeout ?? requestTimeout);
  }

  // Complete verified brand slug -> WooCommerce product_brand term ID mapping
  static const Map<String, int> brandSlugToId = {
    'nivea': 1830,
    'vaseline': 1788,
    'la-roche-posay': 1860,
    'dove': 1694,
    'watsons': 1689,
    'goodvirtuesco': 1746,
    'eucerin': 1655,
    'sunsilk': 1745,
    'biore': 1748,
    'hadalabo': 1754,
    'olay': 1757,
    'pantene': 1723,
    'garnier': 1834,
    'loreal': 1828,
    'blackmores': 1686,
    'simple': 1750,
    'neutrogena': 1719,
    'tresemme': 1756,
    'cetaphil': 1653,
    'himalaya': 1733,
    'cerave': 1648,
    'tsubaki-premium': 1806,
    'aveeno': 1633,
    'cosrx': 1836,
    'anua': 1710,
    'fino': 1674,
    'ponds': 1665,
    'sunplay': 1856,
  };

  // Complete verified 48 WooCommerce product_cat term ID mapping
  static const Map<String, int> categorySlugToId = {
    // 1. Skincare Subcategories
    'serum': 1712,
    'facial-cleanser': 1668,
    'cleanser': 1668,
    'skincare-cleanser': 1737,
    'skincare-moisturizer': 1604,
    'moisturizer': 1604,
    'sunscreen': 1652,
    'skincare-toner': 1654,
    'toner': 1654,
    'skincare-mask': 1755,
    'mask': 1755,
    'eye-care': 1842,
    'face-scrubs-exfoliators': 1734,
    'micellar-cleansing-water': 1841,
    'lip-care': 1657,
    'acne-treatment': 1794,
    'anti-aging': 1765,
    'hydrating': 1775,
    'whitening': 1760,

    // 2. Haircare Subcategories
    'haircare-shampoo': 1678,
    'shampoo': 1678,
    'haircare-conditioner': 1679,
    'conditioner': 1679,
    'hair-mask': 1676,
    'hair-oil': 1677,
    'hair-treatment': 1722,

    // 3. Personal Care & Bath Subcategories
    'bath-body': 1691,
    'bath-body-2': 1696,
    'body-wash': 1693,
    'body-lotion': 1718,
    'body-scrub': 1703,
    'deodorant': 1708,
    'hand-foot-care': 1843,

    // 4. Baby Care Subcategories
    'baby-bath': 1621,
    'baby-lotion': 1611,
    'baby-shampoo': 1618,
    'baby-milk-nutrition': 1908,

    // 5. Makeup Subcategories
    'makeup-facemakeup': 1758,
    'face-makeup': 1758,
    'eye-makeup': 1884,
    'makeup-lip': 1846,
    'lip-makeup': 1846,
    'makeup-makeupremover': 1753,
    'makeup-remover': 1753,

    // 6. Oral Care Subcategories
    'oralcare-toothpaste': 1681,
    'toothpaste': 1681,
    'mouthwash': 1845,

    // 7. Health & Supplements
    'health-supplements': 1688,
    'supplements': 1688,
    'vitamins-minerals': 1844,

    // 8. Top-level Parent Categories
    'skin-care': 1735,
    'skincare': 1735,
    'haircare': 1672,
    'hair-care': 1675,
    'personal-care': 1690,
    'baby-care': 1607,
    'makeup': 1752,
    'oralcare': 1680,
    'oral-care': 1680,
    'health': 1687,
  };

  bool _isSuccess(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      return decoded['success'] == true || decoded['status'] == 'success';
    }
    return false;
  }

  dynamic _extractData(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      return decoded.containsKey('data') ? decoded['data'] : decoded;
    }
    return decoded;
  }

  // 1. Home Feed
  Future<Map<String, dynamic>> getHomeFeed() async {
    try {
      final response = await _get(Uri.parse(ApiEndpoints.home), headers: defaultHeaders);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (_isSuccess(decoded)) {
          final data = _extractData(decoded);
          if (data is Map<String, dynamic>) {
            final banners = (data['banners'] as List? ?? []).map((e) => BannerModel.fromJson(e)).toList();
            final channels = (data['channels'] ?? data['quick_categories']) as List? ?? [];
            
            final flashSaleMap = data['flash_sale'] as Map<String, dynamic>? ?? {};
            final flashProducts = (flashSaleMap['products'] as List? ?? []).map((e) => ProductModel.fromJson(e)).toList();
            final flashEndTimestamp = flashSaleMap['end_timestamp'] ?? 0;
            final isFlashActive = (flashSaleMap['is_active'] == true);
            
            final brands = ((data['top_brands'] ?? data['authentic_brands']) as List? ?? [])
                .map((e) => BrandModel.fromJson(e))
                .toList();

            List<ProductModel> forYou = [];
            if (data['for_you'] is List) {
              forYou = (data['for_you'] as List).map((e) => ProductModel.fromJson(e)).toList();
            } else if (data['just_for_you'] is Map && data['just_for_you']['products'] is List) {
              forYou = (data['just_for_you']['products'] as List).map((e) => ProductModel.fromJson(e)).toList();
            }

            return {
              'banners': banners,
              'channels': channels,
              'flash_sale_active': isFlashActive,
              'flash_sale_end': flashEndTimestamp,
              'flash_products': flashProducts,
              'brands': brands,
              'for_you': forYou,
            };
          }
        }
      }
      return {};
    } catch (e) {
      debugPrint('Error getHomeFeed: $e');
      return {};
    }
  }

  // 2. Flash Sale
  Future<List<ProductModel>> getFlashSale() async {
    try {
      final response = await _get(Uri.parse(ApiEndpoints.flashSale), headers: defaultHeaders);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (_isSuccess(decoded)) {
          final data = _extractData(decoded);
          if (data is Map && data['is_active'] == false) {
            return [];
          }
          final list = (data is Map ? data['products'] : data) as List? ?? [];
          return list.map((e) => ProductModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getFlashSale: $e');
      return [];
    }
  }

  // 3. Categories
  Future<List<CategoryModel>> fetchCategories() => getCategories();
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _get(Uri.parse(ApiEndpoints.categories), headers: defaultHeaders);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (_isSuccess(decoded)) {
          final data = _extractData(decoded);
          final list = data as List? ?? [];
          return list.map((e) => CategoryModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getCategories: $e');
      return [];
    }
  }

  // 4. Brands
  Future<List<BrandModel>> fetchBrands() => getBrands();
  Future<List<BrandModel>> getBrands() async {
    try {
      final response = await _get(Uri.parse(ApiEndpoints.brands), headers: defaultHeaders);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (_isSuccess(decoded)) {
          final data = _extractData(decoded);
          final list = data as List? ?? [];
          return list.map((e) => BrandModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getBrands: $e');
      return [];
    }
  }

  // 5. Products Catalog with Verified Brand & Category Resolution
  Future<Map<String, dynamic>> fetchProducts({
    int page = 1,
    int perPage = 12,
    String? category,
    String? brand,
    String? search,
    String? orderby,
    double? minPrice,
    double? maxPrice,
  }) => getProducts(
    page: page,
    perPage: perPage,
    category: category,
    brand: brand,
    search: search,
    orderby: orderby,
    minPrice: minPrice,
    maxPrice: maxPrice,
  );

  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int perPage = 12,
    String? category,
    String? brand,
    String? search,
    String? orderby,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      // 1. If brand or category filter is requested, query WooCommerce wc/v3 with term ID
      int? brandId;
      if (brand != null && brand.isNotEmpty) {
        final clean = brand.toLowerCase().trim();
        brandId = int.tryParse(clean) ?? brandSlugToId[clean];
      }

      int? categoryId;
      if (category != null && category.isNotEmpty) {
        final clean = category.toLowerCase().trim();
        categoryId = int.tryParse(clean) ??
            categorySlugToId[clean] ??
            categorySlugToId[clean.replaceAll(' ', '-')] ??
            categorySlugToId[clean.replaceAll('&', '').replaceAll('  ', ' ').trim().replaceAll(' ', '-')];
      }

      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = categoryId != null ? categoryId.toString() : category;
      }
      if (brand != null && brand.isNotEmpty) {
        queryParams['brand'] = brandId != null ? brandId.toString() : brand;
      }
      if (brandId != null) queryParams['brand_id'] = brandId.toString();
      if (categoryId != null) queryParams['category_id'] = categoryId.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (orderby != null && orderby.isNotEmpty) queryParams['orderby'] = orderby;
      if (minPrice != null && minPrice > 0) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null && maxPrice > 0) queryParams['max_price'] = maxPrice.toString();

      final uri = Uri.parse(ApiEndpoints.products).replace(queryParameters: queryParams);
      final response = await _get(uri, headers: defaultHeaders);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (_isSuccess(decoded)) {
          final data = _extractData(decoded);
          if (data is Map<String, dynamic>) {
            final products = (data['products'] as List? ?? []).map((e) => ProductModel.fromJson(e)).toList();
            return {
              'products': products,
              'total': data['total'] ?? data['total_items'] ?? 0,
              'total_pages': data['total_pages'] ?? 1,
              'current_page': data['current_page'] ?? page,
            };
          }
        }
      }
      return {'products': <ProductModel>[], 'total': 0, 'total_pages': 1};
    } catch (e) {
      debugPrint('Error getProducts: $e');
      return {'products': <ProductModel>[], 'total': 0, 'total_pages': 1};
    }
  }

  // 6. Dedicated Home Feeds
  Future<List<ProductModel>> fetchNewArrivals({int perPage = 8}) async {
    final res = await getProducts(orderby: 'date', perPage: perPage);
    return res['products'] as List<ProductModel>? ?? [];
  }
  Future<List<ProductModel>> fetchBestSellers({int perPage = 6}) async {
    final res = await getProducts(orderby: 'popularity', perPage: perPage);
    return res['products'] as List<ProductModel>? ?? [];
  }

  Future<List<ProductModel>> fetchWeeklyDeals({int perPage = 8}) async {
    final res = await getProducts(orderby: 'date', perPage: perPage);
    return res['products'] as List<ProductModel>? ?? [];
  }

  Future<List<ProductModel>> fetchTrendingProducts({int perPage = 8}) async {
    final res = await getProducts(orderby: 'rating', perPage: perPage);
    return res['products'] as List<ProductModel>? ?? [];
  }

  // Smart Multi-Stage Barcode / SKU / Visual Product Lookup
  Future<ProductModel?> lookupProductByBarcode(String rawBarcode) async {
    try {
      final clean = rawBarcode.trim();
      if (clean.isEmpty) return null;

      // 1. Query GlowBay Smart Barcode & Visual Lookup API (handles SKU, EAN, UPC, and keywords)
      final smartUri = Uri.parse('https://glowbaybd.com/wp-json/glowbay/v1/products/lookup-barcode?code=${Uri.encodeComponent(clean)}');
      final smartRes = await _get(smartUri, headers: defaultHeaders);
      if (smartRes.statusCode == 200) {
        final decoded = json.decode(smartRes.body);
        if (decoded['success'] == true && decoded['data'] != null && decoded['data']['product'] != null) {
          return ProductModel.fromJson(decoded['data']['product'] as Map<String, dynamic>);
        }
      }

      // 2. Query GlowBay App API by SKU / search term
      final res = await getProducts(search: clean, perPage: 1);
      final products = res['products'] as List<ProductModel>? ?? [];
      if (products.isNotEmpty) {
        return products.first;
      }

      // 3. Direct GlowBay Product ID check
      final int? directId = int.tryParse(clean);
      if (directId != null && directId > 0) {
        final directProd = await getProductDetail(directId);
        if (directProd != null && directProd.id == directId) {
          return directProd;
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error lookupProductByBarcode: $e');
      return null;
    }
  }

  // 7. Product Detail (PDP) with Full Hierarchy & Related Sourcing
  Future<ProductModel?> fetchProductDetails(int id) => getProductDetail(id);
  Future<ProductModel?> getProductDetail(int id) async {
    try {
      final response = await _get(Uri.parse('${ApiEndpoints.productDetail}$id'), headers: defaultHeaders);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (_isSuccess(decoded)) {
          final data = _extractData(decoded);
          return ProductModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getProductDetail: $e');
      return null;
    }
  }

  // 8. Order Placement
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderPayload) async {
    try {
      final response = await _post(
        Uri.parse(ApiEndpoints.createOrder),
        headers: defaultHeaders,
        body: json.encode(orderPayload),
      );
      final decoded = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300 && _isSuccess(decoded)) {
        return {'success': true, 'data': _extractData(decoded)};
      }
      return {'success': false, 'message': decoded['message'] ?? 'Failed to place order.'};
    } catch (e) {
      debugPrint('Error createOrder: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // 9. Order Live Tracking (5-Stage Cross-Border Lifecycle + Steadfast Telemetry)
  Future<OrderTrackingModel?> trackOrder(String identifier) async {
    try {
      final authHeaders = await getAuthHeaders();
      // Try official live tracking endpoint first
      http.Response response = await _get(
        Uri.parse('${ApiEndpoints.liveTrackOrder}$identifier'),
        headers: authHeaders,
      );

      // Fallback to legacy app namespace if needed
      if (response.statusCode != 200) {
        response = await _get(
          Uri.parse('${ApiEndpoints.trackOrder}$identifier'),
          headers: authHeaders,
        );
      }

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (_isSuccess(decoded)) {
          return OrderTrackingModel.fromJson(_extractData(decoded));
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error trackOrder: $e');
      return null;
    }
  }

  // 7.1 Cancel Order (Instant Cancellation & Restock)
  Future<Map<String, dynamic>> cancelOrder({
    required int orderId,
    required String reason,
  }) async {
    try {
      final authHeaders = await getAuthHeaders();
      final response = await _post(
        Uri.parse(ApiEndpoints.cancelOrder(orderId)),
        headers: authHeaders,
        body: json.encode({'reason': reason}),
      );
      final decoded = json.decode(response.body);
      if (response.statusCode == 200 && _isSuccess(decoded)) {
        return {
          'success': true,
          'message': decoded['message'] ?? 'অর্ডারটি সফলভাবে বাতিল করা হয়েছে।',
          'data': _extractData(decoded),
        };
      }
      return {
        'success': false,
        'message': decoded['message'] ?? 'অর্ডার বাতিল করতে সমস্যা হয়েছে।',
      };
    } catch (e) {
      debugPrint('Error cancelOrder: $e');
      return {'success': false, 'message': 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি'};
    }
  }

  // 7.2 Resubmit Corrected Payment Details
  Future<Map<String, dynamic>> resubmitPayment({
    required int orderId,
    required String trxId,
    String? senderNumber,
    String? receiptUrl,
  }) async {
    try {
      final authHeaders = await getAuthHeaders();
      final body = <String, dynamic>{
        'trx_id': trxId,
        if (senderNumber != null && senderNumber.isNotEmpty) 'sender_number': senderNumber,
        if (receiptUrl != null && receiptUrl.isNotEmpty) 'receipt_url': receiptUrl,
      };
      final response = await _post(
        Uri.parse(ApiEndpoints.resubmitPayment(orderId)),
        headers: authHeaders,
        body: json.encode(body),
      );
      final decoded = json.decode(response.body);
      if (response.statusCode == 200 && _isSuccess(decoded)) {
        return {
          'success': true,
          'message': decoded['message'] ?? 'পেমেন্ট তথ্য সফলভাবে জমা দেওয়া হয়েছে।',
          'data': _extractData(decoded),
        };
      }
      return {
        'success': false,
        'message': decoded['message'] ?? 'পেমেন্ট তথ্য আপডেট করা সম্ভব হয়নি।',
      };
    } catch (e) {
      debugPrint('Error resubmitPayment: $e');
      return {'success': false, 'message': 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি'};
    }
  }

  // 7.3 Request Return / Refund
  Future<Map<String, dynamic>> requestReturn({
    required int orderId,
    required String reason,
    String? notes,
  }) async {
    try {
      final authHeaders = await getAuthHeaders();
      final body = <String, dynamic>{
        'reason': reason,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };
      final response = await _post(
        Uri.parse(ApiEndpoints.requestReturn(orderId)),
        headers: authHeaders,
        body: json.encode(body),
      );
      final decoded = json.decode(response.body);
      if (response.statusCode == 200 && _isSuccess(decoded)) {
        return {
          'success': true,
          'message': decoded['message'] ?? 'রিটার্ন রিকোয়েস্ট সফলভাবে গৃহীত হয়েছে।',
          'data': _extractData(decoded),
        };
      }
      return {
        'success': false,
        'message': decoded['message'] ?? 'রিটার্ন রিকোয়েস্ট প্রক্রিয়াকরণে সমস্যা হয়েছে।',
      };
    } catch (e) {
      debugPrint('Error requestReturn: $e');
      return {'success': false, 'message': 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি'};
    }
  }

  // 9.1 Staff Barcode Scanner (KL & Dhaka Hubs)
  Future<Map<String, dynamic>> scanStaffBarcode({
    required String barcode,
    required String action,
    String? staffNotes,
  }) async {
    try {
      final authHeaders = await getAuthHeaders();
      final body = json.encode({
        'barcode': barcode,
        'action': action,
        if (staffNotes != null && staffNotes.isNotEmpty) 'staff_notes': staffNotes,
      });

      // Try official live scan endpoint first
      http.Response response = await _post(
        Uri.parse(ApiEndpoints.scanBarcode),
        headers: authHeaders,
        body: body,
      );

      // Fallback to app route if 404
      if (response.statusCode == 404) {
        response = await _post(
          Uri.parse(ApiEndpoints.scanBarcodeApp),
          headers: authHeaders,
          body: body,
        );
      }

      final decoded = json.decode(response.body);
      if (response.statusCode == 200 && _isSuccess(decoded)) {
        return {
          'success': true,
          'message': decoded['message'] ?? 'বারকোড স্ক্যান সফল হয়েছে।',
          'data': _extractData(decoded),
        };
      }
      return {
        'success': false,
        'message': decoded['message'] ?? 'স্ক্যান ব্যর্থ হয়েছে। আবার চেষ্টা করুন।',
      };
    } catch (e) {
      debugPrint('Error scanStaffBarcode: $e');
      return {
        'success': false,
        'message': 'নেটওয়ার্ক এরর: $e',
      };
    }
  }

  // 9b. Payment Methods & Gateway Configuration
  Future<PaymentSettingsModel> getPaymentSettings({String? lang}) async {
    try {
      final activeLang = lang ?? await LocalStorageService().getLanguage();
      final url = '${ApiEndpoints.paymentMethods}?lang=$activeLang';
      final response = await _get(
        Uri.parse(url),
        headers: defaultHeaders,
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (_isSuccess(decoded)) {
          final data = _extractData(decoded);
          if (data is Map<String, dynamic>) {
            return PaymentSettingsModel.fromJson(data);
          }
        }
      }
      return PaymentSettingsModel.initial();
    } catch (e) {
      debugPrint('Error getPaymentSettings: $e');
      return PaymentSettingsModel.initial();
    }
  }

  // 10. Auth: Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _post(
        Uri.parse(ApiEndpoints.login),
        headers: defaultHeaders,
        body: json.encode({'username': username, 'password': password}),
      );
      final decoded = json.decode(response.body);
      if (response.statusCode == 200 && _isSuccess(decoded)) {
        return {'success': true, 'user': UserModel.fromJson(_extractData(decoded))};
      }
      return {'success': false, 'message': decoded['message'] ?? 'Login failed.'};
    } catch (e) {
      debugPrint('Error login: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // 11. Auth: Register
  Future<Map<String, dynamic>> register(String name, String email, String phone, String password) async {
    try {
      final response = await _post(
        Uri.parse(ApiEndpoints.register),
        headers: defaultHeaders,
        body: json.encode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      );
      final decoded = json.decode(response.body);
      if (response.statusCode == 200 && _isSuccess(decoded)) {
        return {'success': true, 'user': UserModel.fromJson(_extractData(decoded))};
      }
      return {'success': false, 'message': decoded['message'] ?? 'Registration failed.'};
    } catch (e) {
      debugPrint('Error register: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // 11.1 Auth: Social Login
  Future<Map<String, dynamic>> socialLogin({
    required String email,
    String name = '',
    String avatar = '',
    String provider = 'google',
  }) async {
    try {
      final response = await _post(
        Uri.parse(ApiEndpoints.socialLogin),
        headers: defaultHeaders,
        body: json.encode({
          'email': email,
          'name': name,
          'avatar': avatar,
          'provider': provider,
        }),
      );
      final decoded = json.decode(response.body);
      if (response.statusCode == 200 && _isSuccess(decoded)) {
        return {'success': true, 'user': UserModel.fromJson(_extractData(decoded))};
      }
      return {'success': false, 'message': decoded['message'] ?? 'Social login failed.'};
    } catch (e) {
      debugPrint('Error socialLogin: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // 11.2 Auth: Forgot Password
  Future<Map<String, dynamic>> forgotPassword(String userLogin) async {
    try {
      final response = await _post(
        Uri.parse(ApiEndpoints.forgotPassword),
        headers: defaultHeaders,
        body: json.encode({'user_login': userLogin}),
      );
      final decoded = json.decode(response.body);
      if (response.statusCode == 200 && _isSuccess(decoded)) {
        return {'success': true, 'message': decoded['message'] ?? 'Password reset link sent.'};
      }
      return {'success': false, 'message': decoded['message'] ?? 'Unable to send reset email.'};
    } catch (e) {
      debugPrint('Error forgotPassword: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // 11.3 WhatsApp Auth: Send OTP
  Future<Map<String, dynamic>> sendWhatsAppOtp(String phone) async {
    try {
      final response = await _post(
        Uri.parse(ApiEndpoints.whatsAppSendOtp),
        headers: defaultHeaders,
        body: json.encode({'phone': phone.trim()}),
      );
      final decoded = json.decode(response.body);
      if (response.statusCode == 200 && decoded['success'] == true) {
        return {
          'success': true,
          'message': decoded['message'] ?? 'OTP code sent via WhatsApp.',
          'otp': decoded['otp'],
          'phone': decoded['phone'] ?? phone,
        };
      }
      return {'success': false, 'message': decoded['message'] ?? 'Failed to send WhatsApp OTP.'};
    } catch (e) {
      debugPrint('Error sendWhatsAppOtp: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // 11.4 WhatsApp Auth: Verify OTP & Login
  Future<Map<String, dynamic>> verifyWhatsAppOtp(String phone, String otp, {String name = ''}) async {
    try {
      final response = await _post(
        Uri.parse(ApiEndpoints.whatsAppVerifyOtp),
        headers: defaultHeaders,
        body: json.encode({
          'phone': phone.trim(),
          'otp': otp.trim(),
          if (name.isNotEmpty) 'name': name.trim(),
        }),
      );
      final decoded = json.decode(response.body);
      if (response.statusCode == 200 && decoded['success'] == true && decoded['user'] != null) {
        return {
          'success': true,
          'user': UserModel.fromJson(decoded['user']),
          'token': decoded['token'] ?? '',
          'message': decoded['message'] ?? 'Successfully logged in with WhatsApp.',
        };
      }
      return {'success': false, 'message': decoded['message'] ?? 'Invalid or expired OTP.'};
    } catch (e) {
      debugPrint('Error verifyWhatsAppOtp: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // 11.5 Email Auth: Send Registration OTP
  Future<Map<String, dynamic>> sendEmailOtp(String email, {String name = ''}) async {
    try {
      final response = await _post(
        Uri.parse(ApiEndpoints.sendEmailOtp),
        headers: defaultHeaders,
        body: json.encode({
          'email': email.trim().toLowerCase(),
          if (name.isNotEmpty) 'name': name.trim(),
        }),
      );
      final decoded = json.decode(response.body);
      if (response.statusCode == 200 && (decoded['success'] == true || _isSuccess(decoded))) {
        final data = _extractData(decoded);
        return {
          'success': true,
          'message': decoded['message'] ?? 'Verification code sent to your email.',
          'otp': data is Map ? data['otp'] : decoded['otp'],
          'email': data is Map ? data['email'] : email,
        };
      }
      return {
        'success': false,
        'message': decoded['message'] ?? 'Failed to send verification code.',
      };
    } catch (e) {
      debugPrint('Error sendEmailOtp: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // 11.6 Email Auth: Verify OTP & Complete Registration
  Future<Map<String, dynamic>> verifyEmailOtpAndRegister({
    required String email,
    required String otp,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final response = await _post(
        Uri.parse(ApiEndpoints.verifyEmailOtp),
        headers: defaultHeaders,
        body: json.encode({
          'email': email.trim().toLowerCase(),
          'otp': otp.trim(),
          'password': password,
          'name': name.trim(),
          'phone': phone.trim(),
        }),
      );
      final decoded = json.decode(response.body);
      if (response.statusCode == 200 && (decoded['success'] == true || _isSuccess(decoded))) {
        final data = _extractData(decoded);
        if (data is Map<String, dynamic>) {
          return {
            'success': true,
            'user': UserModel.fromJson(data),
            'message': decoded['message'] ?? 'Account created successfully.',
          };
        }
      }
      return {
        'success': false,
        'message': decoded['message'] ?? 'Verification failed. Please check the OTP.',
      };
    } catch (e) {
      debugPrint('Error verifyEmailOtpAndRegister: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // 12. User Dashboard
  Future<DashboardData?> getUserDashboard(int userId) async {
    try {
      final headers = await getAuthHeaders();
      final response = await _get(
        Uri.parse('${ApiEndpoints.userDashboard}?user_id=$userId'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (_isSuccess(decoded)) {
          return DashboardData.fromJson(_extractData(decoded));
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getUserDashboard: $e');
      return null;
    }
  }

  // 13. User Orders
  Future<List<dynamic>> getUserOrders(int userId) async {
    try {
      final headers = await getAuthHeaders();
      final response = await _get(
        Uri.parse('${ApiEndpoints.userOrders}?user_id=$userId'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (_isSuccess(decoded)) {
          final data = _extractData(decoded);
          return data as List? ?? [];
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getUserOrders: $e');
      return [];
    }
  }

  // 14. Vouchers
  Future<List<VoucherModel>> getVouchers() async {
    try {
      final response = await _get(Uri.parse(ApiEndpoints.vouchers), headers: defaultHeaders);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (_isSuccess(decoded)) {
          final data = _extractData(decoded);
          final list = data as List? ?? [];
          return list.map((e) => VoucherModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getVouchers: $e');
      return [];
    }
  }

  // 15. Product Sourcing Request
  Future<Map<String, dynamic>> submitProductRequest(String name, String brand, String phone, String notes) async {
    try {
      final response = await _post(
        Uri.parse(ApiEndpoints.requestProduct),
        headers: defaultHeaders,
        body: json.encode({
          'product_name': name,
          'brand': brand,
          'phone': phone,
          'notes': notes,
        }),
      );
      final decoded = json.decode(response.body);
      if (response.statusCode == 200 && _isSuccess(decoded)) {
        return {'success': true, 'message': decoded['message']};
      }
      return {'success': false, 'message': decoded['message'] ?? 'Failed to submit request.'};
    } catch (e) {
      debugPrint('Error submitProductRequest: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // 16. Affiliate Stats
  Future<AffiliateStatsModel?> getAffiliateStats() async {
    try {
      final response = await _get(Uri.parse(ApiEndpoints.affiliateStats), headers: defaultHeaders);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (_isSuccess(decoded)) {
          return AffiliateStatsModel.fromJson(_extractData(decoded));
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getAffiliateStats: $e');
      return null;
    }
  }

  // 17. Validate Real WooCommerce Coupon
  Future<Map<String, dynamic>> validateCoupon(String code, double subtotal) async {
    try {
      final response = await _post(
        Uri.parse(ApiEndpoints.validateCoupon),
        headers: defaultHeaders,
        body: json.encode({'code': code, 'subtotal': subtotal}),
      );
      final decoded = json.decode(response.body);
      if (response.statusCode == 200 && _isSuccess(decoded)) {
        final data = _extractData(decoded);
        return {
          'success': true,
          'code': data['code'] ?? code,
          'discount': (data['discount'] is num) ? (data['discount'] as num).toDouble() : 0.0,
          'free_shipping': data['free_shipping'] == true,
          'message': data['message'] ?? 'Coupon applied successfully!',
        };
      }
      return {
        'success': false,
        'message': decoded['message'] ?? 'Invalid coupon code.',
      };
    } catch (e) {
      debugPrint('Error validateCoupon: $e');
      return {
        'success': false,
        'message': 'Failed to validate coupon: $e',
      };
    }
  }

  // 18. Verified Customer Reviews
  Future<List<ReviewModel>> fetchVerifiedReviews() async {
    try {
      final response = await _get(Uri.parse(ApiEndpoints.reviews), headers: defaultHeaders);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (_isSuccess(decoded)) {
          final data = _extractData(decoded);
          if (data is List) {
            return data.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>)).toList();
          }
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetchVerifiedReviews: $e');
      return [];
    }
  }

  // 19. Register FCM Push Device Token
  Future<bool> registerDeviceToken({required String token, int? userId}) async {
    try {
      final url = Uri.parse('${ApiEndpoints.baseUrl}/notifications/register-token');
      final response = await _post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': token,
          'user_id': userId ?? 0,
          'device_info': 'Flutter App Android/iOS',
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error registerDeviceToken: $e');
      return false;
    }
  }

  // 20. Smart Search API (Connected with GlowBay Smart Search Plugin)
  Future<Map<String, dynamic>> smartSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return {'brands': [], 'categories': [], 'products': []};
    }
    try {
      final uri = Uri.parse(
        'https://glowbaybd.com/wp-admin/admin-ajax.php?action=gb_smart_search&q=${Uri.encodeComponent(trimmed)}',
      );
      final response = await _get(uri, headers: {
        'Accept': 'application/json',
      }, timeout: const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          final data = decoded['data'];
          if (data is Map<String, dynamic>) {
            return data;
          }
        }
      }
      return {'brands': [], 'categories': [], 'products': []};
    } catch (e) {
      debugPrint('Error smartSearch: $e');
      return {'brands': [], 'categories': [], 'products': []};
    }
  }

  // 21. User Addresses Remote Sync
  Future<List<dynamic>> getUserAddresses(int userId) async {
    try {
      final headers = await getAuthHeaders();
      final response = await _get(
        Uri.parse('${ApiEndpoints.userAddresses}?user_id=$userId'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (_isSuccess(decoded)) {
          final data = _extractData(decoded);
          return data as List? ?? [];
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getUserAddresses: $e');
      return [];
    }
  }

  Future<bool> saveUserAddresses(int userId, List<Map<String, dynamic>> addresses) async {
    try {
      final headers = await getAuthHeaders();
      final response = await _post(
        Uri.parse(ApiEndpoints.userAddresses),
        headers: headers,
        body: json.encode({
          'user_id': userId,
          'addresses': addresses,
        }),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return _isSuccess(decoded);
      }
      return false;
    } catch (e) {
      debugPrint('Error saveUserAddresses: $e');
      return false;
    }
  }
}

