import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class ConfiguracoesService {
  final SharedPreferences _prefs;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  static const String defaultEntradaTime = '07:45';
  static const String defaultSaidaTime = '16:45';

  ConfiguracoesService(this._prefs, this.flutterLocalNotificationsPlugin);

  Future<void> saveAlarmTimes(String entrada, String saida) async {
    await _prefs.setString(
        'entrada', entrada.isEmpty ? defaultEntradaTime : entrada);
    await _prefs.setString('saida', saida.isEmpty ? defaultSaidaTime : saida);
    await _scheduleNotification('entrada', getEntradaTime());
    await _scheduleNotification('saida', getSaidaTime());
  }

  String getEntradaTime() {
    return _prefs.getString('entrada') ?? defaultEntradaTime;
  }

  String getSaidaTime() {
    return _prefs.getString('saida') ?? defaultSaidaTime;
  }

  Future<void> _scheduleNotification(String type, String time) async {
    if (time.isEmpty) return;

    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    debugPrint(
        'Agendando notificação diária para $type às $scheduledTime no fuso horário local');

    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'registro_ponto_channel_id',
      'Registro de Ponto',
      channelDescription: 'Canal para notificações de registro de ponto',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      showWhen: true,
    );

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        type == 'entrada' ? 0 : 1,
        'Alerta de Registro de Ponto de ${type == 'entrada' ? 'Entrada' : 'Saída'}',
        'Efetue o Registro. Mantenha seu ponto efetuado diariamente.',
        scheduledTime,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'Notificação de $type',
      );
      debugPrint(
          'Notificação diária agendada com sucesso para $type às $scheduledTime no fuso horário local');
    } catch (e) {
      debugPrint('Erro ao agendar notificação para $type: $e');
    }
  }
}
