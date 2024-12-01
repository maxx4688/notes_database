import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_database/theme/theme_constance.dart';

class ViewPage extends StatelessWidget {
  final String title;
  final String content;
  final Timestamp time;
  final String id;
  const ViewPage(
      {super.key,
      required this.title,
      required this.content,
      required this.time,
      required this.id});

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMMM dd, HH:mm').format(dateTime);
  }

  // String formatYear(Timestamp timestamp) {
  //   DateTime dateTime = timestamp.toDate();
  //   return DateFormat('yyyy').format(dateTime);
  // }

  @override
  Widget build(BuildContext context) {
    String formattedCreatedTime = formatTimestamp(time);
    final colour = Theme.of(context).brightness == Brightness.light
        ? Colors.black54
        : Colors.white54;

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            children: [
              const SizedBox(
                height: 100,
              ),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    formattedCreatedTime,
                    style: TextStyle(
                      fontSize: 15,
                      color: colour,
                    ),
                  ),
                  const Text(
                    ' | ',
                    style: TextStyle(color: mainColour),
                  ),
                  Text(
                    '${content.length.toString()} Words',
                    style: TextStyle(
                      fontSize: 15,
                      color: colour,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              Text(
                content,
                style: TextStyle(
                  fontSize: 20,
                  color: colour,
                ),
              )
            ],
          ),
          Container(
            height: 150,
            padding: const EdgeInsets.only(left: 20, bottom: 20),
            // color: Colors.black38,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  // Theme.of(context).brightness == Brightness.light
                  //     ? Colors.black
                  //     : Colors.white,
                  Colors.black,
                  Colors.transparent,
                ],
              ),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Row(
                children: [
                  Icon(
                    Icons.arrow_back_ios,
                    color: mainColour,
                  ),
                  Text(
                    'Notes',
                    style: TextStyle(
                      // color: inverseCol,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
