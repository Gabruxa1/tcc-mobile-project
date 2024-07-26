import 'package:flutter/material.dart';

class CustomDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime currentDate;
  final ValueChanged<DateTime> onDateChanged;

  const CustomDatePickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.currentDate,
    required this.onDateChanged,
  });

  @override
  _CustomDatePickerDialogState createState() => _CustomDatePickerDialogState();
}

class _CustomDatePickerDialogState extends State<CustomDatePickerDialog> {
  late DateTime tempDate;

  @override
  void initState() {
    super.initState();
    tempDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ),
          ),
          child: Localizations.override(
            context: context,
            locale: const Locale('pt', 'BR'),
            child: Builder(
              builder: (context) {
                return CalendarDatePicker(
                  initialDate: tempDate,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  currentDate: widget.currentDate,
                  onDateChanged: (DateTime date) {
                    setState(() {
                      tempDate = date;
                    });
                  },
                  selectableDayPredicate: (DateTime day) {
                    return !day.isAfter(widget.currentDate);
                  },
                );
              },
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            textStyle: const TextStyle(
              color: Colors.black,
            ),
          ),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            widget.onDateChanged(tempDate);
            Navigator.of(context).pop(tempDate);
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            textStyle: const TextStyle(
              color: Colors.black,
            ),
          ),
          child: const Text('Selecionar'),
        ),
      ],
    );
  }
}
