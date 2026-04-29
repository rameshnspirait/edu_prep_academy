import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/note_model.dart';

class NotesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isInitialLoading = true.obs;
  final RxBool isLoadingMore = false.obs;

  final RxMap<String, List<NoteModel>> subjectNotes =
      <String, List<NoteModel>>{}.obs;

  final Map<String, DocumentSnapshot?> _lastDocs = {};
  final int pageSize = 6;

  @override
  void onInit() {
    super.onInit();
    fetchInitialNotes();
  }

  /// INITIAL LOAD
  Future<void> fetchInitialNotes() async {
    try {
      isInitialLoading.value = true;

      final subjects = await _firestore.collection('notes').get();

      for (final subject in subjects.docs) {
        final snap = await subject.reference
            .collection('items')
            .orderBy('createdAt', descending: true)
            .limit(pageSize)
            .get();

        subjectNotes[subject.id.replaceAll('_', ' ')] = snap.docs
            .map((e) => NoteModel.fromJson(e.data(), e.id))
            .toList();

        if (snap.docs.isNotEmpty) {
          _lastDocs[subject.id] = snap.docs.last;
        }
      }
    } finally {
      isInitialLoading.value = false;
    }
  }

  /// LOAD MORE
  Future<void> loadMore() async {
    if (isLoadingMore.value) return;
    isLoadingMore.value = true;

    try {
      for (final entry in subjectNotes.entries) {
        final subjectId = entry.key.replaceAll(' ', '_');
        final lastDoc = _lastDocs[subjectId];

        if (lastDoc == null) continue;

        final snap = await _firestore
            .collection('notes')
            .doc(subjectId)
            .collection('items')
            .orderBy('createdAt', descending: true)
            .startAfterDocument(lastDoc)
            .limit(pageSize)
            .get();

        if (snap.docs.isNotEmpty) {
          subjectNotes[entry.key]!.addAll(
            snap.docs.map((e) => NoteModel.fromJson(e.data(), e.id)),
          );
          subjectNotes.refresh();
          _lastDocs[subjectId] = snap.docs.last;
        }
      }
    } finally {
      isLoadingMore.value = false;
    }
  }
}
