import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class TimerProvider extends ChangeNotifier {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;

  final List<User> _users = [
    User("Chloe Katnice", Colors.blue),
    User("Kelly Anderson", Colors.green),
    User("Pamela Rule", Colors.orange),
    User("Loise Danbark", Colors.purple),
    User("Alyssa Drake", Colors.red),
    User("Tanya Rodney", Colors.teal),
  ];

  Duration get elapsedTime => _elapsedTime;
  bool get isRunning => _stopwatch.isRunning;
  List<User> get users => _users;

  void startTimer() {
    if (_stopwatch.isRunning) return;

    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedTime = _stopwatch.elapsed;
      for (var user in _users) {
        if (user.isActive) {
          user.timeOnline = _elapsedTime;
        }
      }
      notifyListeners();
    });
  }

  void pauseTimer() {
    _stopwatch.stop();
    _timer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }
}

class User {
  final String name;
  final Color color;
  Duration timeOnline = Duration.zero;
  bool isActive = true;

  User(this.name, this.color);

  String get formattedTime {
    return "${timeOnline.inHours}h ${timeOnline.inMinutes.remainder(60)}m";
  }

  double get progress {
    // Максимальное время для отображения (12 часов)
    const maxHours = 12;
    return timeOnline.inMinutes / (maxHours * 60);
  }
}

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    final timeStr =
        '${timerProvider.elapsedTime.inHours.toString().padLeft(2, '0')}:'
        '${timerProvider.elapsedTime.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
        '${timerProvider.elapsedTime.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Colors.black12,
      body: SafeArea(
        child: Column(
          children: [
            // Заголовок с временем
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                timeStr,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // Компактная таблица с полоской времени
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1.5),
                      2: FlexColumnWidth(3),
                      3: FlexColumnWidth(1),
                    },
                    border: TableBorder.all(
                      color: Colors.grey.shade700,
                      width: 1,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      // Заголовок таблицы
                      TableRow(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Time',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Progress',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.more_vert,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      // Строки пользователей
                      ...timerProvider.users
                          .map(
                            (user) => TableRow(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade800,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              children: [
                                // Имя с возможностью навигации
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                UserDetailScreen(user: user),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      user.name,
                                      style: TextStyle(
                                        color: user.color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                // Время работы
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    user.formattedTime,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                // Полоска прогресса
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade800,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          return Container(
                                            height: 20,
                                            width:
                                                constraints.maxWidth *
                                                user.progress,
                                            decoration: BoxDecoration(
                                              color: user.color.withOpacity(
                                                0.7,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          );
                                        },
                                      ),
                                      Positioned.fill(
                                        child: Center(
                                          child: Text(
                                            '${(user.progress * 100).toStringAsFixed(1)}%',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Кнопка действий
                                IconButton(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    size: 18,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => _buildUserActionsDialog(
                                            user,
                                            timerProvider,
                                          ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade800,
        onPressed: () {
          if (timerProvider.isRunning) {
            timerProvider.pauseTimer();
          } else {
            timerProvider.startTimer();
          }
        },
        child: Icon(
          timerProvider.isRunning ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildUserActionsDialog(User user, TimerProvider provider) {
    return AlertDialog(
      backgroundColor: Colors.grey.shade900,
      title: Text(user.name, style: TextStyle(color: user.color)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              user.isActive ? Icons.pause : Icons.play_arrow,
              color: Colors.white70,
            ),
            title: Text(
              user.isActive ? 'Pause tracking' : 'Resume tracking',
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              user.isActive = !user.isActive;
              // Navigator.pop(context);
              provider.notifyListeners();
            },
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.white70),
            title: const Text(
              'View details',
              style: TextStyle(color: Colors.white),
            ),
            // onTap: () {
            //   Navigator.pop(context);
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => UserDetailScreen(user: user),
            //     ),
            //   );
            // },
          ),
        ],
      ),
    );
  }
}

class UserDetailScreen extends StatelessWidget {
  final User user;

  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        title: Text(user.name),
        backgroundColor: Colors.black.withOpacity(0.5),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 80, color: user.color),
            const SizedBox(height: 20),
            Text(
              'Total time: ${user.formattedTime}',
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Container(
              width: 300,
              padding: const EdgeInsets.all(20),
              child: LinearProgressIndicator(
                value: user.progress,
                backgroundColor: Colors.grey.shade800,
                color: user.color,
                minHeight: 20,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: user.color.withOpacity(0.8),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Back', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TimerProvider(),
      child: MaterialApp(
        title: 'Time Tracker',
        theme: ThemeData.dark(),
        home: const TimerScreen(),
      ),
    ),
  );
}
