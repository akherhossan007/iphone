import 'package:flutter/material.dart';
import '../data/models/brand_model.dart';
import '../data/models/category_model.dart';
import '../data/models/product_model.dart';
import '../data/services/api_service.dart';

class CatalogProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingInitial = false;
  bool get isLoadingInitial => _isLoadingInitial;

  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  List<BrandModel> _brands = [];
  List<BrandModel> get brands => _brands;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  String? _selectedBrand;
  String? get selectedBrand => _selectedBrand;

  double? _minPrice;
  double? _maxPrice;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;

  String _orderBy = 'date';
  String get orderBy => _orderBy;

  int _currentPage = 1;
  int _totalPages = 1;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  /// Returns clean human readable brand name for active filter
  String? get selectedBrandName {
    if (_selectedBrand == null || _selectedBrand!.isEmpty) return null;
    final match = _brands.where((b) => b.slug.toLowerCase() == _selectedBrand!.toLowerCase()).firstOrNull;
    if (match != null) return match.name;
    return _selectedBrand!.replaceAll('-', ' ').split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
  }

  /// Returns clean human readable category name for active filter
  String? get selectedCategoryName {
    if (_selectedCategory == null || _selectedCategory!.isEmpty) return null;
    for (final c in _categories) {
      if (c.slug.toLowerCase() == _selectedCategory!.toLowerCase()) return c.name;
      for (final sub in c.subcategories) {
        if (sub.slug.toLowerCase() == _selectedCategory!.toLowerCase()) return sub.name;
      }
    }
    return _selectedCategory!.replaceAll('-', ' ').split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
  }

  Future<void> loadInitialData() async {
    if (_categories.isNotEmpty && _brands.isNotEmpty) return;
    _isLoadingInitial = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _api.fetchCategories(),
        _api.fetchBrands(),
      ]);
      _categories = results[0] as List<CategoryModel>;
      _brands = results[1] as List<BrandModel>;
    } catch (e) {
      debugPrint('Error loadInitialData in CatalogProvider: $e');
    } finally {
      _isLoadingInitial = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1;
    fetchProducts();
  }

  void setSearch(String query) => setSearchQuery(query);

  void setSort(String sort) {
    _orderBy = sort;
    _currentPage = 1;
    fetchProducts();
  }

  void setCategory(String? categorySlug) {
    _selectedCategory = categorySlug;
    _currentPage = 1;
    fetchProducts();
  }

  void setBrand(String? brandSlug) {
    _selectedBrand = brandSlug;
    _currentPage = 1;
    fetchProducts();
  }

  /// Isolated brand filtering (clears conflicting categories and search query)
  void filterByBrand(String? brandSlug, {bool clearCategory = true, bool clearSearch = true}) {
    if (clearCategory) _selectedCategory = null;
    if (clearSearch) _searchQuery = '';
    _selectedBrand = brandSlug;
    _currentPage = 1;
    _products = [];
    fetchProducts();
  }

  /// Isolated category filtering (clears conflicting brand and search query)
  void filterByCategory(String? categorySlug, {bool clearBrand = true, bool clearSearch = true}) {
    if (clearBrand) _selectedBrand = null;
    if (clearSearch) _searchQuery = '';
    _selectedCategory = categorySlug;
    _currentPage = 1;
    _products = [];
    fetchProducts();
  }

  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    _currentPage = 1;
    fetchProducts();
  }

  void setSorting(String orderby) {
    _orderBy = orderby;
    _currentPage = 1;
    fetchProducts();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedBrand = null;
    _minPrice = null;
    _maxPrice = null;
    _orderBy = 'date';
    _currentPage = 1;
    _products = [];
    fetchProducts();
  }

  Future<void> fetchProducts({bool loadMore = false}) async {
    if (loadMore) {
      if (_currentPage >= _totalPages) return;
      _currentPage++;
    } else {
      _currentPage = 1;
      _isLoading = true;
      notifyListeners();
    }

    try {
      final res = await _api.fetchProducts(
        page: _currentPage,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        category: _selectedCategory,
        brand: _selectedBrand,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        orderby: _orderBy,
      );

      if (loadMore) {
        _products.addAll(res['products'] as List<ProductModel>);
      } else {
        _products = res['products'] as List<ProductModel>;
        _totalPages = res['total_pages'] ?? 1;
      }
    } catch (e) {
      debugPrint('Error fetchProducts in CatalogProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
