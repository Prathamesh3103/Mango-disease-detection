import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:maizeplant/language_provider.dart';
import 'package:maizeplant/login_page.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((_) {
    print("Firebase initialized successfully");
  }).catchError((error) {
    print("Failed to initialize Firebase: $error");
  });

  runApp(ChangeNotifierProvider(
    create: (context) => LanguageProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('mr'),
      ],
      locale: context.watch<LanguageProvider>().selectedLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'Mango Plant Disease Detector',
      theme: ThemeData(
        primaryColor: const Color(0xFF4CAF50),
        hintColor: const Color(0xFF8BC34A),
        cardColor: const Color(0xFFF44336),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Color(0xFF2E7D32),
            fontSize: 30.0,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF2E7D32),
            fontSize: 24.0,
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(
              secondary: const Color(0xFF8BC34A),
            )
            .copyWith(surface: const Color(0xFFA5D6A7)),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) =>
            const WelcomePage(), // Use WelcomePage as the initial page
        '/home': (context) => const HomePage(),
      },
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 103, 213, 114), // Greenery color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/mango.png', // Your logo asset
              height: 500, // Height of the logo
            ),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color.fromARGB(255, 8, 68, 3), // Green background
                padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20), // Adjust the padding to increase button size
              ),
              child: Text(
                AppLocalizations.of(context)!.startbtn,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
