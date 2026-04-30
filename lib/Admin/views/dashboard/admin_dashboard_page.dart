import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_prep_academy/Admin/controllers/admin_dashboard_controller.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AdminDashboardController());

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1100;

    int crossAxisCount = 4;
    if (isMobile) crossAxisCount = 1;
    if (isTablet) crossAxisCount = 2;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = [
          _StatModel(
            "Total Users",
            ctrl.totalUsers.value.toString(),
            Icons.people,
          ),
          _StatModel("Revenue", "₹${ctrl.revenue.value}", Icons.currency_rupee),
          _StatModel(
            "Mock Tests",
            ctrl.totalTests.value.toString(),
            Icons.quiz,
          ),
          _StatModel(
            "Notes",
            ctrl.totalNotes.value.toString(),
            Icons.menu_book,
          ),
          _StatModel(
            "Active Users",
            ctrl.activeUsers.value.toString(),
            Icons.show_chart,
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= HEADER =================
            const Text(
              "Dashboard",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Overview of your platform",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            /// ================= STATS =================
            GridView.builder(
              itemCount: stats.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile ? 2.8 : 2.2,
              ),
              itemBuilder: (_, i) {
                return _StatCard(model: stats[i]);
              },
            ),

            const SizedBox(height: 30),

            /// ================= CHART =================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "User Growth",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Last 6 months performance",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    height: 280,
                    child: Obx(() {
                      final data = ctrl.monthlyUsers;

                      if (data.isEmpty) {
                        return const Center(child: Text("No Data"));
                      }

                      return LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.withOpacity(0.2),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  const months = [
                                    "Jan",
                                    "Feb",
                                    "Mar",
                                    "Apr",
                                    "May",
                                    "Jun",
                                  ];
                                  return Text(
                                    months[value.toInt()],
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.blue.withOpacity(0.1),
                              ),
                              spots: List.generate(
                                data.length,
                                (i) => FlSpot(i.toDouble(), data[i]),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

/// ================= MODEL =================
class _StatModel {
  final String title;
  final String value;
  final IconData icon;

  _StatModel(this.title, this.value, this.icon);
}

/// ================= CARD =================
class _StatCard extends StatelessWidget {
  final _StatModel model;

  const _StatCard({required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(0.04)),
        ],
      ),
      child: Row(
        children: [
          /// ICON
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(model.icon, color: Colors.blue),
          ),

          const SizedBox(width: 14),

          /// TEXT
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                model.title,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Text(
                model.value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
