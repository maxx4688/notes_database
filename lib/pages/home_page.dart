import 'dart:ui';

import 'package:animations/animations.dart';
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
          title: const Text('Add Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.black12,
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 200,
                child: TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                      labelText: 'Content',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)))),
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
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    contentController.text.isNotEmpty) {
                  await _addNote(titleController.text, contentController.text);
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Can't add empty note."),
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
              child: Text("Error loading notes"),
            );
          }

          final notes = snapshot.data!.docs;

          if (notes.isEmpty) {
            return const Center(child: Text("No notes available. Add a note!"));
          }

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 120),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  var note = notes[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: OpenContainer(
                      transitionDuration: const Duration(milliseconds: 500),
                      openShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      closedColor: Theme.of(context).cardColor,
                      closedElevation: 10,
                      transitionType: ContainerTransitionType.fadeThrough,
                      closedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      closedBuilder: (context, action) => ListTile(
                        title: Text(
                          note['noteTitle'],
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          note['noteContent'],
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                  'Are you sure you want to delete this note?'),
                              action: SnackBarAction(
                                  textColor: Colors.red,
                                  label: 'Yes',
                                  onPressed: () => _deleteNote(note.id)),
                            ),
                          ),
                        ),
                      ),
                      openBuilder: (context, action) {
                        return ViewPage(
                          title: note['noteTitle'],
                          content: note['noteContent'],
                          time: note['createdTime'],
                          id: note.id,
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
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
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
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}



                        // showModal(
                        //   filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                        //   context: context,
                        //   builder: (context) {
                        //     return AlertDialog(
                        //       scrollable: true,
                        //       content: Column(
                        //         mainAxisSize: MainAxisSize.min,
                        //         children: [
                        //           GestureDetector(
                        //             onTap: () => Navigator.pop(context),
                        //             child: Row(
                        //               mainAxisAlignment:
                        //                   MainAxisAlignment.start,
                        //               children: [
                        //                 Container(
                        //                   margin:
                        //                       const EdgeInsets.only(right: 5),
                        //                   height: 15,
                        //                   width: 15,
                        //                   decoration: const BoxDecoration(
                        //                       color: Color(0xFFff6059),
                        //                       shape: BoxShape.circle),
                        //                 ),
                        //                 Container(
                        //                   margin:
                        //                       const EdgeInsets.only(right: 5),
                        //                   height: 15,
                        //                   width: 15,
                        //                   decoration: const BoxDecoration(
                        //                     shape: BoxShape.circle,
                        //                     color: Color(0xFFffbc40),
                        //                   ),
                        //                 ),
                        //                 Container(
                        //                   margin:
                        //                       const EdgeInsets.only(right: 5),
                        //                   height: 15,
                        //                   width: 15,
                        //                   decoration: const BoxDecoration(
                        //                       color: Color(0xFF17c84c),
                        //                       shape: BoxShape.circle),
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //           const SizedBox(
                        //             height: 20,
                        //           ),
                        //           Text(
                        //             note['noteTitle'],
                        //             style: const TextStyle(
                        //               fontSize: 20,
                        //               fontWeight: FontWeight.bold,
                        //             ),
                        //           ),
                        //           Text(note['noteContent']),
                        //         ],
                        //       ),
                        //     );
                        //   },
                        // );