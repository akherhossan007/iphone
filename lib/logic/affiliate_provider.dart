import 'package:flutter/material.dart';
import '../data/models/affiliate_model.dart';
import '../data/services/api_service.dart';

class AffiliateProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  AffiliateStatsModel? _stats;
  bool _isLoading = false;

  AffiliateStatsModel? get stats => _stats;
  bool get isLoading => _isLoading;

  Future<void> fetchStats() async {
    _isLoading = true;
    notifyListeners();
    _stats = await _api.getAffiliateStats();
    _isLoading = false;
    notifyListeners();
  }
}
