import 'package:edu_prep_academy/core/constants/app_colors.dart';
import 'package:edu_prep_academy/core/utils/app_utils.dart';
import 'package:edu_prep_academy/models/note_model.dart';
import 'package:edu_prep_academy/views/notes/note_details_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_prep_academy/controllers/notes_controller.dart';
import 'package:edu_prep_academy/core/theme/app_text_style.dart';
import 'package:shimmer/shimmer.dart';

class NotesView extends GetView<NotesController> {
  NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 10,
        title: Text(
          'Notes',
          style: AppTextStyles.headingMedium(
            context,
          ).copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isInitialLoading.value) {
          return const _NotesShimmer();
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 300) {
              controller.loadMore(); // ✅ SAFE
            }
            return false;
          },
          child: RefreshIndicator(
            color: AppColors.primaryBlue,
            onRefresh: controller.fetchInitialNotes,
            child: CustomScrollView(
              slivers: [
                for (final entry in controller.subjectNotes.entries) ...[
                  /// SUBJECT TITLE
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        entry.key,
                        style: AppTextStyles.headingSmall(
                          context,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  /// NOTES GRID
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final note = entry.value[index];
                        return _NoteCard(
                          note: note,
                          isDark: isDark,
                          onTap: () {
                            Get.to(
                              () => NoteDetailView(note: note),
                              transition: Transition.rightToLeft,
                            );
                          },
                        );
                      }, childCount: entry.value.length),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.82,
                          ),
                    ),
                  ),
                ],

                /// BOTTOM LOADER
                SliverToBoxAdapter(
                  child: Obx(
                    () => controller.isLoadingMore.value
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: _BottomLoader(),
                          )
                        : const SizedBox(height: 40),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final NoteModel note;
  final bool isDark;
  final VoidCallback? onTap;

  const _NoteCard({required this.note, required this.isDark, this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = AppUtils.format(note.createdAt);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: isDark
            ? Colors.white10
            : Theme.of(context).primaryColor.withOpacity(0.08),
        highlightColor: isDark
            ? Colors.white10
            : Theme.of(context).primaryColor.withOpacity(0.04),

        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.4)
                    : Colors.grey.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// THUMBNAIL + TAG
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: NetworkImageWithShimmer(
                        imageUrl: note.thumbnail,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                    ),

                    /// PDF CHIP
                    Positioned(
                      top: 8,
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
                        child: Row(
                          children: const [
                            Icon(
                              Icons.picture_as_pdf,
                              size: 14,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'PDF',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// CONTENT
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TITLE
                    Text(
                      note.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// DATE
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotesShimmer extends StatelessWidget {
  const _NotesShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Let's simulate 3 categories each with 4 notes
    final int categories = 3;
    final int notesPerCategory = 4;

    return CustomScrollView(
      slivers: [
        for (int cat = 0; cat < categories; cat++) ...[
          // Category Title Shimmer
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            sliver: SliverToBoxAdapter(
              child: Shimmer.fromColors(
                baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                highlightColor: isDark
                    ? Colors.grey.shade700
                    : Colors.grey.shade100,
                child: Container(
                  height: 22,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),

          // Notes Grid Shimmer
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                return Shimmer.fromColors(
                  baseColor: isDark
                      ? Colors.grey.shade800
                      : Colors.grey.shade300,
                  highlightColor: isDark
                      ? Colors.grey.shade700
                      : Colors.grey.shade100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            height: 14,
                            width: double.infinity,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Date
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            height: 12,
                            width: 60,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              }, childCount: notesPerCategory),
            ),
          ),
        ],

        // Bottom Loader
        SliverToBoxAdapter(
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ),
      ],
    );
  }
}

class _BottomLoader extends StatelessWidget {
  const _BottomLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
  }
}

class NetworkImageWithShimmer extends StatefulWidget {
  final String imageUrl;
  final BorderRadius borderRadius;

  const NetworkImageWithShimmer({
    super.key,
    required this.imageUrl,
    required this.borderRadius,
  });

  @override
  State<NetworkImageWithShimmer> createState() =>
      _NetworkImageWithShimmerState();
}

class _NetworkImageWithShimmerState extends State<NetworkImageWithShimmer> {
  bool _isLoaded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        /// SHIMMER
        if (!_isLoaded)
          Shimmer.fromColors(
            baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
            highlightColor: isDark
                ? Colors.grey.shade700
                : Colors.grey.shade100,
            child: Container(color: Colors.grey),
          ),

        /// IMAGE
        Image.network(
          widget.imageUrl,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, _) {
            if (frame != null) {
              Future.microtask(() {
                if (mounted) setState(() => _isLoaded = true);
              });
            }
            return child;
          },
          errorBuilder: (_, __, ___) {
            return const Center(child: Icon(Icons.broken_image, size: 32));
          },
        ),
      ],
    );
  }
}
