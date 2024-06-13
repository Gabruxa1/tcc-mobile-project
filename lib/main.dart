import 'package:flutter/material.dart';
import 'package:registro_ponto/screens/login/login_screen.dart';
import 'package:registro_ponto/screens/registro_ponto/registro_ponto_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const LoginPage(),
        '/login': (context) => const LoginPage(),
        '/registroPonto': (context) => const RegistroPontoPage(),
        // Adicione outras rotas conforme necessário
      },
      title: 'Aplicativo de Ponto',
      themeMode: ThemeMode.light,
    );
  }
}
