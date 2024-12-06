import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:notes_database/firebase/user_provider.dart';
import 'package:notes_database/theme/theme_constance.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool isHidden = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  Future<void> _createAccount(
      String email, String password, BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Enter both email and password!!",
          ),
        ),
      );
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set(
        {
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      // Save to UserProvider and Shared Preferences
      userProvider.setUser(userCredential.user!.uid, email);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', userCredential.user!.uid);

      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "User with this email already exists, try logging in.",
            ),
          ),
        );
      } else {
        print("Account creation failed: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Account creation failed: $e",
            ),
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 40.0,
        ),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 4,
            child: const Center(
              child: Text(
                'Noting',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
          const Row(
            children: [
              Text(
                'New,',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 30,
                ),
              ),
              Text(
                'User',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 30,
                  color: mainColour,
                ),
              ),
            ],
          ),
          const Text('Create a new account!'),
          SizedBox(
            height: MediaQuery.of(context).size.height / 20,
          ),
          TextField(
            cursorColor: mainColour,
            controller: _emailController,
            scrollPhysics: const BouncingScrollPhysics(),
            decoration: const InputDecoration(
              labelText: 'New email',
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 30,
          ),
          TextField(
            cursorColor: mainColour,
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'New password',
              suffixIcon: IconButton(
                icon: Icon(
                  isHidden == false ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    isHidden = !isHidden;
                  });
                },
              ),
            ),
            obscureText: isHidden,
            scrollPhysics: const BouncingScrollPhysics(),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100.0),
            child: isLoading == false
                ? ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Color.fromARGB(255, 22, 22, 22),
                      ),
                    ),
                    onPressed: () {
                      _createAccount(_emailController.text,
                          _passwordController.text, context);
                    },
                    child: const Text(
                      "Sign up",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : SpinKitDoubleBounce(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                  ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Already have an account?"),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Log in',
                  style: TextStyle(
                    color: mainColour,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
