import 'package:flutter/material.dart';
import 'package:registro_ponto/themes/app_theme.dart';
import 'package:registro_ponto/screens/login/login_screen.dart';
import 'package:registro_ponto/screens/registro_ponto/registro_ponto_screen.dart';
import 'package:registro_ponto/screens/relatorio/relatorio_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

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
        '/': (context) => LoginPage(toggleTheme: _toggleTheme),
        '/login': (context) => LoginPage(toggleTheme: _toggleTheme),
        '/registroPonto': (context) => const RegistroPontoPage(),
        '/gerarRelatorio': (context) => const RelatorioScreen(),
      },
      title: 'Aplicativo de Ponto',
      themeMode: _themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
    );
  }
}
