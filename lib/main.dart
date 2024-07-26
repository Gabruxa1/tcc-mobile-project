import 'package:flutter/material.dart';
import 'package:registro_ponto/screens/login/login_screen.dart';
import 'package:registro_ponto/screens/registro_ponto/registro_ponto_screen.dart';
import 'package:registro_ponto/screens/relatorio/relatorio_screen.dart';
import 'package:registro_ponto/screens/configuracoes/configuracoes_screen.dart';
import 'package:registro_ponto/screens/cadastro/cadastro_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

  await _initializeNotifications();
  await _requestPermissions();

  runApp(const MyApp());
}

Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (String? payload) async {
      if (payload != null) {
        debugPrint('Notification payload: $payload');
      } else {
        debugPrint('Notification clicked with no payload');
      }
    },
  );

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'registro_ponto_channel_id',
    'Registro de Ponto',
    description: 'Canal para notificações de registro de ponto',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> _requestPermissions() async {
  final notificationStatus = await Permission.notification.status;
  if (!notificationStatus.isGranted) {
    await Permission.notification.request();
  }

  if (!await Permission.ignoreBatteryOptimizations.isGranted) {
    await Permission.ignoreBatteryOptimizations.request();
  }

  if (!await _hasScheduleExactAlarmPermission()) {
    await _requestScheduleExactAlarmPermission();
  }
}

Future<bool> _hasScheduleExactAlarmPermission() async {
  const intent = AndroidIntent(
    action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
  );
  return (await intent.canResolveActivity()) ?? false;
}

Future<void> _requestScheduleExactAlarmPermission() async {
  const intent = AndroidIntent(
    action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
  );
  await intent.launch();
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
        '/cadastro': (context) => const CadastroScreen(),
      },
      title: 'Aplicativo de Ponto',
      themeMode: ThemeMode.light,
    );
  }
}
