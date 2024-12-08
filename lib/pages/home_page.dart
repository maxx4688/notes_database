import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:notes_database/my_drawer.dart';
import 'package:notes_database/pages/view_page.dart';
import 'package:notes_database/theme/theme_constance.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> _addOrEditNoteDialog() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    // setState(() {});

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: const Text(
            'Add Note',
            style: TextStyle(fontFamily: 'poppins'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                cursorColor: mainColour,
                controller: titleController,
                decoration: const InputDecoration(
                  floatingLabelStyle: TextStyle(color: mainColour),
                  labelText: 'Title',
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    borderSide: BorderSide(color: mainColour),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 200,
                child: TextField(
                  cursorColor: mainColour,
                  controller: contentController,
                  decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                      borderSide: BorderSide(color: mainColour),
                    ),
                    floatingLabelStyle: TextStyle(color: mainColour),
                    labelText: 'Content',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                  ),
                  // maxLength: null,
                  maxLines: null,
                  minLines: null,
                  expands: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(mainColour),
              ),
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                try {
                  if (titleController.text.isNotEmpty ||
                      contentController.text.isNotEmpty) {
                    await _addNote(
                        titleController.text, contentController.text);
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.black,
                        content: Text(
                          "Can't add empty note.",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.black,
                      content: Text(
                        "Unexpected error occured",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
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
    return Scaffold(
      drawer: const MyDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('notes')
            .orderBy('createdTime', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: SpinKitDoubleBounce(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
            ));
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Error loading notes",
                style: TextStyle(fontFamily: 'poppins'),
              ),
            );
          }

          final notes = snapshot.data!.docs;

          if (notes.isEmpty) {
            return const Center(
                child: Text(
              "No notes available. Add a note!",
              style: TextStyle(fontFamily: 'poppins'),
            ));
          }

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 120),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  var note = notes[index];
                  return Card(
                    elevation: 6,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color.fromARGB(255, 12, 12, 12)
                        : Colors.white,
                    child: ListTile(
                      title: Text(
                        note['noteTitle'],
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                        style: const TextStyle(fontFamily: 'poppins'),
                      ),
                      subtitle: Text(
                        note['noteContent'],
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black54
                                  : Colors.white38,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.close,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black
                                  : mainColour,
                        ),
                        onPressed: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.black,
                            content: const Text(
                              'Are you sure you want to delete this note?',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'poppins',
                              ),
                            ),
                            action: SnackBarAction(
                              textColor: mainColour,
                              label: 'Yes',
                              onPressed: () => _deleteNote(note.id),
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => ViewPage(
                              title: note['noteTitle'],
                              content: note['noteContent'],
                              time: note['createdTime'],
                              id: note.id,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40.0, left: 10, right: 10),
                child: Card(
                  color: Theme.of(context).cardColor,
                  elevation: 20,
                  child: SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Builder(builder: (context) {
                            return GestureDetector(
                                onTap: () {
                                  Scaffold.of(context).openDrawer();
                                },
                                child: const Icon(Icons.menu_rounded));
                          }),
                          const Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Text(
                              'Noting,',
                              style: TextStyle(
                                color: mainColour,
                                fontFamily: 'poppins',
                                fontSize: 26,
                              ),
                            ),
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
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
