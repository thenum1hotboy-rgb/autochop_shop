import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedTheme = 'Futuristic Galaxy';

  static const List<String> themeNames = [
    'Futuristic Galaxy',
    'Midnight Stealth',
    'Purple Nebula',
    'Ice Blue Cyber',
    'Redline Reactor',
    'Matrix Green',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.deepPurple[900],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text('Theme', style: TextStyle(color: Colors.white70, fontSize: 14)),
          SizedBox(height: 8),
          DropdownButton<String>(
            value: selectedTheme,
            dropdownColor: Colors.grey[900],
            isExpanded: true,
            items: themeNames
                .map((t) => DropdownMenuItem(
                    value: t,
                    child: Text(t, style: TextStyle(color: Colors.white))))
                .toList(),
            onChanged: (val) {
              if (val == null) return;
              setState(() => selectedTheme = val);
              AppTheme.switchTheme(val);
            },
          ),
        ],
      ),
    );
  }
}
