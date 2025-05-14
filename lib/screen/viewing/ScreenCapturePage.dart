import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(const ScreenshotApp());
}

class ScreenshotApp extends StatelessWidget {
  const ScreenshotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linux Screenshot Tool',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ScreenshotPage(),
    );
  }
}

class ScreenshotPage extends StatefulWidget {
  const ScreenshotPage({super.key});

  @override
  State<ScreenshotPage> createState() => _ScreenshotPageState();
}

class _ScreenshotPageState extends State<ScreenshotPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Путь для сохранения скриншотов
  final String screenshotPath = '/home/neroin/Изображения/Снимки экрана/';

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _createScreenshotDirectory();
  }

  Future<void> _createScreenshotDirectory() async {
    try {
      final directory = Directory(screenshotPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
    } catch (e) {
      debugPrint('Ошибка при создании директории: $e');
    }
  }

  Future<void> _initNotifications() async {
    // Настройки для Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Настройки для Linux
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    // Общие настройки инициализации
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          linux: initializationSettingsLinux,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Обработка нажатия на уведомление
        debugPrint('Notification clicked: ${response.payload}');
      },
    );
  }

  Future<void> _showNotification(String title, String body) async {
    // Настройки для Android
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'screenshot_channel',
          'Screenshot Notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        );

    // Настройки для Linux
    const LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails(
          actions: <LinuxNotificationAction>[
            LinuxNotificationAction(key: 'open', label: 'Open'),
          ],
        );

    // Общие настройки уведомления
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      linux: linuxPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> _takeScreenshot() async {
    try {
      // Проверяем существование директории
      final directory = Directory(screenshotPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(
        RegExp(r'[^0-9]'),
        '_',
      );
      final filePath = '${screenshotPath}screenshot_$timestamp.png';

      // Вызываем системную утилиту для создания скриншота
      ProcessResult result;

      if (await _isCommandAvailable('gnome-screenshot')) {
        result = await Process.run('gnome-screenshot', ['-f', filePath]);
      } else if (await _isCommandAvailable('flameshot')) {
        result = await Process.run('flameshot', ['full', '-p', filePath]);
      } else if (await _isCommandAvailable('scrot')) {
        result = await Process.run('scrot', [filePath]);
      } else {
        throw Exception(
          'Не найдена утилита для скриншотов. Установите gnome-screenshot, flameshot или scrot.',
        );
      }

      if (result.exitCode != 0) {
        throw Exception('Ошибка при создании скриншота: ${result.stderr}');
      }

      await _showNotification('Скриншот сохранён', 'Файл: $filePath');
    } catch (e) {
      await _showNotification('Ошибка', e.toString());
    }
  }

  Future<bool> _isCommandAvailable(String command) async {
    try {
      final result = await Process.run('which', [command]);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Скриншоттер для Linux')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Нажмите кнопку ниже, чтобы сделать скриншот',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              'Скриншоты сохраняются в:\n$screenshotPath',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _takeScreenshot,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: const Text('Сделать скриншот'),
            ),
          ],
        ),
      ),
    );
  }
}
