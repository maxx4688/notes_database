import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_database/theme/theme_constance.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController passwordFor = TextEditingController();

  Future resetPassword(BuildContext context) async {
    if (passwordFor.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.black,
          content: Text(
            'No email found!!',
            style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
          )));
    } else {
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: passwordFor.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.black,
            content: Text(
              'Password reset link sent!!\nCheck your mail Inbox',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
            )));
      } on FirebaseAuthException catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.black,
            content: Text(
              e.message.toString(),
              style: const TextStyle(fontFamily: 'Poppins', color: Colors.red),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    passwordFor.dispose;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 4,
            child: const Center(
              child: Text(
                'Noting',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'poppins',
                ),
              ),
            ),
          ),
          const Row(
            children: [
              Text(
                'Forgot ',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 35,
                ),
              ),
              Text(
                'password?',
                style: TextStyle(
                    fontFamily: 'poppins', fontSize: 35, color: mainColour),
              ),
            ],
          ),
          const Center(
              child: Text(
                  "No worries, Enter your email and we'll send you a mail for resetting it.")),
          SizedBox(
            height: MediaQuery.of(context).size.height / 10,
          ),
          TextField(
            cursorColor: mainColour,
            controller: passwordFor,
            scrollPhysics: const BouncingScrollPhysics(),
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 20,
          ),
          Hero(
            tag: 'pass',
            child: ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  Color.fromARGB(255, 22, 22, 22),
                ),
              ),
              onPressed: () => resetPassword(context),
              child: const Text(
                "Send mail",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 10,
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_back_ios,
                  size: 15,
                ),
                Text('Back to login'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
