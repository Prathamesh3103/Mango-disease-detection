import 'dart:typed_data';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:maizeplant/feedback_page.dart';
import 'package:maizeplant/language_provider.dart';
import 'package:maizeplant/login_page.dart';
import 'package:provider/provider.dart';
import 'display_image_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Stream<User?> userStream = FirebaseAuth.instance.authStateChanges();
  User? _user;
  String? _fullName;

  @override
  void initState() {
    super.initState();

    FirebaseDatabase.instanceFor(
      app: Firebase.app(), // Use the default Firebase app instance
      databaseURL:
          'https://maize-plant-e1ae0-default-rtdb.asia-southeast1.firebasedatabase.app',
    );
    userStream.listen((user) {
      setState(() {
        _user = user;
        _fetchFullName();
      });
    });
  }

  Future<void> _fetchFullName() async {
    if (_user != null) {
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child('users').child(_user!.uid);
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.value != null) {
        Map<String, dynamic> userData = snapshot.value as Map<String, dynamic>;
        setState(() {
          _fullName = userData['full_name'];
        });
      }
    }
  }

  Uint8List? _imageData;
  String? _prediction;
  double? _confidenceLevel;
  final bool _isModelReady = true;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage == null) return;
      final imageData = await pickedImage.readAsBytes();
      setState(() {
        _imageData = imageData;
      });
      print('Image picked successfully.');
    } catch (e) {
      print('Failed to pick and process image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick and process image: $e')),
      );
    }
  }

  Future<void> _captureImage() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedImage == null) return;
      final imageData = await pickedImage.readAsBytes();
      setState(() {
        _imageData = imageData;
      });
      print('Image captured successfully.');
    } catch (e) {
      print('Failed to capture and process image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture and process image: $e')),
      );
    }
  }

  Future<void> _runModelOnImage() async {
    if (_isModelReady && _imageData != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://maizediseasepredict.onrender.com/predict'),
        );

        request.files.add(http.MultipartFile.fromBytes('file', _imageData!,
            filename: 'image.jpg'));

        var response = await request.send();
        var result = await response.stream.bytesToString();
        var jsonResult = json.decode(result);
        var prediction = jsonResult['prediction'] as String;
        var confidenceLevel = jsonResult['confidence_level'] as double;

        setState(() {
          _prediction = prediction;
          _confidenceLevel = confidenceLevel * 100;
          _isLoading = false;
        });

        print('Model inference successful.');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DisplayImagePage(
              imageData: _imageData!,
              prediction: _prediction!,
              confidenceLevel: _confidenceLevel!,
            ),
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print('Failed to run model: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to run model: $e')),
        );
      }
    } else {
      print('Model is not ready or image is null.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Model is not ready or image is null.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.homepageTitle,
          style: TextStyle(fontSize: 26.0, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 7, 107, 35),
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
              context.read<LanguageProvider>().changeLanguage(value as String);
            },
            dropdownMenuEntries: LanguageProvider.languages
                .map((language) => DropdownMenuEntry(
                    value: language['locale'], label: language['name']))
                .toList(),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
              // Redirect to login page
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 7, 107, 35),
              ),
              accountName: Text(
                _fullName ?? AppLocalizations.of(context)!.welcome,
                style: const TextStyle(
                    fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                _user?.email ?? 'No Email',
                style: const TextStyle(fontSize: 18.0),
              ),
              currentAccountPicture: CircleAvatar(
                radius: 50.0,
                backgroundImage: _user?.photoURL != null
                    ? NetworkImage(_user!.photoURL!)
                    : const NetworkImage(
                        'https://static.vecteezy.com/system/resources/previews/005/153/495/original/cartoon-builder-mascot-logo-a-builder-man-character-holding-a-hat-logo-templates-for-business-identity-architecture-property-real-estate-residential-solutions-home-staging-building-engineers-vector.jpg',
                      ),
              ),
            ),
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.abtheading,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.infoheading,
                style: TextStyle(fontSize: 16.0),
              ),
              subtitle: Text(
                AppLocalizations.of(context)!.info,
                style: TextStyle(fontSize: 14.0),
              ),
              onTap: () {
                // You can navigate to an 'About' page with more information about the app here
              },
            ),
            const Divider(),
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.feedbackbtn,
                style: TextStyle(fontSize: 16.0),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FeedbackPage()));
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/cover3.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const CircularProgressIndicator(
                color: Colors.white,
              ),
            if (_imageData != null)
              Image.memory(
                _imageData!,
                frameBuilder: (BuildContext context, Widget child, int? frame,
                    bool wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) {
                    return child;
                  }
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
              ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.pickImagebtn,
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      )),
                ),
                const SizedBox(width: 10.0), // Add some spacing between buttons
                ElevatedButton(
                  onPressed: () => _captureImage(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ), // Call the capture image function
                  child: Text(AppLocalizations.of(context)!.captureImagebtn,
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _runModelOnImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.detectbtn,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  )),
            ),
          ],
        )),
      ),
    );
  }
}
