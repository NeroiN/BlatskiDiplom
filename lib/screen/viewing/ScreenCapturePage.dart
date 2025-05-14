import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart' as path;

class ScreenshotPage extends StatefulWidget {
  const ScreenshotPage({super.key});

  @override
  State<ScreenshotPage> createState() => _ScreenshotPageState();
}

class _ScreenshotPageState extends State<ScreenshotPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final String screenshotPath = '/home/neroin/Изображения/Снимки экрана/';
  List<FileSystemEntity> screenshots = [];
  bool isLoadingScreenshots = false;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _createScreenshotDirectory();
    _loadScreenshots();
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
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          linux: initializationSettingsLinux,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          _openFile(response.payload!);
        }
      },
    );
  }

  Future<void> _showNotification(
    String title,
    String body, {
    String? filePath,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'screenshot_channel',
          'Screenshot Notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        );

    const LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails(
          actions: <LinuxNotificationAction>[
            LinuxNotificationAction(key: 'open', label: 'Open'),
          ],
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      linux: linuxPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: filePath,
    );
  }

  Future<void> _loadScreenshots() async {
    setState(() {
      isLoadingScreenshots = true;
    });

    try {
      final directory = Directory(screenshotPath);
      if (await directory.exists()) {
        final files = await directory.list().toList();
        files.sort(
          (a, b) => b.path.compareTo(a.path),
        ); // Сортировка по новым сначала

        setState(() {
          screenshots =
              files.where((file) {
                final ext = path.extension(file.path).toLowerCase();
                return ext == '.png' || ext == '.jpg' || ext == '.jpeg';
              }).toList();
        });
      }
    } catch (e) {
      debugPrint('Ошибка при загрузке скриншотов: $e');
    } finally {
      setState(() {
        isLoadingScreenshots = false;
      });
    }
  }

  Future<void> _takeScreenshot() async {
    try {
      final directory = Directory(screenshotPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(
        RegExp(r'[^0-9]'),
        '_',
      );
      final filePath = '${screenshotPath}screenshot_$timestamp.png';

      ProcessResult result;

      if (await _isCommandAvailable('gnome-screenshot')) {
        result = await Process.run('gnome-screenshot', ['-f', filePath]);
      } else if (await _isCommandAvailable('flameshot')) {
        result = await Process.run('flameshot', ['full', '-p', filePath]);
      } else if (await _isCommandAvailable('scrot')) {
        result = await Process.run('scrot', [filePath]);
      } else {
        throw Exception(
          'No screenshot tool found. Install gnome-screenshot, flameshot or scrot.',
        );
      }

      if (result.exitCode != 0) {
        throw Exception('Failed to take screenshot: ${result.stderr}');
      }

      await _loadScreenshots();
      await _showNotification(
        'Скриншот сохранён',
        'Файл: ${path.basename(filePath)}',
        filePath: filePath,
      );
    } catch (e) {
      await _showNotification('Ошибка', e.toString());
    }
  }

  Future<void> _openFile(String filePath) async {
    try {
      await Process.run('xdg-open', [filePath]);
    } catch (e) {
      await _showNotification('Ошибка', 'Не удалось открыть файл: $e');
    }
  }

  Future<void> _openScreenshotFolder() async {
    try {
      await Process.run('xdg-open', [screenshotPath]);
    } catch (e) {
      await _showNotification('Ошибка', 'Не удалось открыть папку: $e');
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
      appBar: AppBar(
        title: const Text('Скриншоттер для Linux'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder),
            onPressed: _openScreenshotFolder,
            tooltip: 'Открыть папку со скриншотами',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadScreenshots,
            tooltip: 'Обновить список скриншотов',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                isLoadingScreenshots
                    ? const Center(child: CircularProgressIndicator())
                    : screenshots.isEmpty
                    ? const Center(
                      child: Text(
                        'Нет сохранённых скриншотов',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                    : ListView.builder(
                      itemCount: screenshots.length,
                      itemBuilder: (context, index) {
                        final file = screenshots[index];
                        final fileName = path.basename(file.path);
                        final fileDate = File(file.path).lastModifiedSync();

                        return ListTile(
                          leading: const Icon(Icons.image, size: 40),
                          title: Text(fileName),
                          subtitle: Text(
                            '${fileDate.day}.${fileDate.month}.${fileDate.year} '
                            '${fileDate.hour}:${fileDate.minute.toString().padLeft(2, '0')}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.open_in_new),
                            onPressed: () => _openFile(file.path),
                          ),
                          onTap: () => _openFile(file.path),
                        );
                      },
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _takeScreenshot,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Сделать скриншот'),
            ),
          ),
        ],
      ),
    );
  }
}
