import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel, Event;
import 'package:intl/date_symbol_data_local.dart';

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
      weekendTextStyle: const TextStyle(
        color: Colors.red,
      ),
      todayButtonColor: Colors.transparent,
      todayBorderColor: Colors.blue,
      selectedDayButtonColor: Colors.blue,
      selectedDayBorderColor: Colors.blue,
      selectedDateTime: _selectedDate,
      daysHaveCircularBorder: true,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Registro de Jornada'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Implementar ação do menu
            },
          ),
        ],
      ),
      drawer: const Drawer(
          // Aqui você pode adicionar o código para o Drawer, se necessário
          ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
                height: 16), // Adiciona espaço entre o AppBar e o conteúdo
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
            // Definindo uma altura fixa para o container do calendário
            Container(
              height: MediaQuery.of(context).size.height *
                  0.6, // Altura como 60% da altura disponível da tela
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child:
                  calendarCarouselNoHeader, // Configuração do calendário aqui
            ),
          ],
        ),
      ),
    );
  }
}
