import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_database/firebase/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  Future<void> _loginUser(BuildContext context) async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // Trying to sign in the user
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Checking if user data exists in Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        // Save user data to UserProvider and Shared Preferences
        userProvider.setUser(userCredential.user!.uid, email);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('email', email);
        await prefs.setString('userId', userCredential.user!.uid);

        Navigator.pushReplacementNamed(context, '/home'); // Navigate to Home

      } else if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("One or more fields are empty.")));
            
      } else {
        // If user data does not exist, prompt for account creation
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("User not found. Please create a new account.")));
        _showCreateAccountDialog(context, email, password);
      }
    } catch (e) {
      // Handle login errors
      if (e is FirebaseAuthException) {
        // If user not found, prompt for account creation
        _showCreateAccountDialog(context, email, password);
      } else {
        // Show other errors (e.g., wrong password)
        print("Login failed: $e");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Login failed: $e")));
      }
    }
  }

  Future<void> _showCreateAccountDialog(
      BuildContext context, String email, String password) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Create Account"),
          content: const Text(
              "No account found for this email. Would you like to create a new account?"),
          actions: [
            TextButton(
              onPressed: () async {
                await _createAccount(email, password, context);
                Navigator.of(context).pop();
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createAccount(
      String email, String password, BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Save to UserProvider and Shared Preferences
      userProvider.setUser(userCredential.user!.uid, email);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', userCredential.user!.uid);

      Navigator.pushReplacementNamed(context, '/home'); // Navigate to Home
    } catch (e) {
      print("Account creation failed: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Account creation failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 5,
              child: const Center(
                  child: Text(
                'Hi, User',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              )),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _loginUser(context),
              child: const Text(
                "Login",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
