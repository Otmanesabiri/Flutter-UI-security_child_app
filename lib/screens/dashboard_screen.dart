import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  final List<Map<String, dynamic>> alerts;
  final bool systemActive;
  final Set<String> monitoredObjects;

  const DashboardScreen({
    Key? key,
    required this.alerts,
    required this.systemActive,
    required this.monitoredObjects,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(context),
            const SizedBox(height: 16),
            _buildStatisticsGrid(context),
            const SizedBox(height: 16),
            _buildRecentAlertsCard(context),
            const SizedBox(height: 16),
            _buildWeeklyChart(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: systemActive ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Status',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    systemActive ? 'Active - Monitoring' : 'Inactive',
                    style: TextStyle(
                      color: systemActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              systemActive ? Icons.shield : Icons.shield_outlined,
              size: 40,
              color: systemActive ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid(BuildContext context) {
    // Calculate statistics
    final todayAlerts = _getAlertsForToday().length;
    final highRiskAlerts =
        alerts.where((a) => (a['confidence'] ?? 0.0) > 0.7).length;

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildStatCard(context, 'Total Alerts', '${alerts.length}',
            Icons.warning_amber, Colors.orange),
        _buildStatCard(context, 'Today\'s Alerts', '$todayAlerts', Icons.today,
            Colors.blue),
        _buildStatCard(context, 'High Risk Alerts', '$highRiskAlerts',
            Icons.priority_high, Colors.red),
        _buildStatCard(context, 'Objects Monitored',
            '${monitoredObjects.length}', Icons.remove_red_eye, Colors.green),
      ],
    );
  }

  List<Map<String, dynamic>> _getAlertsForToday() {
    final today = DateTime.now();
    return alerts.where((alert) {
      final timestamp = alert['timestamp'] as String?;
      if (timestamp == null) return false;

      final alertDate = DateTime.tryParse(timestamp);
      if (alertDate == null) return false;

      return alertDate.year == today.year &&
          alertDate.month == today.month &&
          alertDate.day == today.day;
    }).toList();
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAlertsCard(BuildContext context) {
    final recentAlerts = alerts.isEmpty
        ? []
        : alerts.length > 3
            ? alerts.sublist(0, 3)
            : alerts;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Alerts',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full alerts tab
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    // Should navigate to alerts tab
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const Divider(),
            recentAlerts.isEmpty
                ? const SizedBox(
                    height: 100,
                    child: Center(child: Text('No recent alerts')),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentAlerts.length,
                    itemBuilder: (context, index) {
                      final alert = recentAlerts[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.shade100,
                          child: const Icon(Icons.warning, color: Colors.red),
                        ),
                        title: Text(alert['object'] ?? 'Unknown'),
                        subtitle: Text(alert['timestamp'] ?? ''),
                        trailing: Text(
                          '${(alert['confidence'] ?? 0.0).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context) {
    // Prepare weekly data
    final Map<String, int> alertsByDay = _getWeeklyAlertCounts();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Alert Trend',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: const BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(value.toInt().toString()), // Add the required meta parameter
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value >= alertsByDay.length) {
                            return const Text('');
                          }
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              alertsByDay.keys.elementAt(value.toInt()),
                              style: const TextStyle(fontSize: 10),
                            ), // Add the required meta parameter
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: alertsByDay.entries.map((entry) {
                    final index = alertsByDay.keys.toList().indexOf(entry.key);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: Colors.red.shade700,
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: alertsByDay.values.isEmpty
                                ? 5
                                : (alertsByDay.values
                                            .reduce((a, b) => a > b ? a : b) +
                                        1)
                                    .toDouble(),
                            color: Colors.grey.shade200,
                          ),
                        )
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, int> _getWeeklyAlertCounts() {
    final Map<String, int> alertsByDay = {};
    final now = DateTime.now();

    // Initialize last 7 days
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('E').format(date); // Day abbreviation
      alertsByDay[dateStr] = 0;
    }

    // Count alerts by day
    for (final alert in alerts) {
      final timestamp = alert['timestamp'] as String?;
      if (timestamp == null) continue;

      final date = DateTime.tryParse(timestamp);
      if (date == null) continue;

      // Only include alerts from last 7 days
      final difference = now.difference(date).inDays;
      if (difference <= 6) {
        final dateStr = DateFormat('E').format(date);
        alertsByDay[dateStr] = (alertsByDay[dateStr] ?? 0) + 1;
      }
    }

    return alertsByDay;
  }
}
