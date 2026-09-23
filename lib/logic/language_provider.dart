import 'package:flutter/material.dart';
import '../core/localization/app_translations.dart';
import '../data/services/local_storage_service.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'en'; // English is Default

  String get currentLanguage => _currentLanguage;
  bool get isEnglish => _currentLanguage == 'en';
  bool get isBengali => _currentLanguage == 'bn';

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final saved = await LocalStorageService().getLanguage();
      if (saved == 'en' || saved == 'bn') {
        _currentLanguage = saved;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setLanguage(String code) async {
    if (code != 'en' && code != 'bn') return;
    if (_currentLanguage == code) return;

    _currentLanguage = code;
    await LocalStorageService().saveLanguage(code);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    final next = _currentLanguage == 'en' ? 'bn' : 'en';
    await setLanguage(next);
  }

  String t(String key, [String fallback = '']) {
    return AppTranslations.get(key, languageCode: _currentLanguage, fallback: fallback);
  }
}
