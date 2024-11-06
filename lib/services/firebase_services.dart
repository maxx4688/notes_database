import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {
  // get collections of notes
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  // CREATE
  Future<void> addNote(String note, String title) {
    return notes.add({'title': title, 'note': note});
  }

  // READ

  Stream<QuerySnapshot> getNote() {
    final noteStream = notes.snapshots();
    return noteStream;
  }

  // UPDATE

  // DELETE
}
