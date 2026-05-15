import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  /// Inisialisasi AwesomeNotifications dengan channel 'basic_channel'.
  /// Dipanggil sekali saat aplikasi pertama kali dijalankan (di main()).
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // null = gunakan icon default aplikasi
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50BB),
          ledColor: Colors.white,
        ),
      ],
      debug: true,
    );
  }

  /// Meminta izin notifikasi dari user jika belum diberikan.
  static Future<void> requestPermission() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  /// Menjadwalkan daily reminder berdasarkan waktu check-in pengguna.
  ///
  /// [checkinTime] diambil dari field `daily_checkin_time` pada endpoint
  /// `/users/me`, dalam format **"HH:mm"** (contoh: `"09:00"`).
  /// Jika [checkinTime] null atau tidak valid, fallback ke **09:15**.
  ///
  /// Notifikasi lama (id=12) akan di-cancel terlebih dahulu agar waktu
  /// selalu sinkron jika pengguna mengubah preferensi check-in-nya.
  static Future<void> scheduleDailyNotification({
    String? checkinTime,
  }) async {
    // Parsing "HH:mm" → hour & minute, dengan fallback 09:15
    int hour = 9;
    int minute = 15;

    if (checkinTime != null && checkinTime.contains(':')) {
      final parts = checkinTime.split(':');
      if (parts.length >= 2) {
        hour = int.tryParse(parts[0]) ?? 9;
        minute = int.tryParse(parts[1]) ?? 15;
      }
    }

    // Cancel notifikasi lama agar tidak stale jika waktu berubah
    await AwesomeNotifications().cancel(12);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 12,
        channelKey: 'basic_channel',
        title: 'Daily Reminder 🌟',
        body: 'Time to log your daily progress!',
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        repeats: true,
      ),
    );

    debugPrint(
      '[NotificationService] Daily reminder dijadwalkan pukul '
      '$hour:${minute.toString().padLeft(2, '0')}.',
    );
  }

  /// Mengirim notifikasi **instan** (tanpa jadwal) untuk keperluan testing.
  /// Notifikasi ini akan muncul langsung dalam hitungan detik.
  static Future<void> triggerTestNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 99,
        channelKey: 'basic_channel',
        title: '🔔 Test Notification',
        body: 'Notifikasi berfungsi dengan baik! ✅',
        notificationLayout: NotificationLayout.Default,
      ),
    );
    debugPrint('[NotificationService] Test notification dikirim.');
  }

  /// Membatalkan semua notifikasi yang terdaftar.
  static Future<void> cancelAll() async {
    await AwesomeNotifications().cancelAll();
    debugPrint('[NotificationService] Semua notifikasi dibatalkan.');
  }
}
