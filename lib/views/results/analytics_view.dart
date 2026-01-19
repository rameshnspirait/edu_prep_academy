import 'package:edu_prep_academy/controllers/results_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsPage extends GetView<ResultsController> {
  final String testId;
  const AnalyticsPage({super.key, required this.testId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Test Analytics"),
        centerTitle: true,
        elevation: 8,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return Center(child: Text(controller.error.value));
        }

        // Find the result for the given testId
        Map<String, dynamic>? data;
        controller.results.forEach((category, tests) {
          for (final test in tests) {
            if (test['testId'] == testId) {
              data = test;
            }
          }
        });

        if (data == null) {
          return const Center(child: Text("No data found for this test"));
        }

        final int obtained = (data!['obtainedMarks'] ?? 0).toInt();
        final int totalMarks = (data!['totalMarks'] ?? 1).toInt();
        final int totalQuestions = (data!['totalQuestions'] ?? 1).toInt();
        final int correct = (data!['correctAnswered'] ?? 0).toInt();
        final int rank = (data!['rank'] ?? 0).toInt();
        final int totalStudents = (data!['totalStudents'] ?? 1).toInt();
        final double percentile = (data!['percentile'] ?? 0).toDouble();

        final double scorePercent = totalMarks == 0 ? 0 : obtained / totalMarks;
        final double accuracyPercent = totalQuestions == 0
            ? 0
            : correct / totalQuestions;

        Color scoreColor() {
          if (scorePercent >= 0.75) return Colors.green.shade200;
          if (scorePercent >= 0.5) return Colors.orange.shade600;
          return Colors.red.shade600;
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// ================= OVERVIEW =================
            _OverviewChart(
              scorePercent: scorePercent,
              accuracyPercent: accuracyPercent,
              color: scoreColor(),
            ),
            const SizedBox(height: 20),

            /// ================= RANK / PERCENTILE =================
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    title: "Rank",
                    value: rank == 0 ? "--" : "$rank",
                    subtitle: totalStudents == 0
                        ? "Overall"
                        : "Out of $totalStudents",
                    icon: Icons.emoji_events_outlined,
                    color: Colors.deepPurple.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    title: "Percentile",
                    value: percentile == 0
                        ? "--"
                        : "${percentile.toStringAsFixed(1)}%",
                    subtitle: "Your standing",
                    icon: Icons.trending_up,
                    color: Colors.teal.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            /// ================= BAR CHART =================
            _BarProgress(
              title: "Score vs Accuracy",
              score: scorePercent,
              accuracy: accuracyPercent,
            ),
          ],
        );
      }),
    );
  }
}

/// ================= OVERVIEW PIE =================
class _OverviewChart extends StatelessWidget {
  final double scorePercent;
  final double accuracyPercent;
  final Color color;

  const _OverviewChart({
    required this.scorePercent,
    required this.accuracyPercent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
        ),
      ),
      child: Row(
        children: [
          _DonutChart(label: "Score", value: scorePercent),
          const SizedBox(width: 20),
          _DonutChart(label: "Accuracy", value: accuracyPercent),
        ],
      ),
    );
  }
}

/// ================= DONUT =================
class _DonutChart extends StatelessWidget {
  final String label;
  final double value;

  const _DonutChart({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            height: 110,
            child: PieChart(
              PieChartData(
                startDegreeOffset: -90,
                sectionsSpace: 0,
                centerSpaceRadius: 35,
                sections: [
                  PieChartSectionData(
                    value: value * 100,
                    color: label == "Score"
                        ? Colors.green
                        : Colors.blue.shade600,
                    radius: 18,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: 100 - (value * 100),
                    color: Colors.white24,
                    radius: 18,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${(value * 100).toStringAsFixed(1)}%",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// ================= BAR GRAPH =================
class _BarProgress extends StatelessWidget {
  final String title;
  final double score;
  final double accuracy;

  const _BarProgress({
    required this.title,
    required this.score,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: 1.2,
                barTouchData: BarTouchData(enabled: false),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return _TopBarLabel(score);
                        if (value == 1) return _TopBarLabel(accuracy);
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            value == 0 ? "Score" : "Accuracy",
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: score,
                        width: 28,
                        color: Colors.green.shade600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: accuracy,
                        width: 28,
                        color: Colors.blue.shade600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBarLabel extends StatelessWidget {
  final double value;
  const _TopBarLabel(this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        "${(value * 100).toStringAsFixed(1)}%",
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// ================= STAT TILE =================
class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
