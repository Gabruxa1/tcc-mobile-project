import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const RegistroPontoPage(),
    );
  }
}

class RegistroPontoPage extends StatelessWidget {
  const RegistroPontoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Cor de fundo do cabeçalho
        title: Text(
          'Registro de Ponto',
          style: Theme.of(context)
              .textTheme
              .titleLarge, // Estilo do texto do título
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu), // Ícone do menu hamburguer
              onPressed: () {
                Scaffold.of(context)
                    .openDrawer(); // Abre o menu lateral ao ser clicado
              },
            );
          },
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            CalendarWidget(), // Widget do calendário
          ],
        ),
      ),
    );
  }
}

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CalendarCarousel(
      selectedDateTime: DateTime.now(),
      todayButtonColor: Colors.blue, // Cor do botão "Hoje"
    );
  }
}
