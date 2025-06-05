import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignupPage extends StatelessWidget {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  SignupPage({super.key});

  void _performSignup(BuildContext context) async {
    try {
      if (_passwordController.text != _confirmPasswordController.text) {
        print('Passwords do not match');
      }

      // Create user account
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Store full name in the database
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child('users').child(userId);
      userRef.set({
        'full_name': _fullNameController.text,
      });

      // Successfully signed up, show success dialog
      _showSignupSuccessDialog(context);
    } catch (e) {
      // Handle signup failure
      print('Signup failed: $e');
      // Show an error message or dialog
    }
  }

  void _showSignupSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Signup Success'),
          content: const Text('Thank you for signing up!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                // Navigate back to the Login Page
                Navigator.pop(context); // Go back to the previous page
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.signupHeading,
            style: TextStyle(fontSize: 26.0, color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 7, 107, 35),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/cover4.png'), // Add your background image here
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/sign_up.png',
                    height: 280.0), // Add your logo asset here
                const SizedBox(height: 20),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.nameHint,
                      labelStyle: const TextStyle(
                          fontSize: 20.0, color: Color.fromARGB(255, 0, 0, 0)),
                      fillColor: Colors.white.withOpacity(0.5),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(fontSize: 20.0, color: Colors.black),
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.emailHint,
                      labelStyle: const TextStyle(
                          fontSize: 20.0, color: Color.fromARGB(255, 0, 0, 0)),
                      fillColor: Colors.white.withOpacity(0.5),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(fontSize: 20.0, color: Colors.black),
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.passHint,
                      labelStyle: const TextStyle(
                          fontSize: 20.0, color: Color.fromARGB(255, 0, 0, 0)),
                      fillColor: Colors.white.withOpacity(0.5),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    obscureText: true,
                    style: const TextStyle(fontSize: 20.0, color: Colors.black),
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.cnfmPass,
                      labelStyle: const TextStyle(
                          fontSize: 20.0, color: Color.fromARGB(255, 0, 0, 0)),
                      fillColor: Colors.white.withOpacity(0.5),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    obscureText: true,
                    style: const TextStyle(fontSize: 20.0, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _performSignup(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 7, 107, 35),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.signupbtn,
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
