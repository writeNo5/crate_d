import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../models/vinyl.dart';
import '../../features/crate/data/mock_data.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class CollectionProvider with ChangeNotifier {
  final Isar isar;
  List<Vinyl> _vinyls = [];
  bool _isLoading = true;

  double _valueChangePercentage = 12.5; // Dummy, could be dynamic later
  int _wishlistCount = 15;

  CollectionProvider(this.isar) {
    _init();
  }

  Future<void> _init() async {
    final count = await isar.vinyls.count();
    if (count == 0) {
      final mocks = MockData.getVinyls().take(10).toList();
      await isar.writeTxn(() async {
        await isar.vinyls.putAll(mocks);
      });
    }

    await fetchVinyls();
    _isLoading = false;
    notifyListeners();
  }

  List<Vinyl> get vinyls => _vinyls;
  bool get isLoading => _isLoading;

  int get totalCollection => _vinyls.length;
  
  double get totalValue => _vinyls.fold(0.0, (sum, v) => sum + (v.avgPrice ?? 0.0));
  
  double get valueChangePercentage => _valueChangePercentage;
  int get wishlistCount => _wishlistCount;

  String get formattedValue {
    final value = totalValue;
    if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(1)}K';
    }
    return '\$${value.toStringAsFixed(2)}';
  }

  Future<void> fetchVinyls() async {
    _vinyls = await isar.vinyls.where().sortByAddedAtDesc().findAll();
    notifyListeners();
  }

  Future<void> addVinyl(Vinyl vinyl) async {
    await isar.writeTxn(() async {
      await isar.vinyls.put(vinyl);
    });
    await fetchVinyls();
  }
  
  Future<void> deleteVinyl(Id id) async {
    await isar.writeTxn(() async {
      await isar.vinyls.delete(id);
    });
    await fetchVinyls();
  }
}
