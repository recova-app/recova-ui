📄 Product Requirements Document (PRD): Daily Reminder Notification
1. Objective (Tujuan)
Mengimplementasikan sistem notifikasi lokal terjadwal (daily reminder) pada aplikasi Flutter untuk mengingatkan pengguna agar melakukan aktivitas harian (misal: log daily progress). Notifikasi ini harus muncul setiap hari pada waktu yang telah ditentukan (contoh: pukul 09:15 pagi), meskipun aplikasi dalam keadaan tertutup atau berjalan di background.

2. Tech Stack & Dependencies
Framework: Flutter

Package: awesome_notifications (versi ^0.9.3 atau terbaru)

3. Scope of Work (Cakupan Kerja)
Instalasi dan konfigurasi package.

Inisialisasi Notification Channel pada OS level (khususnya Android).

Penanganan Permission untuk memastikan pengguna mengizinkan aplikasi mengirim notifikasi.

Pembuatan fungsi penjadwalan (scheduling) notifikasi harian.

4. Step-by-Step Implementation Guide
Step 1: Instalasi Package
Tambahkan dependensi awesome_notifications ke dalam project.

Action:
Buka file pubspec.yaml dan tambahkan kode berikut di bawah dependencies:

YAML
dependencies:
  awesome_notifications: ^0.9.3 
Jalankan flutter pub get setelah menyimpan file.

Step 2: Inisialisasi Notification Channel
Sistem operasi (terutama Android 8.0+) mewajibkan notifikasi untuk memiliki Channel. Inisialisasi ini harus dilakukan sesegera mungkin saat aplikasi berjalan.

Action:
Buka file main.dart dan inisialisasi plugin di dalam main() sebelum runApp().

Dart
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

void main() {
  AwesomeNotifications().initialize(
    null, // Gunakan null untuk memakai icon aplikasi bawaan, atau ganti dengan resource path icon
    [
      NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50BB),
          ledColor: Colors.white)
    ],
    debug: true // Set ke false saat build production
  );
  runApp(const MyApp());
}
Step 3: Request Permission (Izin Notifikasi)
Pada OS modern (Android 13+ & iOS), aplikasi harus meminta izin secara eksplisit kepada pengguna sebelum bisa menampilkan notifikasi.

Action:
Tambahkan logika pengecekan dan permintaan izin di halaman utama aplikasi (misalnya pada initState di HomeScreen).

Dart
@override
void initState() {
  super.initState();
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      // Akan membuka dialog/sistem setting agar user memberikan izin
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });
}
Step 4: Setup Scheduling Logic (Fungsi Daily Reminder)
Buat fungsi yang menangani pembuatan dan penjadwalan notifikasi. Notifikasi ini menggunakan NotificationCalendar agar berulang secara otomatis setiap hari.

Action:
Buat method di dalam service atau controller terkait, lalu panggil method ini saat user berhasil login atau saat aplikasi pertama kali disiapkan.

Dart
void scheduleDailyNotification() {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 12, // ID unik untuk notifikasi ini
      channelKey: 'basic_channel',
      title: 'Daily Reminder',
      body: 'Time to log your daily progress!',
    ),
    schedule: NotificationCalendar(
      hour: 9,        // Jam 09 pagi
      minute: 15,     // Menit ke-15
      second: 0,
      repeats: true,  // Trigger berulang setiap hari pada 09:15 AM
    ),
  );
}
5. Acceptance Criteria (Kriteria Selesai)
[ ] Package berhasil diinstal tanpa konflik dependensi.

[ ] Aplikasi meminta izin notifikasi (prompt permission) saat pertama kali dibuka oleh pengguna baru.

[ ] Notifikasi muncul tepat pada waktu yang dijadwalkan (09:15).

[ ] Notifikasi tetap muncul keesokan harinya (fungsi repeats: true berjalan normal).

[ ] Ketika notifikasi di-klik, pengguna diarahkan ke dalam aplikasi dengan aman tanpa crash.