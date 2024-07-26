import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class CustomTimePickerDialog extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const CustomTimePickerDialog({
    super.key,
    required this.controller,
    required this.label,
  });

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Localizations(
          locale: const Locale('pt', 'BR'),
          delegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          child: Builder(
            builder: (BuildContext context) {
              return Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Colors.blue,
                    onSurface: Colors.black,
                  ),
                  dialogBackgroundColor: Colors.grey[200],
                  timePickerTheme: TimePickerThemeData(
                    backgroundColor: Colors.grey[200],
                    hourMinuteTextColor: WidgetStateColor.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? Colors.white
                            : Colors.black),
                    hourMinuteShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.blue, width: 1),
                    ),
                    hourMinuteColor: WidgetStateColor.resolveWith((states) =>
                        states.contains(WidgetState.selected)
                            ? Colors.blue
                            : Colors.grey[300]!),
                    dialBackgroundColor: Colors.grey[300],
                  ),
                ),
                child: child!,
              );
            },
          ),
        );
      },
    );
    if (picked != null) {
      controller.text = picked.format(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectTime(context),
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
