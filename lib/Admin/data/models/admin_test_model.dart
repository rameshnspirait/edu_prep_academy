class AdminTestModel {
  final String id;
  final String title;
  final String category;
  final int duration;
  final int totalMarks;
  final double negativeMarks;

  AdminTestModel({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.totalMarks,
    required this.negativeMarks,
  });

  factory AdminTestModel.fromJson(Map<String, dynamic> json, String id) {
    return AdminTestModel(
      id: id,
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      duration: json['duration'] ?? 0,
      totalMarks: json['totalMarks'] ?? 0,
      negativeMarks: (json['negativeMarks'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "category": category,
      "duration": duration,
      "totalMarks": totalMarks,
      "negativeMarks": negativeMarks,
      "createdAt": DateTime.now(),
    };
  }
}
