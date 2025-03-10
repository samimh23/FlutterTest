import 'package:flutter/material.dart';
import 'package:hanouty/Core/theme/theme_provider.dart';
import 'package:provider/provider.dart';


class ThemeToggleSwitch extends StatelessWidget {
  const ThemeToggleSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    // Use watch instead of read to ensure widget rebuilds when theme changes
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Switch(
      value: isDarkMode,
      onChanged: (_) {
        // Call the toggle method
        themeProvider.toggleTheme();
        print('Switch toggled. New theme mode: ${themeProvider.themeMode}');
      },
      activeColor: Colors.green,
      activeTrackColor: Colors.green.withOpacity(0.5),
      inactiveThumbColor: Colors.grey,
      inactiveTrackColor: Colors.grey.withOpacity(0.5),
    );
  }
}