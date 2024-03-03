import 'package:flutter/material.dart';
import 'screens/login/login_screen.dart';
import 'screens/registro_ponto/registro_ponto_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => LoginPage(toggleTheme: _toggleTheme),
        '/registroPonto': (context) => const RegistroPontoPage(),
        // outras rotas que você possa adicionar
      },
      title: 'Aplicativo de Ponto',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      initialRoute: '/', // Define a rota inicial do seu aplicativo
    );
  }
}
