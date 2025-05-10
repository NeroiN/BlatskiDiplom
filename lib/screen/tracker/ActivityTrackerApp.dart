import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';
import 'package:process_run/process_run.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  runApp(ActivityTrackerApp());
}

class ActivityTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Activity Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ActivityTrackerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ActivityTrackerScreen extends StatefulWidget {
  @override
  _ActivityTrackerScreenState createState() => _ActivityTrackerScreenState();
}

class _ActivityTrackerScreenState extends State<ActivityTrackerScreen> {
  List<AppActivity> allApps = [];
  List<AppActivity> activeApps = [];
  String currentActiveApp = '';
  Timer? trackingTimer;
  Timer? fullScanTimer;

  @override
  void initState() {
    super.initState();
    _startTracking();
    _startFullScan();
  }

  @override
  void dispose() {
    trackingTimer?.cancel();
    fullScanTimer?.cancel();
    super.dispose();
  }

  void _startTracking() {
    trackingTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      await _updateActiveApp();
    });
  }

  void _startFullScan() {
    fullScanTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await _scanAllOpenApps();
    });
  }

  Future<void> _updateActiveApp() async {
    try {
      String appName = await _getActiveAppName();
      String appUrl = await _getActiveTabUrl();

      setState(() {
        currentActiveApp = appName;
        _updateAppDuration(appName, appUrl);
        activeApps = allApps.where((app) => app.isActive).toList();
      });
    } catch (e) {
      print('Error updating active app: $e');
    }
  }

  Future<void> _scanAllOpenApps() async {
    try {
      List<String> openApps = await _getAllOpenApps();
      DateTime now = DateTime.now();

      setState(() {
        for (String app in openApps) {
          if (!allApps.any((a) => a.appName == app)) {
            allApps.add(
              AppActivity(
                appName: app,
                firstSeen: now,
                lastActive: now,
                duration: Duration.zero,
                isActive: false,
                category: _detectAppCategory(app),
              ),
            );
          }
        }

        for (var app in allApps) {
          app.isActive = openApps.contains(app.appName);
          if (app.isActive && app.appName == currentActiveApp) {
            app.lastActive = now;
            app.duration += Duration(seconds: 1);
          }
        }
      });
    } catch (e) {
      print('Error scanning open apps: $e');
    }
  }

  void _updateAppDuration(String appName, String url) {
    final appIndex = allApps.indexWhere((app) => app.appName == appName);
    if (appIndex != -1) {
      final now = DateTime.now();
      setState(() {
        allApps[appIndex].lastActive = now;
        allApps[appIndex].duration += Duration(seconds: 1);
        if (url.isNotEmpty) {
          allApps[appIndex].url = url;
        }
        allApps[appIndex].isActive = true;
      });
    } else {
      setState(() {
        allApps.add(
          AppActivity(
            appName: appName,
            firstSeen: DateTime.now(),
            lastActive: DateTime.now(),
            duration: Duration(seconds: 1),
            isActive: true,
            url: url,
            category: _detectAppCategory(appName),
          ),
        );
      });
    }
  }

  Future<String> _getActiveAppName() async {
    try {
      if (Platform.isWindows) {
        var result = await run('powershell', [
          '(Get-Process | Where-Object { \$_.MainWindowTitle -ne \"\" } | Sort-Object WS -Descending | Select-Object -First 1).MainWindowTitle',
        ]);
        return result.stdout.toString().trim();
      } else if (Platform.isMacOS) {
        var result = await run('osascript', [
          '-e',
          'tell application "System Events" to get name of first application process whose frontmost is true',
        ]);
        return result.stdout.toString().trim();
      } else if (Platform.isLinux) {
        var result = await run('xdotool', ['getwindowfocus', 'getwindowname']);
        return result.stdout.toString().trim();
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<List<String>> _getAllOpenApps() async {
    try {
      if (Platform.isWindows) {
        var result = await run('powershell', [
          'Get-Process | Where-Object { \$_.MainWindowTitle -ne \"\" } | Select-Object -ExpandProperty Name',
        ]);
        return result.stdout
            .toString()
            .split('\n')
            .where((name) => name.trim().isNotEmpty)
            .toList();
      } else if (Platform.isMacOS) {
        var result = await run('osascript', [
          '-e',
          'tell application "System Events" to get name of every application process',
        ]);
        return result.stdout
            .toString()
            .split(',')
            .map((s) => s.trim())
            .where((name) => name.isNotEmpty)
            .toList();
      } else if (Platform.isLinux) {
        var result = await run('ps', ['-e', '--no-header', '-o', 'comm']);
        return result.stdout
            .toString()
            .split('\n')
            .where((name) => name.trim().isNotEmpty)
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<String> _getActiveTabUrl() async {
    try {
      if (Platform.isWindows) {
        var result = await run('powershell', [
          r'''
          \$url = "";
          \$browsers = @("chrome","firefox","edge","opera","brave");
          foreach (\$browser in \$browsers) {
            \$process = Get-Process \$browser -ErrorAction SilentlyContinue;
            if (\$process) {
              \$url = (Get-Process \$browser).MainWindowTitle;
              if (\$url -match "http") { break; }
            }
          }
          \$url
          ''',
        ]);
        return result.stdout.toString().trim();
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  String _detectAppCategory(String appName) {
    appName = appName.toLowerCase();
    if (appName.contains('chrome') ||
        appName.contains('firefox') ||
        appName.contains('edge') ||
        appName.contains('safari')) {
      return 'Browser';
    } else if (appName.contains('word') ||
        appName.contains('excel') ||
        appName.contains('powerpoint')) {
      return 'Office';
    } else if (appName.contains('visual studio') ||
        appName.contains('android studio') ||
        appName.contains('vscode')) {
      return 'Development';
    } else if (appName.contains('spotify') ||
        appName.contains('vlc') ||
        appName.contains('media player')) {
      return 'Media';
    }
    return 'Other';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Advanced Activity Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                allApps.clear();
                activeApps.clear();
                _scanAllOpenApps();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              children: [
                Icon(Icons.timer, color: Colors.blue),
                SizedBox(width: 10),
                Text(
                  'Current: $currentActiveApp',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  tabs: [
                    Tab(text: 'All Applications (${allApps.length})'),
                    Tab(text: 'Active Now (${activeApps.length})'),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: TabBarView(
                    children: [
                      _buildAppsTable(allApps),
                      _buildAppsTable(activeApps),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppsTable(List<AppActivity> apps) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Application')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Duration'), numeric: true),
          DataColumn(label: Text('Last Active')),
          DataColumn(label: Text('URL/Details')),
        ],
        rows:
            apps.map((app) {
              return DataRow(
                color: MaterialStateProperty.resolveWith<Color?>((
                  Set<MaterialState> states,
                ) {
                  if (app.isActive) return Colors.blue[50];
                  return null;
                }),
                cells: [
                  DataCell(Text(app.appName)),
                  DataCell(
                    Chip(
                      label: Text(app.category),
                      backgroundColor: _getCategoryColor(app.category),
                    ),
                  ),
                  DataCell(Text(_formatDuration(app.duration))),
                  DataCell(Text('${_timeAgo(app.lastActive)}')),
                  DataCell(
                    Text(
                      app.url ?? app.appName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Browser':
        return Colors.green[100]!;
      case 'Office':
        return Colors.blue[100]!;
      case 'Development':
        return Colors.purple[100]!;
      case 'Media':
        return Colors.orange[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}

class AppActivity {
  final String appName;
  final DateTime firstSeen;
  DateTime lastActive;
  Duration duration;
  bool isActive;
  final String category;
  String? url;

  AppActivity({
    required this.appName,
    required this.firstSeen,
    required this.lastActive,
    required this.duration,
    required this.isActive,
    required this.category,
    this.url,
  });
}
