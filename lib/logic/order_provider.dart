import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/order_model.dart';
import '../data/models/payment_settings_model.dart';
import '../data/services/api_service.dart';

class OrderProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  bool _isCreatingOrder = false;
  bool get isCreatingOrder => _isCreatingOrder;
  bool get isSubmitting => _isCreatingOrder;

  PaymentSettingsModel _paymentSettings = PaymentSettingsModel.initial();
  PaymentSettingsModel get paymentSettings => _paymentSettings;

  bool _isPaymentSettingsLoading = false;
  bool get isPaymentSettingsLoading => _isPaymentSettingsLoading;

  bool _isTrackingLoading = false;
  bool get isTrackingLoading => _isTrackingLoading;

  OrderTrackingModel? _trackingData;
  OrderTrackingModel? get trackingData => _trackingData;

  String? _trackingError;
  String? get trackingError => _trackingError;

  Timer? _trackingPollingTimer;

  Future<Map<String, dynamic>> submitOrder(Map<String, dynamic> payload) async {
    if (_isCreatingOrder) {
      return {'success': false, 'message': 'Order submission in progress.'};
    }
    _isCreatingOrder = true;
    notifyListeners();

    final result = await _api.createOrder(payload);
    _isCreatingOrder = false;
    notifyListeners();

    return result;
  }

  Future<Map<String, dynamic>> placeOrder({
    required String name,
    required String phone,
    String? email,
    required String division,
    required String district,
    required String upazila,
    required String address,
    required String paymentMethod,
    String? note,
    required List<Map<String, dynamic>> items,
    String paymentPlan = 'advance_50',
    String? senderNumber,
    String? trxId,
    String? bankRef,
    String? receiptBase64,
    String? receiptFilename,
    double? shippingCost,
    double? totalWeight,
    double? cashoutFee,
  }) async {
    if (_isCreatingOrder) {
      return {
        'status': 'error',
        'message': 'Order is currently being processed. Please do not double tap.',
      };
    }

    final payload = {
      'name': name,
      'phone': phone,
      'email': email ?? '',
      'division': division,
      'district': district,
      'upazila': upazila,
      'address': address,
      'payment_method': paymentMethod,
      'preorder_payment_mode': paymentPlan,
      'sender_number': senderNumber ?? '',
      'trx_id': trxId ?? '',
      'bank_ref': bankRef ?? '',
      if (receiptBase64 != null && receiptBase64.isNotEmpty) 'receipt_base64': receiptBase64,
      if (receiptFilename != null && receiptFilename.isNotEmpty) 'receipt_filename': receiptFilename,
      'shipping_cost': ?shippingCost,
      'total_weight': ?totalWeight,
      'cashout_fee': ?cashoutFee,
      'note': note ?? '',
      'items': items,
      'address_details': {
        'name': name,
        'phone': phone,
        'email': email ?? '',
        'division': division,
        'district': district,
        'upazila': upazila,
        'street': address,
      },
    };

    final res = await submitOrder(payload);
    if (res['success'] == true) {
      final data = res['data'] is Map ? res['data'] : {};
      return {
        'status': 'success',
        'order_id': data['order_id'] ?? 0,
      };
    }
    return {
      'status': 'error',
      'message': res['message'] ?? 'Failed to place order. Please try again.',
    };
  }

  Future<void> trackOrder(String identifier) async {
    _isTrackingLoading = true;
    _trackingError = null;
    _trackingData = null;
    notifyListeners();

    final result = await _api.trackOrder(identifier);
    _isTrackingLoading = false;

    if (result != null) {
      _trackingData = result;
    } else {
      _trackingError = 'No order found matching "$identifier". Please check the phone number or Order ID.';
    }
    notifyListeners();
  }

  Future<void> fetchPaymentSettings({bool forceRefresh = false, String? lang}) async {
    if (_isPaymentSettingsLoading && !forceRefresh) return;
    _isPaymentSettingsLoading = true;
    notifyListeners();

    try {
      final settings = await _api.getPaymentSettings(lang: lang);
      _paymentSettings = settings;
    } catch (e) {
      debugPrint('Error fetching payment settings: $e');
    } finally {
      _isPaymentSettingsLoading = false;
      notifyListeners();
    }
  }

  void startTrackingPolling(String identifier, {Duration interval = const Duration(seconds: 20)}) {
    _trackingPollingTimer?.cancel();
    trackOrder(identifier);
    _trackingPollingTimer = Timer.periodic(interval, (_) {
      if (_trackingData != null) {
        _api.trackOrder(identifier).then((updated) {
          if (updated != null) {
            _trackingData = updated;
            notifyListeners();
          }
        });
      }
    });
  }

  void stopTrackingPolling() {
    _trackingPollingTimer?.cancel();
    _trackingPollingTimer = null;
  }

  Future<Map<String, dynamic>> cancelOrder({
    required int orderId,
    required String reason,
  }) async {
    final res = await _api.cancelOrder(orderId: orderId, reason: reason);
    if (res['success'] == true && _trackingData != null && _trackingData!.orderId == orderId) {
      await trackOrder(orderId.toString());
    }
    return res;
  }

  Future<Map<String, dynamic>> resubmitPayment({
    required int orderId,
    required String trxId,
    String? senderNumber,
    String? receiptUrl,
  }) async {
    final res = await _api.resubmitPayment(
      orderId: orderId,
      trxId: trxId,
      senderNumber: senderNumber,
      receiptUrl: receiptUrl,
    );
    if (res['success'] == true && _trackingData != null && _trackingData!.orderId == orderId) {
      await trackOrder(orderId.toString());
    }
    return res;
  }

  Future<Map<String, dynamic>> requestReturn({
    required int orderId,
    required String reason,
    String? notes,
  }) async {
    final res = await _api.requestReturn(
      orderId: orderId,
      reason: reason,
      notes: notes,
    );
    if (res['success'] == true && _trackingData != null && _trackingData!.orderId == orderId) {
      await trackOrder(orderId.toString());
    }
    return res;
  }

  @override
  void dispose() {
    _trackingPollingTimer?.cancel();
    super.dispose();
  }
}
