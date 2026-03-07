import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class CollectionProvider with ChangeNotifier {
  int _totalCollection = 128;
  double _totalValue = 4200.0;
  double _valueChangePercentage = 12.5; // Represents +12.5%
  int _wishlistCount = 15;

  int get totalCollection => _totalCollection;
  double get totalValue => _totalValue;
  double get valueChangePercentage => _valueChangePercentage;
  int get wishlistCount => _wishlistCount;

  // Formatting helper
  String get formattedValue {
    if (_totalValue >= 1000) {
      return '\$${(_totalValue / 1000).toStringAsFixed(1)}K';
    }
    return '\$${_totalValue.toStringAsFixed(2)}';
  }

  // Simulate updating stats
  void addVinylToCollection(double value) {
    _totalCollection++;
    _totalValue += value;
    notifyListeners();
  }
}
