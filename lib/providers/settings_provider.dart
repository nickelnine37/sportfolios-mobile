import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider = ChangeNotifierProvider<SettingsChangeNotifier>((ref) {
  return SettingsChangeNotifier();
});

List<String> _supportedCurrencies = ['GBP', 'EUR', 'USD'];


class SettingsChangeNotifier with ChangeNotifier {
  String _currency;
  bool _darkMode;

  SettingsChangeNotifier() {
    loadPreferences();
  }

  String get currency => this._currency;
  bool get darkMode => this._darkMode;

  void setCurrency(String currency) {
    if (_supportedCurrencies.contains(currency)) {
      if (this._currency != currency) {
        this._currency = currency;
        notifyListeners();
        savePreferences();
        print('Setting currency to $currency');
      }
    } else {
      print('Unsupported currency: $currency');
    }
  }

  void setDarkMode(bool darkMode) {
    if (this._darkMode != darkMode) {
      this._darkMode = darkMode;
      notifyListeners();
      savePreferences();
    }
  }

  savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('currency', _currency);
    prefs.setBool('darkMode', _darkMode);
  }

  loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setCurrency(prefs.getString('currency') ?? 'GBP');
    setDarkMode(prefs.getBool('darkMode') ?? false);
  }
}
