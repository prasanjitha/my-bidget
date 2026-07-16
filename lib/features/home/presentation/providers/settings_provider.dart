import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;
  String _currency = 'LKR';
  bool _isLoading = true;

  bool get isDarkMode => _isDarkMode;
  String get currency => _currency;
  bool get isLoading => _isLoading;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _currency = prefs.getString('currency') ?? 'LKR';
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('darkMode', _isDarkMode);
    } catch (e) {
      debugPrint('Error saving dark mode: $e');
    }
  }

  Future<void> setCurrency(String currency) async {
    _currency = currency;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currency', currency);
    } catch (e) {
      debugPrint('Error saving currency: $e');
    }
  }

  String getCurrencySymbol([String? currencyCode]) {
    final code = currencyCode ?? _currency;
    switch (code) {
      case 'LKR':
        return 'RS';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      default:
        return 'RS';
    }
  }

  String getCurrencyName([String? currencyCode]) {
    final code = currencyCode ?? _currency;
    switch (code) {
      case 'LKR':
        return 'Sri Lankan Rupee';
      case 'USD':
        return 'US Dollar';
      case 'EUR':
        return 'Euro';
      case 'GBP':
        return 'British Pound';
      case 'INR':
        return 'Indian Rupee';
      default:
        return 'Sri Lankan Rupee';
    }
  }

  String formatAmount(double amount, [String? currencyCode]) {
    final symbol = getCurrencySymbol(currencyCode);
    final formattedNumber = amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '$symbol $formattedNumber';
  }

  List<String> get availableCurrencies => ['LKR', 'USD', 'EUR', 'GBP', 'INR'];
}
