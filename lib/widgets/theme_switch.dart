import 'package:flutter/material.dart';

class ThemeSwitch extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggle;

  const ThemeSwitch({
    super.key,
    required this.isDarkMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(
          value: isDarkMode,
          onChanged: (_) => onToggle(),
          activeColor: Colors.blue,
        ),
        Icon(
          isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ],
    );
  }
}
