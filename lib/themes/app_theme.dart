import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    // Tema Claro
    return ThemeData.light().copyWith(
      primaryColor: Colors.blue,
      colorScheme: const ColorScheme.light(
        primary: Colors.blue,
        secondary: Colors.blueAccent,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all(Colors.blue),
        trackColor: MaterialStateProperty.all(Colors.transparent),
      ),
    );
  }

  static ThemeData get darkTheme {
    // Tema Escuro
    return ThemeData.dark().copyWith(
      primaryColor: Colors.blue,
      colorScheme: const ColorScheme.dark(
        primary: Colors.blue,
        secondary: Colors.blueAccent,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all(Colors.blue),
        trackColor: MaterialStateProperty.all(Colors.blue.shade700),
      ),
    );
  }
}
