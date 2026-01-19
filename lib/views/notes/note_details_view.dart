import 'dart:io';

import 'package:dio/dio.dart';
import 'package:edu_prep_academy/core/utils/app_utils.dart';
import 'package:edu_prep_academy/models/note_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class NoteDetailView extends StatefulWidget {
  final NoteModel note;

  const NoteDetailView({super.key, required this.note});

  @override
  State<NoteDetailView> createState() => _NoteDetailViewState();
}

class _NoteDetailViewState extends State<NoteDetailView> {
  final PdfViewerController _pdfController = PdfViewerController();

  bool _isLoading = true;
  bool _focusMode = false;
  File? _localFile;

  @override
  void initState() {
    super.initState();
    _preparePdf();
  }

  /// DOWNLOAD & CACHE PDF (OFFLINE + ONLINE)
  Future<void> _preparePdf() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${widget.note.id}.pdf');

      if (await file.exists()) {
        _localFile = file;
        return;
      }

      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final response = await dio.get(
        widget.note.pdfUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.data);
        _localFile = file;
      } else {
        throw Exception('PDF not found');
      }
    } catch (e) {
      debugPrint('PDF Error: $e');
      _localFile = null;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// SEARCH
  void _openSearch() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Search in Notes'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter keyword'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _pdfController.searchText(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  /// PAGE JUMP
  void _jumpToPage() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Go to page'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () {
              final page = int.tryParse(controller.text);
              if (page != null) _pdfController.jumpToPage(page);
              Navigator.pop(context);
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    /// 🔥 GLOBAL THEME (SYNCED WITH PROFILE TAB)
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,

      /// APP BAR
      appBar: _focusMode
          ? null
          : AppBar(
              elevation: 10,
              backgroundColor: bgColor,
              foregroundColor: isDark ? Colors.white : Colors.black,
              title: Text(
                widget.note.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _openSearch,
                ),
                IconButton(
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () {
                    /// 🔥 CHANGE GLOBAL THEME
                    Get.changeThemeMode(
                      isDark ? ThemeMode.light : ThemeMode.dark,
                    );
                  },
                ),
              ],
            ),

      body: Column(
        children: [
          /// META INFO
          if (!_focusMode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  _InfoChip(
                    icon: Icons.calendar_today,
                    label: AppUtils.format(widget.note.createdAt),
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(icon: Icons.picture_as_pdf, label: 'PDF Notes'),
                ],
              ),
            ),

          /// PDF VIEW
          Expanded(
            child: Container(
              color: bgColor, // 🔥 fills entire screen
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _localFile == null
                  ? _PdfErrorView(onRetry: _preparePdf)
                  : SfPdfViewer.file(
                      _localFile!,
                      controller: _pdfController,

                      /// SMOOTH UX
                      pageLayoutMode: PdfPageLayoutMode.continuous,
                      enableDoubleTapZooming: true,
                      enableTextSelection: true,
                      canShowScrollHead: false,
                      canShowScrollStatus: false,
                    ),
            ),
          ),
        ],
      ),

      /// FLOATING READER CONTROLS
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _focusMode
          ? null
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ReaderAction(
                  icon: Icons.navigate_before,
                  onTap: () => _pdfController.previousPage(),
                ),
                const SizedBox(width: 10),
                _ReaderAction(
                  icon: Icons.navigate_next,
                  onTap: () => _pdfController.nextPage(),
                ),
                const SizedBox(width: 10),
                _ReaderAction(icon: Icons.menu_book, onTap: _jumpToPage),
                const SizedBox(width: 10),
                _ReaderAction(
                  icon: Icons.center_focus_strong,
                  onTap: () => setState(() => _focusMode = !_focusMode),
                ),
              ],
            ),
    );
  }
}

/// INFO CHIP
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Theme.of(context).primaryColor),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

/// FLOATING BUTTON
class _ReaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ReaderAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

/// ERROR VIEW
class _PdfErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _PdfErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
          const SizedBox(height: 12),
          const Text(
            'Unable to load PDF',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'File not found or removed from server',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
