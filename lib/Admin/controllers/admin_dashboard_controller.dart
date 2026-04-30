import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AdminDashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ================= STATE =================
  var totalUsers = 0.obs;
  var totalTests = 0.obs;
  var activeUsers = 0.obs;
  var revenue = 0.obs;
  var totalNotes = 0.obs;

  var isLoading = true.obs;

  /// Chart data
  var monthlyUsers = <double>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  /// ================= MAIN FETCH =================
  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;

      await Future.wait([
        _getUsers(),
        _getTests(),
        _getRevenue(),
        _getChartData(),
        _getNotes(),
      ]);
    } catch (e) {
      print("Dashboard Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  ///================== NOTES =================
  Future<void> _getNotes() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collectionGroup('items') // 🔥 key change
          .get();

      totalNotes.value = snapshot.size; // total notes count
    } catch (e) {
      print("Notes count error: $e");
    }
  }

  /// ================= USERS =================
  Future<void> _getUsers() async {
    final snapshot = await _firestore.collection('users').get();
    totalUsers.value = snapshot.docs.length;

    /// Example active users logic (last 7 days)
    final now = DateTime.now();
    activeUsers.value = snapshot.docs.where((doc) {
      final lastLogin = doc['lastLogin'];
      if (lastLogin == null) return false;

      final date = (lastLogin as Timestamp).toDate();
      return now.difference(date).inDays <= 7;
    }).length;
  }

  /// ================= TESTS =================
  Future<void> _getTests() async {
    int count = 0;

    final categories = await _firestore.collection('mock_tests').get();

    for (var cat in categories.docs) {
      final tests = await cat.reference.collection('tests').get();
      count += tests.docs.length;
    }

    totalTests.value = count;
  }

  /// ================= REVENUE =================
  Future<void> _getRevenue() async {
    final payments = await _firestore.collection('payments').get();

    int total = 0;
    for (var doc in payments.docs) {
      total += (doc['amount'] ?? 0) as int;
    }

    revenue.value = total;
  }

  /// ================= CHART =================
  Future<void> _getChartData() async {
    final users = await _firestore.collection('users').get();

    List<double> months = List.filled(6, 0);

    for (var doc in users.docs) {
      final createdAt = doc['createdAt'];
      if (createdAt == null) continue;

      final date = (createdAt as Timestamp).toDate();
      final monthIndex = DateTime.now().month - date.month;

      if (monthIndex >= 0 && monthIndex < 6) {
        months[5 - monthIndex] += 1;
      }
    }

    monthlyUsers.value = months;
  }
}
