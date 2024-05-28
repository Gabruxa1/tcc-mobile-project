import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel, Event;
import 'package:intl/date_symbol_data_local.dart';
import '../../widgets/custom_drawer.dart'; // Importe o CustomDrawer

class RegistroPontoPage extends StatefulWidget {
  const RegistroPontoPage({Key? key}) : super(key: key);

  @override
  _RegistroPontoPageState createState() => _RegistroPontoPageState();
}

class _RegistroPontoPageState extends State<RegistroPontoPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
  }

  @override
  Widget build(BuildContext context) {
    final CalendarCarousel<Event> calendarCarouselNoHeader =
        CalendarCarousel<Event>(
      locale: 'pt_BR',
      onDayPressed: (DateTime date, List<Event> events) {
        setState(() {
          _selectedDate = date;
        });
      },
      weekendTextStyle:
          const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      todayButtonColor: Colors.green,
      selectedDayButtonColor: Colors.blue,
      selectedDayBorderColor: Colors.blue,
      selectedDateTime: _selectedDate,
      daysHaveCircularBorder: true,
      weekdayTextStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const CustomDrawer(), // Use o CustomDrawer aqui
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Registro de Ponto',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: calendarCarouselNoHeader,
            ),
          ],
        ),
      ),
    );
  }
}
