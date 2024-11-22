import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_database/firebase/user_provider.dart';
import 'package:notes_database/login_page.dart';
import 'package:notes_database/theme/theme_constance.dart';
import 'package:notes_database/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final changeTheme = Provider.of<ThemeProvider>(context);

    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(
            height: 50,
          ),
          const Text(
            'Hello,',
            style: TextStyle(
              color: mainColour,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(userProvider.email!),
          const SizedBox(
            height: 30,
          ),
          Card(
            elevation: 10,
            child: ListTile(
              title: const Text('Switch theme'),
              onTap: () {
                changeTheme.toggleTheme();
              },
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 1.35,
          ),
          const Divider(),
          const Text(
            'Danger zone!!',
            style: TextStyle(color: Colors.red),
          ),
          Card(
            elevation: 10,
            child: ListTile(
              title: const Text('Log out'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                userProvider.logout();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);

                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const LoginPage()));
              },
            ),
          ),
        ],
      ),
    );
  }
}
