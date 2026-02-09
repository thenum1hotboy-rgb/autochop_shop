import 'package:flutter_test/flutter_test.dart';
import 'package:autochop_shop/themes/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  group('AppTheme', () {
    test('default theme uses dark brightness', () {
      expect(AppTheme.currentTheme.brightness, Brightness.dark);
    });

    test('default theme has colorScheme with secondary color', () {
      // Bug fix: replaced deprecated accentColor with colorScheme.secondary
      expect(AppTheme.currentTheme.colorScheme.secondary, Colors.purpleAccent);
    });

    test('switchTheme updates currentTheme for known themes', () {
      AppTheme.switchTheme('Midnight Stealth');
      expect(AppTheme.currentTheme.brightness, Brightness.dark);

      AppTheme.switchTheme('Purple Nebula');
      expect(AppTheme.currentTheme.primaryColor, Colors.purpleAccent);

      AppTheme.switchTheme('Ice Blue Cyber');
      expect(AppTheme.currentTheme.primaryColor, Colors.cyanAccent);

      AppTheme.switchTheme('Redline Reactor');
      expect(AppTheme.currentTheme.primaryColor, Colors.redAccent);

      AppTheme.switchTheme('Matrix Green');
      expect(AppTheme.currentTheme.primaryColor, Colors.greenAccent);
    });

    test('switchTheme falls back to default for unknown theme', () {
      AppTheme.switchTheme('Unknown Theme');
      expect(AppTheme.currentTheme.primaryColor, Colors.blueAccent);
    });
  });
}
