import 'package:edu_prep_academy/User/controllers/download_notes_controller.dart';
import 'package:edu_prep_academy/User/core/utils/app_utils.dart';
import 'package:edu_prep_academy/User/views/profile/pdf_view_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DownloadedNotesView extends StatefulWidget {
  const DownloadedNotesView({super.key});

  @override
  State<DownloadedNotesView> createState() => _DownloadedNotesViewState();
}

class _DownloadedNotesViewState extends State<DownloadedNotesView> {
  final controller = Get.put(DownloadedNotesController());

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    controller.loadPdfs(userId);
  }

  @override
  Widget build(BuildContext context) {
    // final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Downloaded Notes"),
        centerTitle: true,
        elevation: 8,
      ),

      body: Obx(() {
        final pdfs = controller.downloadedPdfs;

        if (pdfs.isEmpty) {
          return _emptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pdfs.length,
          itemBuilder: (context, index) {
            final pdf = pdfs[index];

            return _PremiumPdfCard(
              pdf: pdf,
              onTap: () {
                Get.to(() => PdfViewerPage(filePath: pdf.filePath));
              },
            );
          },
        );
      }),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, size: 80, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No Offline Notes",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            "Download notes to access them without internet",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _PremiumPdfCard extends StatelessWidget {
  final dynamic pdf;
  final VoidCallback onTap;

  const _PremiumPdfCard({required this.pdf, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            /// 📄 THUMBNAIL SECTION
            Container(
              width: 90,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.8),
                    Colors.indigo.withOpacity(0.9),
                  ],
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf, color: Colors.white, size: 40),
                  SizedBox(height: 6),
                  Text(
                    "PDF",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            /// DETAILS
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TITLE
                    Text(
                      pdf.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// DOWNLOAD TIME
                    Row(
                      children: [
                        const Icon(
                          Icons.download_done,
                          size: 14,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppUtils.format(pdf.downloadedAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// TAGS
                    Row(
                      children: [
                        _tag("Offline", Colors.green),
                        const SizedBox(width: 6),
                        _tag("Saved", Colors.blue),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            /// ARROW
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
