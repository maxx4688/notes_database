import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_database/firebase/user_provider.dart';
import 'package:notes_database/login_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> _addOrEditNoteDialog({DocumentSnapshot? note}) async {
    final titleController =
        TextEditingController(text: note?['noteTitle'] ?? '');
    final contentController =
        TextEditingController(text: note?['noteContent'] ?? '');

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(note == null ? 'Add Note' : 'Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(note == null ? 'Add' : 'Save'),
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    contentController.text.isNotEmpty) {
                  if (note == null) {
                    await _addNote(
                        titleController.text, contentController.text);
                  } else {
                    await _updateNote(
                        note.id, titleController.text, contentController.text);
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addNote(String title, String content) async {
    String uid = _auth.currentUser!.uid;

    await _firestore.collection('users').doc(uid).collection('notes').add({
      'noteTitle': title,
      'noteContent': content,
      'createdTime': FieldValue.serverTimestamp(),
      'editedTime': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateNote(String noteId, String title, String content) async {
    String uid = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notes')
        .doc(noteId)
        .update({
      'noteTitle': title,
      'noteContent': content,
      'editedTime': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _deleteNote(String noteId) async {
    String uid = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notes')
        .doc(noteId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('notes')
            .orderBy('createdTime', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading notes"));
          }

          final notes = snapshot.data!.docs;

          if (notes.isEmpty) {
            return const Center(child: Text("No notes available. Add a note!"));
          }

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 100),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  var note = notes[index];
                  return Card(
                    elevation: 10,
                    child: ListTile(
                      title: Text(note['noteTitle']),
                      subtitle: Text(note['noteContent']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _addOrEditNoteDialog(note: note),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteNote(note.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40.0, left: 10, right: 10),
                child: Card(
                  elevation: 20,
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(userProvider.email!),
                          IconButton(
                            icon: const Icon(Icons.logout),
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              userProvider.logout();
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool('isLoggedIn',
                                  false); // Explicitly set isLoggedIn to false

                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditNoteDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
