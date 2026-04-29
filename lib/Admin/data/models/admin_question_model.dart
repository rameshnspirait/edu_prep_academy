class AdminQuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  AdminQuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  Map<String, dynamic> toJson() {
    return {
      "question": question,
      "options": options,
      "correctIndex": correctIndex,
      "explanation": explanation,
    };
  }
}
