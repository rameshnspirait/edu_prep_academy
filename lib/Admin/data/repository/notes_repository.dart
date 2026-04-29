import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_prep_academy/Admin/data/models/notes_model.dart';

class NotesRepository {
  final _firestore = FirebaseFirestore.instance;

  /// FETCH SUBJECTS
  Future<List<String>> getSubjects() async {
    final snap = await _firestore.collection('notes').get();
    return snap.docs.map((e) => e.id).toList();
  }

  /// FETCH NOTES
  Future<List<AdminNoteModel>> getNotes(String subjectId) async {
    final snap = await _firestore
        .collection('notes')
        .doc(subjectId)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs
        .map((e) => AdminNoteModel.fromJson(e.data(), e.id))
        .toList();
  }

  /// ADD NOTE
  Future<void> addNote(String subjectId, AdminNoteModel note) async {
    await _firestore
        .collection('notes')
        .doc(subjectId)
        .collection('items')
        .add(note.toJson());
  }

  /// UPDATE NOTE
  Future<void> updateNote(
    String subjectId,
    String id,
    AdminNoteModel note,
  ) async {
    await _firestore
        .collection('notes')
        .doc(subjectId)
        .collection('items')
        .doc(id)
        .update(note.toJson());
  }

  /// DELETE NOTE
  Future<void> deleteNote(String subjectId, String id) async {
    await _firestore
        .collection('notes')
        .doc(subjectId)
        .collection('items')
        .doc(id)
        .delete();
  }
}
