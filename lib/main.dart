import 'package:flutter/material.dart';
import 'package:registro_ponto/screens/login/login_screen.dart';
import 'package:registro_ponto/screens/registro_ponto/registro_ponto_screen.dart';
import 'package:registro_ponto/screens/relatorio/relatorio_screen.dart';
import 'package:registro_ponto/screens/configuracoes/configuracoes_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (String? payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');
      }
    },
  );

  runApp(const MyApp());
}

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
        '/configuracoes': (context) => const ConfiguracoesScreen(),
      },
      title: 'Aplicativo de Ponto',
      themeMode: ThemeMode.light,
    );
  }
}
