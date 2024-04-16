import 'package:flutter/material.dart';
import 'package:registro_ponto/themes/app_theme.dart'; // Ajuste para o caminho correto do seu app_theme.dart
import 'package:registro_ponto/screens/login/login_screen.dart';
import 'package:registro_ponto/screens/registro_ponto/registro_ponto_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light; // Inicializa como tema claro

  void _toggleTheme() {
    setState(() {
      // Alterna entre os modos de tema
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => LoginPage(toggleTheme: _toggleTheme),
        '/registroPonto': (context) => const RegistroPontoPage(),
        // Adicione outras rotas conforme necessário
      },
      title: 'Aplicativo de Ponto',
      themeMode: _themeMode, // Controla o tema com base no estado _themeMode
      theme: AppTheme.lightTheme, // Usa o tema claro definido em app_theme.dart
      darkTheme:
          AppTheme.darkTheme, // Usa o tema escuro definido em app_theme.dart
    );
  }
}
