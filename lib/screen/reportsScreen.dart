import 'package:flutter/material.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final List<UsageItem> usageItems = [
    UsageItem(name: 'secondtime.timedoctor.com', time: '39m', percentage: 0.65),
    UsageItem(name: 'Time Doctor', time: '9m', percentage: 0.15),
    UsageItem(name: 'login.timedoctor.com', time: '4m', percentage: 0.07),
    UsageItem(name: 'facebook.com', time: '3m', percentage: 0.05),
    UsageItem(name: 'TeamViewer', time: '3m', percentage: 0.05),
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
            _buildUserInfoSection(lightGrey),
            const SizedBox(height: 20),
            _buildExportOptionsSection(lightGrey),
            const SizedBox(height: 20),
            _buildFilterSection(lightGrey),
            const SizedBox(height: 20),
            _buildUsageListSection(context, lightGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(Color? textColor) {
    return Text(
      'Web & App Usage',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  Widget _buildUserInfoSection(Color? textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chloe Katnice (Myself)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text('Poor time use', style: TextStyle(color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildExportOptionsSection(Color? textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Export Options', style: TextStyle(color: Colors.grey[500])),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildFilterChip('Wed_Apr 25,2018', textColor),
            _buildFilterChip('Day', textColor),
            _buildFilterChip('Week', textColor),
            _buildFilterChip('Date Range', textColor),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, Color? textColor) {
    return Chip(
      label: Text(label, style: TextStyle(color: textColor)),
      backgroundColor: Colors.grey[800],
    );
  }

  Widget _buildFilterSection(Color? textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton(
          onPressed: () {},
          child: Text('All', style: TextStyle(color: textColor)),
        ),
        VerticalDivider(color: Colors.grey[600], width: 1),
        TextButton(
          onPressed: () {},
          child: Text('Websites', style: TextStyle(color: textColor)),
        ),
        VerticalDivider(color: Colors.grey[600], width: 1),
        TextButton(
          onPressed: () {},
          child: Text('Applications', style: TextStyle(color: textColor)),
        ),
      ],
    );
  }

  Widget _buildUsageListSection(BuildContext context, Color? textColor) {
    final totalTime = usageItems.fold<double>(
      0,
      (sum, item) => sum + item.percentage,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search websites or apps',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: TextStyle(color: textColor),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Websites', style: TextStyle(color: textColor)),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Applications',
                        style: TextStyle(color: Colors.blue[200]),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.grey),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Time', style: TextStyle(color: textColor)),
                    Text(
                      _formatTotalTime(totalTime),
                      style: TextStyle(color: textColor),
                    ),
                  ],
                ),
              ),
              ...usageItems
                  .map(
                    (item) => Column(
                      children: [
                        const Divider(height: 1, color: Colors.grey),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(color: textColor),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      height: 4,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(2),
                                        color: Colors.grey[800],
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor:
                                            item.percentage / totalTime,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                            color: Colors.greenAccent[400],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                item.time,
                                style: TextStyle(color: textColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTotalTime(double totalPercentage) {
    final totalMinutes = (totalPercentage * 60).round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}

class UsageItem {
  final String name;
  final String time;
  final double percentage;

  UsageItem({required this.name, required this.time, required this.percentage});
}
