import 'package:asd/screen/homeScreen.dart';
// import 'package:asd/screen/reportsScreen.dart';
import 'package:asd/screen/timer/timerScreen.dart';
import 'package:asd/screen/tracker/ActivityTrackerApp.dart';
import 'package:asd/screen/viewing/ScreenCapturePage.dart';
import 'package:flutter/material.dart'; // Импортируем наш новый экран

class BodyScreen extends StatelessWidget {
  final int selectedIndex;

  const BodyScreen({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (selectedIndex) {
      case 0: // Home
        return const TimerScreen(); // Заменяем на наш новый экран
      case 1: // Search
        return ActivityTrackerApp();
      case 2: // qwe
        return ScreenshotPage();
      case 3: // asd
        return _buildAsdScreen();
      case 4: // Settings
        return _buildSettingsScreen();
      default:
        return const TimerScreen(); // Заменяем на наш новый экран
      // Возвращаем HomeScreen по умолчанию
    }
  }

  // Остальные методы остаются без изменений
  Widget _buildSearchScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.white),
          SizedBox(height: 20),
          Text('Поиск', style: TextStyle(color: Colors.white, fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildQweScreen() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Экран QWE',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildAsdScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlutterLogo(size: 100),
          SizedBox(height: 20),
          Text(
            'Экран ASD',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 64, color: Colors.white),
          SizedBox(height: 20),
          Text(
            'Настройки',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ],
      ),
    );
  }
}
