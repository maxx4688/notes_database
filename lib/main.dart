import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes_database/services/firebase_services.dart';
import 'package:notes_database/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'theme/theme_constance.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (context) => ThemeProvider())],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes database',
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FireStoreService fireStoreService = FireStoreService();

  TextEditingController notesCont = TextEditingController();
  TextEditingController titleCont = TextEditingController();

  void openDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Add new note'),
                  TextField(
                    controller: titleCont,
                  ),
                  TextField(
                    controller: notesCont,
                  )
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close')),
                TextButton(
                    onPressed: () {
                      fireStoreService.addNote(notesCont.text, titleCont.text);
                      titleCont.clear();
                      notesCont.clear();
                      Navigator.pop(context);
                    },
                    child: const Text('Add')),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final getTheme = Provider.of<ThemeProvider>(context);
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: openDialog,
          elevation: 10,
          child: const Icon(Icons.edit),
        ),
        body: StreamBuilder(
          stream: fireStoreService.getNote(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List notesList = snapshot.data!.docs;
              return Stack(
                children: [
                  ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 100, bottom: 30),
                      itemCount: notesList.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = notesList[index];
                        String id = document.id;

                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        String noteTitle = data['title'];
                        String noteContent = data['note'];

                        return Card(
                          shadowColor: Colors.black26,
                          elevation: 15,
                          // color: Colors.white,
                          child: ListTile(
                            leading: const Icon(Icons.note),
                            title: Text(noteTitle),
                            subtitle: Text(noteContent),
                          ),
                        );
                      }),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 40.0, left: 10, right: 10),
                    child: Card(
                      shadowColor: Colors.black38,
                      elevation: 20,
                      child: SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Hey ash.',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: mainColour,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  getTheme.toggleTheme();
                                },
                                child: Icon(
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Icons.toggle_off
                                      : Icons.toggle_on,
                                  color: mainColour,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              );
            } else {
              return Center(child: const Text('No saved notes yet'));
            }
          },
        ));
  }
}
