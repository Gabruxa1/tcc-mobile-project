import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class ConfiguracoesService {
  final SharedPreferences _prefs;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  ConfiguracoesService(this._prefs, this.flutterLocalNotificationsPlugin);

  Future<void> saveAlarmTimes(String entrada, String saida) async {
    await _prefs.setString('entrada', entrada);
    await _prefs.setString('saida', saida);
    await _scheduleNotification('entrada', entrada);
    await _scheduleNotification('saida', saida);
  }

  String getEntradaTime() {
    return _prefs.getString('entrada') ?? '';
  }

  String getSaidaTime() {
    return _prefs.getString('saida') ?? '';
  }

  Future<void> _scheduleNotification(String type, String time) async {
    if (time.isEmpty) return;

    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = DateTime.now();
    final scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

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
    );
  }
}
