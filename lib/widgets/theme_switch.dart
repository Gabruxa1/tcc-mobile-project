import 'package:flutter/material.dart';

class ThemeSwitch extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggle;

  const ThemeSwitch({
    Key? key,
    required this.isDarkMode,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(
          value: isDarkMode,
          onChanged: (_) => onToggle(),
          activeColor: Colors.blue, // Personalize conforme necessário
        ),
        Icon(
          isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ],
    );
  }
}
