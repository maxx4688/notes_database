import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_database/applock/pin_provider.dart';
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
    final provider = Provider.of<CustomLockProvider>(context);

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
          Card(
            elevation: 10,
            child: SwitchListTile(
              thumbIcon: const WidgetStatePropertyAll(Icon(
                Icons.verified_user_rounded,
                color: Colors.green,
              )),
              activeTrackColor: Colors.green,
              title: const Text("Enable App Lock"),
              value: provider.isLocked,
              onChanged: (value) async {
                if (value) {
                  // Ask for a new PIN
                  final newPin = await showDialog<String>(
                    context: context,
                    builder: (context) {
                      TextEditingController pinController =
                          TextEditingController();
                      return AlertDialog(
                        title: const Text("Set PIN"),
                        content: TextField(
                          controller: pinController,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          maxLength: 4,
                          decoration: const InputDecoration(
                              labelText: "Enter 4-digit PIN"),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, pinController.text);
                              print(provider.isLocked);
                              print(provider.code);
                            },
                            child: const Text("Save"),
                          ),
                        ],
                      );
                    },
                  );
                  if (newPin != null && newPin.length == 4) {
                    await provider.enableLock(newPin);
                  }
                } else {
                  await provider.disableLock();
                }
              },
            ),
          ),
          // ListTile(
          //   title: Text('Check in console'),
          //   onTap: () {
          //     print(provider.code);
          //     print(provider.isLocked);
          //   },
          // ),
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
