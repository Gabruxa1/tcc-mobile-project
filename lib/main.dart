import 'package:flutter/material.dart';
import 'package:registro_ponto/screens/login/login_screen.dart';
import 'package:registro_ponto/screens/registro_ponto/registro_ponto_screen.dart';
import 'package:registro_ponto/screens/relatorio/relatorio_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('pt', 'BR'),
      ],
      routes: {
        '/': (context) => const LoginPage(),
        '/login': (context) => const LoginPage(),
        '/registroPonto': (context) => const RegistroPontoPage(),
        '/gerarRelatorio': (context) => const RelatorioScreen(),
      },
      title: 'Aplicativo de Ponto',
      themeMode: ThemeMode.light,
    );
  }
}
