import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'themes/app_theme.dart';

void main() {
  runApp(AutoChopShopApp());
}

class AutoChopShopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoChop Shop',
      theme: AppTheme.currentTheme,
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}