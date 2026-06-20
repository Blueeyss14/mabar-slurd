import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Pastikan variabel ini ada di dalam class
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'mabar_channel_id',
    'Mabar Notifications',
    importance: Importance.max,
    priority: Priority.high,
  );

  static const NotificationDetails _platformDetails = NotificationDetails(
    android: _androidDetails,
  );

  static Future<void> init() async {
    // Database zona waktu untuk penjadwalan notifikasi (zonedSchedule).
    tzdata.initializeTimeZones();

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

  /// Notifikasi instan. ID unik (berbasis waktu) supaya notifikasi tidak saling
  /// menimpa dan tidak bentrok dengan ID reminder terjadwal.
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.remainder(1 << 30);
    await _notificationsPlugin.show(id, title, body, _platformDetails);
  }

  /// ID reminder yang stabil dari bookingId, agar bisa dijadwalkan ulang /
  /// dibatalkan saat booking di-reschedule atau dibatalkan.
  static int _reminderId(String bookingId) => bookingId.hashCode & 0x3fffffff;

  /// Jadwalkan pengingat 1 jam sebelum sesi mulai.
  ///
  /// Waktu absolut dihitung lewat [DateTime.toUtc] lalu dibungkus sebagai
  /// TZDateTime UTC, sehingga notifikasi berbunyi pada jam dinding lokal yang
  /// benar tanpa perlu tahu nama zona waktu perangkat.
  static Future<void> scheduleBookingReminder({
    required String bookingId,
    required String venueName,
    required DateTime startTime,
  }) async {
    final remindAt = startTime.subtract(const Duration(hours: 1));
    // Jangan jadwalkan untuk waktu yang sudah lewat.
    if (!remindAt.isAfter(DateTime.now())) return;

    final utc = remindAt.toUtc();
    final scheduled = tz.TZDateTime.utc(
      utc.year,
      utc.month,
      utc.day,
      utc.hour,
      utc.minute,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        _reminderId(bookingId),
        'Booking sebentar lagi',
        '$venueName — sesi kamu mulai 1 jam lagi. Siap-siap mabar!',
        scheduled,
        _platformDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // Penjadwalan gagal (mis. izin alarm) tidak boleh menggagalkan booking.
    }
  }

  /// Batalkan reminder terjadwal untuk sebuah booking (saat dibatalkan).
  static Future<void> cancelReminder(String bookingId) async {
    try {
      await _notificationsPlugin.cancel(_reminderId(bookingId));
    } catch (_) {}
  }
}
