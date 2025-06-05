import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  static const List<Map<String, dynamic>> languages = [
    {
      'name': 'English',
      'locale': 'en',
    },
    {
      'name': 'हिंदी',
      'locale': 'hi',
    },
    {
      'name': 'मराठी',
      'locale': 'mr',
    }
  ];

  Locale selectedLocale = Locale('en');

  void changeLanguage(String language) {
    selectedLocale = Locale(language);
    notifyListeners();
  }
}
