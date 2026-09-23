import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/services/api_service.dart';
import '../data/services/local_storage_service.dart';
import '../data/services/firestore_service.dart';
import '../data/services/firebase_auth_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  final LocalStorageService _storage = LocalStorageService();
  final FirestoreService _firestore = FirestoreService();

  UserModel? _currentUser;
  DashboardData? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  DashboardData? get dashboardData => _dashboardData;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initAutoLogin();
  }

  Future<void> _initAutoLogin() async {
    final savedUser = await _storage.getUser();
    if (savedUser != null && savedUser.id > 0 && (savedUser.email.isNotEmpty || savedUser.phone.isNotEmpty)) {
      _currentUser = savedUser;
      notifyListeners();
      await fetchDashboard();
    } else {
      _currentUser = null;
      await _storage.clearToken();
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await _api.login(username, password);
    _isLoading = false;

    if (res['success'] == true) {
      _currentUser = res['user'];
      if (_currentUser != null) {
        await _storage.saveUser(_currentUser!);
        await _firestore.saveUserProfile(
          uid: _currentUser!.id.toString(),
          email: _currentUser!.email,
          name: _currentUser!.name,
          phone: _currentUser!.phone,
          provider: 'password',
        );
      }
      await fetchDashboard();
      notifyListeners();
      return true;
    } else {
      _errorMessage = res['message'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String phone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await _api.register(name, email, phone, password);
    _isLoading = false;

    if (res['success'] == true) {
      _currentUser = res['user'];
      if (_currentUser != null) {
        await _storage.saveUser(_currentUser!);
        await _firestore.saveUserProfile(
          uid: _currentUser!.id.toString(),
          email: _currentUser!.email,
          name: _currentUser!.name,
          phone: _currentUser!.phone,
          provider: 'password',
        );
      }
      await fetchDashboard();
      notifyListeners();
      return true;
    } else {
      _errorMessage = res['message'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> socialLogin({
    required String email,
    String name = '',
    String avatar = '',
    String provider = 'google',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await _api.socialLogin(
      email: email,
      name: name,
      avatar: avatar,
      provider: provider,
    );
    _isLoading = false;

    if (res['success'] == true) {
      _currentUser = res['user'];
      if (_currentUser != null) {
        await _storage.saveUser(_currentUser!);
        await _firestore.saveUserProfile(
          uid: _currentUser!.id.toString(),
          email: _currentUser!.email,
          name: _currentUser!.name,
          phone: _currentUser!.phone,
          avatar: _currentUser!.avatar,
          provider: provider,
        );
      }
      await fetchDashboard();
      notifyListeners();
      return true;
    } else {
      _errorMessage = res['message'];
      notifyListeners();
      return false;
    }
  }

  /// WhatsApp OTP Login: Step 1 - Send OTP
  Future<Map<String, dynamic>> sendWhatsAppOtp(String phone) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await _api.sendWhatsAppOtp(phone);
    _isLoading = false;
    if (res['success'] != true) {
      _errorMessage = res['message'];
    }
    notifyListeners();
    return res;
  }

  /// WhatsApp OTP Login: Step 2 - Verify OTP & Login
  Future<bool> verifyWhatsAppOtp(String phone, String otp, {String name = ''}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await _api.verifyWhatsAppOtp(phone, otp, name: name);
    _isLoading = false;

    if (res['success'] == true) {
      _currentUser = res['user'];
      if (_currentUser != null) {
        await _storage.saveUser(_currentUser!);
        await _firestore.saveUserProfile(
          uid: _currentUser!.id.toString(),
          email: _currentUser!.email,
          name: _currentUser!.name,
          phone: _currentUser!.phone,
          avatar: _currentUser!.avatar,
          provider: 'whatsapp',
        );
      }
      await fetchDashboard();
      notifyListeners();
      return true;
    } else {
      _errorMessage = res['message'];
      notifyListeners();
      return false;
    }
  }

  /// Email Registration OTP: Step 1 - Send OTP
  Future<Map<String, dynamic>> sendEmailOtp(String email, {String name = ''}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await _api.sendEmailOtp(email, name: name);
    _isLoading = false;
    if (res['success'] != true) {
      _errorMessage = res['message'];
    }
    notifyListeners();
    return res;
  }

  /// Email Registration OTP: Step 2 - Verify OTP & Register
  Future<bool> verifyEmailOtpAndRegister({
    required String email,
    required String otp,
    required String password,
    required String name,
    required String phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await _api.verifyEmailOtpAndRegister(
      email: email,
      otp: otp,
      password: password,
      name: name,
      phone: phone,
    );
    _isLoading = false;

    if (res['success'] == true && res['user'] != null) {
      _currentUser = res['user'];
      if (_currentUser != null) {
        await _storage.saveUser(_currentUser!);
        await _firestore.saveUserProfile(
          uid: _currentUser!.id.toString(),
          email: _currentUser!.email,
          name: _currentUser!.name,
          phone: _currentUser!.phone,
          provider: 'email_otp',
        );
      }
      await fetchDashboard();
      notifyListeners();
      return true;
    } else {
      _errorMessage = res['message'];
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await _api.forgotPassword(email);
    _isLoading = false;
    notifyListeners();
    return res;
  }

  Future<void> fetchDashboard() async {
    if (_currentUser == null) {
      _dashboardData = null;
      notifyListeners();
      return;
    }
    final data = await _api.getUserDashboard(_currentUser!.id);
    if (data != null) {
      _dashboardData = data;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _dashboardData = null;
    await _storage.clearToken();
    try {
      await FirebaseAuthService().signOut();
    } catch (_) {}
    notifyListeners();
  }
}
