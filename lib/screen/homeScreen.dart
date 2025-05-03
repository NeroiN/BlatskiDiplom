import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<User> users = [
    User(
      name: 'Chloe Katnice pro 1.4.75.14',
      timeWorked: '11h 11m',
      workPeriods: [WorkPeriod(start: 2, end: 12)],
    ),
    User(
      name: 'Kelly Anderson Time doctor Pro 1.4.76.1',
      timeWorked: '9h 19m',
      workPeriods: [
        WorkPeriod(start: 4, end: 10),
        WorkPeriod(start: 12, end: 15),
      ],
    ),
    User(
      name: 'Pamela Rule Time Doctor lite 2.3.50.1',
      timeWorked: '9h 14m',
      workPeriods: [
        WorkPeriod(start: 6, end: 12),
        WorkPeriod(start: 14, end: 17),
      ],
    ),
    User(
      name: 'Loise Danbark Dev build 19.08',
      timeWorked: '8h 31m',
      workPeriods: [WorkPeriod(start: 8, end: 16)],
    ),
    User(
      name: 'Alyssa Drake Tracking on Live Build 19.8',
      timeWorked: '0h 0m',
      workPeriods: [],
    ),
    User(
      name: 'Tanya Rodney Ubuntu 17.10 Pro 1.5.20',
      timeWorked: '0h 0m',
      workPeriods: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final lightGrey = Colors.grey[300];
    final darkGrey = Colors.grey[700];

    return Scaffold(
      backgroundColor: Colors.black12,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(lightGrey),
            const SizedBox(height: 20),
            _buildUserTable(context, lightGrey),
            const SizedBox(height: 20),
            _buildFooterSection(lightGrey),
            const SizedBox(height: 20),
            _buildDateSection(lightGrey),
            const SizedBox(height: 20),
            _buildTimeTypeSection(lightGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(Color? textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Support On-Boarding',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: textColor),
              onPressed: () {},
              child: const Text('Invite new user'),
            ),
            const SizedBox(width: 10),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: textColor),
              onPressed: () {},
              child: const Text('Invite'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserTable(BuildContext context, Color? textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All 6 Users Selected',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.grey[600], // Установка цвета разделителя
              dataTableTheme: DataTableThemeData(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                headingTextStyle: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
                dataTextStyle: TextStyle(color: textColor),
              ),
            ),
            child: DataTable(
              columnSpacing: 20,
              headingRowHeight: 40,
              dataRowHeight: 60,
              columns: [
                for (final header in [
                  'Names',
                  'Time Worked',
                  '2 AM',
                  '4 AM',
                  '6 AM',
                  '8 AM',
                  '10 AM',
                  '12 PM',
                  '2 PM',
                  '4 PM',
                  '6 PM',
                  '8 PM',
                  '10 PM',
                ])
                  DataColumn(
                    label: Text(header, style: TextStyle(color: textColor)),
                  ),
              ],
              rows:
                  users.map((user) => _buildUserRow(user, textColor)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  DataRow _buildUserRow(User user, Color? textColor) {
    return DataRow(
      cells: [
        DataCell(
          InkWell(
            onTap: () => _navigateToProfile(user),
            child: Text(
              user.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[200],
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        DataCell(Text(user.timeWorked, style: TextStyle(color: textColor))),
        for (int hour = 2; hour <= 22; hour += 2)
          DataCell(_buildTimeIndicator(user, hour)),
      ],
    );
  }

  Widget _buildTimeIndicator(User user, int hour) {
    final isWorking = user.workPeriods.any(
      (p) => hour >= p.start && hour < p.end,
    );
    return Container(
      height: 20,
      width: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isWorking ? Colors.greenAccent[400] : Colors.transparent,
      ),
    );
  }

  void _navigateToProfile(User user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Переход на профиль ${user.name}'),
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  Widget _buildFooterSection(Color? textColor) {
    return Text(
      'Current time: 1:11 PM, Apr 25, 2018 (GMT+08:00) Manila, Hong K...',
      style: TextStyle(color: textColor),
    );
  }

  Widget _buildDateSection(Color? textColor) {
    return Text(
      'Tue, Apr 24, 2018',
      style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
    );
  }

  Widget _buildTimeTypeSection(Color? textColor) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildTimeTypeChip('Computer Work Time', textColor),
        _buildTimeTypeChip('Mobile Work Time', textColor),
        _buildTimeTypeChip('Edited Time', textColor),
      ],
    );
  }

  Widget _buildTimeTypeChip(String text, Color? textColor) {
    return Chip(
      label: Text(text, style: TextStyle(color: textColor)),
      backgroundColor: Colors.grey[800],
    );
  }
}

class User {
  final String name;
  final String timeWorked;
  final List<WorkPeriod> workPeriods;

  User({
    required this.name,
    required this.timeWorked,
    required this.workPeriods,
  });
}

class WorkPeriod {
  final int start;
  final int end;

  WorkPeriod({required this.start, required this.end});
}
