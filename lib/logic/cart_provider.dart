import 'package:flutter/material.dart';
import '../data/models/product_model.dart';
import '../data/services/local_storage_service.dart';

class CartItem {
  final ProductModel product;
  final ProductVariationModel? variation;
  final Map<String, String>? selectedAttributes;
  int quantity;
  bool isSelected;

  CartItem({
    required this.product,
    this.variation,
    this.selectedAttributes,
    this.quantity = 1,
    this.isSelected = true,
  });

  int get effectiveProductId => product.id;
  int? get effectiveVariationId => variation?.id;
  double get unitPrice => variation != null ? variation!.price : product.price;
  double get unitRegularPrice => variation != null ? variation!.regularPrice : product.regularPrice;
  double get totalPrice => unitPrice * quantity;
  double get totalWeightKg => (variation != null && variation!.weightG > 0 ? variation!.weightG / 1000.0 : product.weightInKg) * quantity;
  String get displayImage => (variation != null && variation!.image.isNotEmpty) ? variation!.image : product.image;
  String get variationText {
    if (variation != null && variation!.attributeSummary.isNotEmpty) {
      return variation!.attributeSummary;
    }
    if (selectedAttributes != null && selectedAttributes!.isNotEmpty) {
      return selectedAttributes!.values.join(' / ');
    }
    return '';
  }

  String get cartKey => variation != null ? '${product.id}_${variation!.id}' : '${product.id}';

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'variation': variation?.toJson(),
    'selected_attributes': selectedAttributes,
    'quantity': quantity,
    'is_selected': isSelected,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    product: ProductModel.fromJson(Map<String, dynamic>.from(json['product'] as Map)),
    variation: json['variation'] != null && json['variation'] is Map
        ? ProductVariationModel.fromJson(Map<String, dynamic>.from(json['variation'] as Map))
        : null,
    selectedAttributes: json['selected_attributes'] is Map
        ? Map<String, String>.from(json['selected_attributes'] as Map)
        : null,
    quantity: json['quantity'] is int ? json['quantity'] as int : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
    isSelected: json['is_selected'] != false,
  );
}

