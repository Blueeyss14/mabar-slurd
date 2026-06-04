import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Pastikan variabel ini ada di dalam class
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Pastikan pakai 'const' dan tipe datanya benar
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Kalau ini merah, berarti flutter_local_notifications belum ke-install bener
    await _notificationsPlugin.initialize(initializationSettings);

    await _notificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
  }

  static Future<void> showNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'mabar_channel_id',
      'Mabar Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      0, // ID notifikasi
      title,
      body,
      platformDetails,
    );
  }
}