import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/models.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  Future<void> scheduleAll(List<StudySlot> slots) async {
    await _plugin.cancelAll();

    // Slot start notifications
    for (final slot in slots) {
      if (slot.isBreak) {
        await _scheduleDaily(
          id: slot.id * 10,
          title: '☕ Break Time!',
          body: 'आराम करो! तुमने ${slot.hours} घंटे पढ़ा। Break लेना ज़रूरी है।',
          time: slot.startTime,
        );
      } else {
        await _scheduleDaily(
          id: slot.id * 10,
          title: '📚 ${slot.subject} शुरू करो!',
          body: '${slot.startTime} बज गए — ${slot.task}',
          time: slot.startTime,
        );
      }
    }

    // Morning motivation (6:00 AM)
    await _scheduleDaily(
      id: 900,
      title: '🌅 Good Morning, Warrior!',
      body: 'आज का दिन GATE AIR 100 की तरफ एक कदम है। उठो, पढ़ो, जीतो!',
      time: '06:00',
    );

    // Midnight warning (11:50 PM)
    await _scheduleDaily(
      id: 999,
      title: '🌙 Midnight Reset in 10 minutes',
      body: 'कल के लिए तैयार हो जाओ। आज का progress save हो रहा है।',
      time: '23:50',
    );
  }

  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required String time,
  }) async {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'gate_planner_channel',
      'GATE Planner',
      channelDescription: 'Daily study reminders',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFF00D4FF),
      icon: '@mipmap/ic_launcher',
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
