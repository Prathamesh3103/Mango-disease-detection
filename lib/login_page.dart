import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maizeplant/language_provider.dart';
import 'package:provider/provider.dart';
import 'signup_page.dart';
import 'home_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ValueNotifier<bool> _isHovering = ValueNotifier<bool>(false);

  LoginPage({super.key});

  void _performLogin(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Successfully logged in, navigate to the home page

      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      // Handle login failure
      print('Login failed: $e');
      // Show a SnackBar with the error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed: Check your email or password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.startbtn,
              style: TextStyle(
                  fontSize: 26.0, color: Color.fromARGB(255, 255, 255, 255))),
          backgroundColor:
              const Color.fromARGB(255, 7, 107, 35), // Made app bar transparent
          elevation: 0,
          actions: [
            DropdownMenu(
              textStyle: TextStyle(
                color: Colors.white,
              ),
              initialSelection: Text(
                context.watch<LanguageProvider>().selectedLocale.languageCode,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onSelected: (value) {
                context
                    .read<LanguageProvider>()
                    .changeLanguage(value as String);
              },
              dropdownMenuEntries: LanguageProvider.languages
                  .map((language) => DropdownMenuEntry(
                      value: language['locale'], label: language['name']))
                  .toList(),
            ),
          ]),
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
                Image.asset('assets/login.png', height: 180.0),
                const SizedBox(height: 20),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.emailHint,
                      labelStyle: const TextStyle(
                          fontSize: 20.0, color: Color.fromARGB(255, 0, 0, 0)),
                      fillColor: Colors.white.withOpacity(
                          0.5), // Added background color to the text field
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(
                        fontSize: 20.0, color: Color.fromARGB(255, 0, 0, 0)),
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
                      fillColor: Colors.white.withOpacity(
                          0.5), // Added background color to the text field
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    obscureText: true,
                    style: const TextStyle(
                        fontSize: 20.0, color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _performLogin(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 7, 107, 35),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.loginbtn,
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      )),
                ),
                const SizedBox(height: 20),
                Text(AppLocalizations.of(context)!.signupHint,
                    style: TextStyle(
                        fontSize: 18.0, color: Color.fromARGB(255, 0, 0, 0))),
                const SizedBox(height: 10),
                MouseRegion(
                  onEnter: (_) {
                    _isHovering.value = true;
                  },
                  onExit: (_) {
                    _isHovering.value = false;
                  },
                  child: ValueListenableBuilder(
                    valueListenable: _isHovering,
                    builder: (context, isHovering, child) {
                      return TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignupPage()),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: isHovering
                              ? Colors.white // White background when hovered
                              : null, // Transparent background when not hovered
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.signupbtn,
                          style: TextStyle(
                            fontSize: 18.0,
                            color: isHovering
                                ? const Color.fromARGB(
                                    255, 0, 128, 0) // Green text when hovered
                                : const Color.fromARGB(255, 0, 0,
                                    0), // Black text when not hovered
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
