import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeType { light, dark }

class ThemeModel extends ChangeNotifier {
  late ThemeData _currentTheme;
  final SharedPreferences _prefs;

  ThemeModel(this._prefs) {
    String? savedTheme = _prefs.getString('theme');
    if (savedTheme == null) {
      // If no theme preference is saved, default to dark
      _currentTheme = _darkTheme;
      _prefs.setString('theme', 'dark');
    } else {
      // Otherwise, use the saved theme preference
      _currentTheme = savedTheme == 'light' ? _lightTheme : _darkTheme;
    }
  }

  ThemeData get currentTheme => _currentTheme;

  static get myPersonalColor => null;

  void toggleTheme() {
    _currentTheme = _currentTheme == _lightTheme ? _darkTheme : _lightTheme;
    _prefs.setString(
        'theme', _currentTheme == _lightTheme ? 'light' : 'dark');
    notifyListeners();
  }

  


  final _lightTheme = ThemeData.light().copyWith(
    // Background color set to white
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: Colors.black,
      ),
    colorScheme: ColorScheme.light(
      secondary: Colors.black.withOpacity(0.05)
    )
  );



  final _darkTheme = ThemeData.dark().copyWith(
    // Custom dark theme colors
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: Colors.white,
      ),
    // Add more customizations as needed
    colorScheme: ColorScheme.dark(
      // primary: Colors.red.withOpacity(0.05), // Example color
      secondary: Color.fromRGBO(255, 255, 255, 0.4), // Example color
      // surface: Colors.purple, // Example color
      // background: Colors.black, // Example color
      // error: Colors.red, // Example color
      // onPrimary: Colors.white, // Example color
      // onSecondary: Colors.white, // Example color
      // onSurface: Colors.white, // Example color
      // onBackground: Colors.white, // Example color
      // onError: Colors.black, // Example color
      // brightness: Brightness.dark,
    ),
  );
  ThemeData get lightTheme => _lightTheme;
}
