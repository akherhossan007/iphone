import 'package:flutter/material.dart';
import '../data/models/banner_model.dart';
import '../data/models/brand_model.dart';
import '../data/models/category_model.dart';
import '../data/models/product_model.dart';
import '../data/models/review_model.dart';
import '../data/services/api_service.dart';
import '../data/services/recently_viewed_service.dart';

class HomeProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<BannerModel> _banners = [];
  List<BannerModel> get banners => _banners;

  List<CategoryModel> _quickCategories = [];
  List<CategoryModel> get quickCategories => _quickCategories;

  List<ProductModel> _flashProducts = [];
  List<ProductModel> get flashProducts => _flashProducts;

  int _flashEndTime = 0;
  int get flashEndTime => _flashEndTime;
  int get flashSaleEndTime => _flashEndTime;

  bool _isFlashActive = false;
  bool get isFlashSaleActive => _isFlashActive && _flashProducts.isNotEmpty && _flashEndTime > (DateTime.now().millisecondsSinceEpoch ~/ 1000);

  List<BrandModel> _authenticBrands = [];
  List<BrandModel> get authenticBrands => _authenticBrands;
  List<BrandModel> get topBrands => _authenticBrands;

  // Real Independent Home Datasets
  List<ProductModel> _forYouProducts = [];
  List<ProductModel> get forYouProducts => _forYouProducts;

  List<ProductModel> _newArrivals = [];
  List<ProductModel> get newArrivals => _newArrivals;

  List<ProductModel> _bestSellers = [];
  List<ProductModel> get bestSellers => _bestSellers;

  List<ProductModel> _weeklyDeals = [];
  List<ProductModel> get weeklyDeals => _weeklyDeals;

  List<ProductModel> _trending = [];
  List<ProductModel> get trending => _trending;

  List<ProductModel> _recentlyViewed = [];
  List<ProductModel> get recentlyViewed => _recentlyViewed;

  List<ReviewModel> _reviews = [];
  List<ReviewModel> get reviews => _reviews;

  DateTime? _lastFetchTime;
  bool _isSyncingBackground = false;
  bool get isSyncingBackground => _isSyncingBackground;

  HomeProvider() {
    fetchHomeData();
  }

  Future<void> fetchHomeData({bool forceRefresh = false, bool silent = false}) async {
    // If not forcing refresh or silent revalidation, throttle within 30 seconds
    if (!forceRefresh && !silent && _lastFetchTime != null && _banners.isNotEmpty) {
      final diff = DateTime.now().difference(_lastFetchTime!);
      if (diff < const Duration(seconds: 30)) {
        return;
      }
    }

    if (silent && _banners.isNotEmpty) {
      if (_isSyncingBackground) return;
      _isSyncingBackground = true;
    } else {
      _isLoading = true;
      notifyListeners();
    }

    // 1. Fetch Home Feed structure
    final data = await _api.getHomeFeed();
    if (data.isNotEmpty) {
      _banners = data['banners'] as List<BannerModel>? ?? [];
      _isFlashActive = data['flash_sale_active'] == true;
      _flashProducts = data['flash_products'] as List<ProductModel>? ?? [];
      _flashEndTime = data['flash_sale_end'] ?? 0;
      final serverBrands = data['brands'] as List<BrandModel>? ?? [];
      if (serverBrands.isNotEmpty) {
        _authenticBrands = serverBrands;
      }
      _forYouProducts = data['for_you'] as List<ProductModel>? ?? [];
      
      final channels = data['channels'] as List? ?? [];
      if (channels.isNotEmpty) {
        _quickCategories = channels
            .whereType<Map<String, dynamic>>()
            .map((c) => CategoryModel(
                  id: (c['id'] is int) ? c['id'] : 0,
                  name: c['name'] ?? '',
                  slug: c['slug'] ?? '',
                  image: c['image'] ?? '',
                  count: (c['count'] is int) ? c['count'] : 0,
                ))
            .toList();
      }
    }

    // 2. Fetch distinct independent feeds concurrently
    final results = await Future.wait([
      _api.fetchNewArrivals(perPage: 8),
      _api.fetchBestSellers(perPage: 8),
      _api.fetchWeeklyDeals(perPage: 8),
      _api.fetchTrendingProducts(perPage: 8),
      RecentlyViewedService.getRecentlyViewed(),
      _api.fetchVerifiedReviews(),
    ]);

    _newArrivals = results[0] as List<ProductModel>;
    _bestSellers = results[1] as List<ProductModel>;
    _weeklyDeals = results[2] as List<ProductModel>;
    _trending = results[3] as List<ProductModel>;
    _recentlyViewed = results[4] as List<ProductModel>;
    _reviews = results[5] as List<ReviewModel>;

    _lastFetchTime = DateTime.now();
    _isLoading = false;
    _isSyncingBackground = false;
    notifyListeners();
  }

  Future<void> refreshRecentlyViewed() async {
    _recentlyViewed = await RecentlyViewedService.getRecentlyViewed();
    notifyListeners();
  }

  Future<void> loadHomeFeed() => fetchHomeData();
}
