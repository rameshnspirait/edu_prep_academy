import 'package:edu_prep_academy/core/constants/app_colors.dart';
import 'package:edu_prep_academy/core/theme/app_text_style.dart';
import 'package:edu_prep_academy/views/classes/video_model.dart';
import 'package:flutter/material.dart';

class VideoClassesView extends StatelessWidget {
  VideoClassesView({super.key});
  final List<VideoModel> videoClasses = [
    VideoModel(
      title: "Physics: Laws of Motion",
      subject: "SSC GD",
      thumbnail:
          "https://images.pexels.com/photos/256417/pexels-photo-256417.jpeg",
      duration: 42,
      progress: 0.7,
    ),
    VideoModel(
      title: "Maths: Algebra Basics",
      subject: "SSC GD",
      thumbnail:
          "https://images.pexels.com/photos/267885/pexels-photo-267885.jpeg",
      duration: 35,
      progress: 0.4,
    ),
    VideoModel(
      title: "History: Freedom Struggle",
      subject: "Railway Exams",
      thumbnail:
          "https://images.pexels.com/photos/159711/books-bookstore-book-reading-159711.jpeg",
      duration: 50,
      progress: 0.9,
    ),
    VideoModel(
      title: "English: Grammar Rules",
      subject: "Bank Exams",
      thumbnail:
          "https://images.pexels.com/photos/261909/pexels-photo-261909.jpeg",
      duration: 30,
      progress: 0.2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 10,
        title: const Text("Video Classes"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: videoClasses.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            return _VideoCard(video: videoClasses[index], isDark: isDark);
          },
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final VideoModel video;
  final bool isDark;

  const _VideoCard({required this.video, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        // Navigate to video player
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.45)
                  : Colors.grey.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───────────── THUMBNAIL ─────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Stack(
                children: [
                  Image.network(
                    video.thumbnail,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),

                  // ▶ Play Button
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // ⏱ Duration
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${video.duration} min",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ───────────── CONTENT ─────────────
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.subject,
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium(
                      context,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  // 📊 Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: video.progress,
                      minHeight: 6,
                      backgroundColor: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${(video.progress * 100).toInt()}% watched",
                    style: AppTextStyles.caption(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
