import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: const Text('Log out'),
            trailing:
                IconButton(onPressed: () {}, icon: const Icon(Icons.logout)),
          )
        ],
      ),
    );
  }
}
