import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData currentTheme = futuristicGalaxy;

  static final futuristicGalaxy = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blueAccent,
    scaffoldBackgroundColor: Colors.black,
    accentColor: Colors.purpleAccent,
    fontFamily: 'Neon',
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.deepPurple[900],
      elevation: 2,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        textStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );

  static void switchTheme(String themeName) {
    switch (themeName) {
      case 'Midnight Stealth':
        currentTheme = ThemeData.dark();
        break;
      case 'Purple Nebula':
        currentTheme = futuristicGalaxy.copyWith(primaryColor: Colors.purpleAccent);
        break;
      case 'Ice Blue Cyber':
        currentTheme = futuristicGalaxy.copyWith(primaryColor: Colors.cyanAccent);
        break;
      case 'Redline Reactor':
        currentTheme = futuristicGalaxy.copyWith(primaryColor: Colors.redAccent);
        break;
      case 'Matrix Green':
        currentTheme = futuristicGalaxy.copyWith(primaryColor: Colors.greenAccent);
        break;
      default:
        currentTheme = futuristicGalaxy;
    }
  }
}