import 'package:flutter/material.dart';

class AppTheme {
  ThemeData getTheme() =>
      ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue);

  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: Colors.deepPurple,
  );

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: Colors.deepPurple,
  );
}
