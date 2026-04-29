class VideoModel {
  final String title;
  final String subject;
  final String thumbnail;
  final int duration; // minutes
  final double progress; // 0.0 - 1.0

  VideoModel({
    required this.title,
    required this.subject,
    required this.thumbnail,
    required this.duration,
    required this.progress,
  });
}