class CartProvider with ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  bool _isInitialized = false;

  CartProvider() {
    _loadCartFromStorage();
  }

  int get totalItemCount => itemCount;
  int get selectedCount => _items.where((i) => i.isSelected).fold(0, (sum, i) => sum + i.quantity);
  double get total => finalTotal;
  void removeItem(int productId) => removeFromCart(productId);
  final List<CartItem> _items = [];
  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  String _appliedVoucher = '';
  String get appliedVoucher => _appliedVoucher;

  double _voucherDiscount = 0.0;
  double get voucherDiscount => _voucherDiscount;

  bool _isFreeShippingCoupon = false;
  bool get isFreeShippingCoupon => _isFreeShippingCoupon;

  String _voucherMessage = '';
  String get voucherMessage => _voucherMessage;

  bool _isInsideDhaka = true;
  bool get isInsideDhaka => _isInsideDhaka;

  // Free Shipping Campaign Configuration (Controlled by Admin/Campaign)
  bool _isFreeShippingActive = false; // Default inactive as requested
  double _freeShippingThreshold = 2000.0;

  bool get isFreeShippingActive => _isFreeShippingActive;
  double get freeShippingThreshold => _freeShippingThreshold;

  double get freeShippingProgress {
    if (_freeShippingThreshold <= 0) return 1.0;
    return (subtotal / _freeShippingThreshold).clamp(0.0, 1.0);
  }

  bool get hasUnlockedFreeShipping => _isFreeShippingActive && subtotal >= _freeShippingThreshold;

  void setFreeShippingConfig({required bool isActive, double threshold = 2000.0}) {
    _isFreeShippingActive = isActive;
    _freeShippingThreshold = threshold;
    notifyListeners();
  }

  void setShippingLocation(bool insideDhaka) {
    _isInsideDhaka = insideDhaka;
    notifyListeners();
  }

  Future<void> _loadCartFromStorage() async {
    if (_isInitialized) return;
    try {
      final rawList = await _storage.getCartRaw();
      if (rawList.isNotEmpty) {
        _items.clear();
        for (var raw in rawList) {
          try {
            _items.add(CartItem.fromJson(raw));
          } catch (e) {
            debugPrint('Error restoring cart item: $e');
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart from storage: $e');
    } finally {
      _isInitialized = true;
    }
  }

  void _persistCart() {
    try {
      final rawList = _items.map((i) => i.toJson()).toList();
      _storage.saveCartRaw(rawList);
    } catch (e) {
      debugPrint('Error persisting cart: $e');
    }
  }

  void addToCart(
    ProductModel product, {
    int quantity = 1,
    ProductVariationModel? variation,
    Map<String, String>? selectedAttributes,
  }) {
    final targetKey = variation != null ? '${product.id}_${variation.id}' : '${product.id}';
    final index = _items.indexWhere((item) => item.cartKey == targetKey);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(
        product: product,
        variation: variation,
        selectedAttributes: selectedAttributes,
        quantity: quantity,
      ));
    }
    _persistCart();
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity, [int? variationId]) {
    final index = _items.indexWhere((item) =>
        item.product.id == productId &&
        (variationId == null || item.variation?.id == variationId));
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      _persistCart();
      notifyListeners();
    }
  }

  void toggleItemSelection(int productId, [int? variationId]) {
    final index = _items.indexWhere((item) =>
        item.product.id == productId &&
        (variationId == null || item.variation?.id == variationId));
    if (index >= 0) {
      _items[index].isSelected = !_items[index].isSelected;
      _persistCart();
      notifyListeners();
    }
  }

  void toggleSelectAll(bool selectAll) {
    for (var item in _items) {
      item.isSelected = selectAll;
    }
    _persistCart();
    notifyListeners();
  }

  void removeFromCart(int productId, [int? variationId]) {
    if (variationId != null) {
      _items.removeWhere((item) => item.product.id == productId && item.variation?.id == variationId);
    } else {
      _items.removeWhere((item) => item.product.id == productId);
    }
    _persistCart();
    notifyListeners();
  }

  void removeSelectedItems() {
    _items.removeWhere((item) => item.isSelected);
    _appliedVoucher = '';
    _voucherDiscount = 0.0;
    _isFreeShippingCoupon = false;
    _voucherMessage = '';
    _persistCart();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _appliedVoucher = '';
    _voucherDiscount = 0.0;
    _isFreeShippingCoupon = false;
    _voucherMessage = '';
    _persistCart();
    notifyListeners();
  }

  Future<Map<String, dynamic>> applyCouponCode(String code) async {
    return {'success': false, 'message': 'কুপন সুবিধা আপাতত বন্ধ রয়েছে।'};
  }

  bool applyVoucher(String code) {
    applyCouponCode(code);
    return false;
  }

  void removeVoucher() {
    _appliedVoucher = '';
    _voucherDiscount = 0.0;
    _isFreeShippingCoupon = false;
    _voucherMessage = '';
    notifyListeners();
  }

  double get subtotal {
    return _items
        .where((item) => item.isSelected)
        .fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get totalWeightKg {
    return _items
        .where((item) => item.isSelected)
        .fold(0.0, (sum, item) => sum + item.totalWeightKg);
  }

  double calculateCustomShippingFee({required double weightKg, required bool insideDhaka}) {
    if (weightKg <= 0) return 0;
    if (_isFreeShippingCoupon || hasUnlockedFreeShipping) return 0;

    // Weight-based dynamic calculation:
    // Inside Dhaka: 1st kg = ৳80, each additional kg = +৳20
    // Outside Dhaka: 1st kg = ৳150, each additional kg = +৳30
    final weight = weightKg <= 0 ? 1.0 : weightKg;
    if (insideDhaka) {
      if (weight <= 1.0) {
        return 80.0;
      } else {
        final extraKg = (weight - 1.0).ceil();
        return 80.0 + (extraKg * 20.0);
      }
    } else {
      if (weight <= 1.0) {
        return 150.0;
      } else {
        final extraKg = (weight - 1.0).ceil();
        return 150.0 + (extraKg * 30.0);
      }
    }
  }

  double get shippingFee {
    if (subtotal == 0) return 0;
    return calculateCustomShippingFee(weightKg: totalWeightKg, insideDhaka: _isInsideDhaka);
  }

  double get finalTotal {
    final total = subtotal - _voucherDiscount + shippingFee;
    return total > 0 ? total : 0;
  }

  bool get isAllSelected {
    if (_items.isEmpty) return false;
    return _items.every((item) => item.isSelected);
  }
}
