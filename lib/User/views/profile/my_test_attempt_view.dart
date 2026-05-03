// import 'package:edu_prep_academy/User/controllers/my_test_attempts_controller.dart';
// import 'package:edu_prep_academy/User/core/constants/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:lottie/lottie.dart';

// class MyTestAttemptView extends StatelessWidget {
//   MyTestAttemptView({super.key});

//   final controller = Get.put(MyTestAttemptsController());

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("My Performance"),
//         centerTitle: true,
//         elevation: 4,
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return _shimmer(isDark);
//         }

//         if (controller.attempts.isEmpty) {
//           return _emptyState(isDark);
//         }

//         final tests = controller.attempts;

//         return RefreshIndicator(
//           onRefresh: () async => controller.fetchAttempts(),
//           child: ListView(
//             padding: const EdgeInsets.all(16),
//             children: [
//               /// 🔥 TOP ANIMATION
//               // Center(
//               //   child: Lottie.asset(
//               //     'assets/lottie/analytics.json',
//               //     height: 120,
//               //   ),
//               // ),
//               const SizedBox(height: 12),

//               /// 🔥 SUMMARY CARD
//               _summaryCard(tests, isDark),

//               const SizedBox(height: 20),

//               /// 🔥 PERFORMANCE CHART
//               _chartCard(tests, isDark),

//               const SizedBox(height: 20),

//               /// 🔥 WEAK AREAS
//               _weakCard(tests, isDark),

//               const SizedBox(height: 20),

//               /// 🔥 ATTEMPT LIST
//               ...tests.map((e) => _attemptCard(e, isDark)),
//             ],
//           ),
//         );
//       }),
//     );
//   }

//   /// ================= SHIMMER =================
//   Widget _shimmer(bool isDark) {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: 5,
//       itemBuilder: (_, __) => Container(
//         height: 100,
//         margin: const EdgeInsets.only(bottom: 16),
//         decoration: BoxDecoration(
//           color: isDark ? Colors.grey[800] : Colors.grey[300],
//           borderRadius: BorderRadius.circular(16),
//         ),
//       ),
//     );
//   }

//   /// ================= EMPTY =================
//   Widget _emptyState(bool isDark) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Lottie.asset('assets/lottie/empty.json', height: 180),
//           const SizedBox(height: 10),
//           Text(
//             "No Attempts Yet",
//             style: TextStyle(
//               fontSize: 16,
//               color: isDark ? Colors.white : Colors.black,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// ================= SUMMARY =================
//   Widget _summaryCard(List tests, bool isDark) {
//     final total = tests.length;

//     final avg = tests.isEmpty
//         ? 0
//         : tests.map((e) => (e['accuracy'] ?? 0)).reduce((a, b) => a + b) /
//               total;

//     final best = tests
//         .map((e) => (e['obtainedMarks'] ?? 0))
//         .fold(0, (a, b) => a > b ? a : b);

//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
//         ),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         children: [
//           const Text(
//             "Your Performance",
//             style: TextStyle(color: Colors.white70),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _stat("Tests", "$total"),
//               _stat("Avg", "${avg.toStringAsFixed(1)}%"),
//               _stat("Best", "$best"),
//               _stat("Rank", "#${controller.userRank.value}"),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _stat(String title, String value) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Text(title, style: const TextStyle(color: Colors.white70)),
//       ],
//     );
//   }

//   /// ================= CHART =================
//   Widget _chartCard(List tests, bool isDark) {
//     final scores = tests.map((e) => (e['accuracy'] ?? 0).toDouble()).toList();

//     return _cardWrapper(
//       isDark,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text("Accuracy Trend"),
//           const SizedBox(height: 16),
//           SizedBox(
//             height: 180,
//             child: LineChart(
//               LineChartData(
//                 borderData: FlBorderData(show: false),
//                 titlesData: FlTitlesData(show: false),
//                 gridData: FlGridData(show: false),
//                 lineBarsData: [
//                   LineChartBarData(
//                     isCurved: true,
//                     spots: List.generate(
//                       scores.length,
//                       (i) => FlSpot(i.toDouble(), scores[i]),
//                     ),
//                     color: AppColors.primaryBlue,
//                     barWidth: 3,
//                     dotData: FlDotData(show: false),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// ================= WEAK =================
//   Widget _weakCard(List tests, bool isDark) {
//     final weak = tests
//         .where((e) => (e['accuracy'] ?? 0) < 50)
//         .map((e) => e['testName'] ?? "Test")
//         .toSet()
//         .toList();

//     if (weak.isEmpty) return const SizedBox();

//     return _cardWrapper(
//       isDark,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text("Weak Areas"),
//           const SizedBox(height: 10),
//           Wrap(
//             spacing: 10,
//             children: weak
//                 .map(
//                   (e) => Chip(
//                     label: Text(e),
//                     backgroundColor: Colors.red.withOpacity(0.1),
//                   ),
//                 )
//                 .toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   /// ================= ATTEMPT CARD =================
//   Widget _attemptCard(Map data, bool isDark) {
//     final score = data['obtainedMarks'] ?? 0;
//     final total = data['totalMarks'] ?? 1;
//     final acc = data['accuracy'] ?? 0;

//     return _cardWrapper(
//       isDark,
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 24,
//             backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
//             child: const Icon(Icons.analytics),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               data['testName'] ?? "Mock Test",
//               style: const TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text("$score/$total"),
//               Text(
//                 "${acc.toStringAsFixed(1)}%",
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: acc >= 50 ? Colors.green : Colors.red,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   /// ================= COMMON CARD =================
//   Widget _cardWrapper(bool isDark, {required Widget child}) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: isDark
//                 ? Colors.black.withOpacity(0.4)
//                 : Colors.grey.withOpacity(0.1),
//             blurRadius: 8,
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
// }
