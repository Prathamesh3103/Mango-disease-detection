import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:maizeplant/generate_pdf.dart';
import 'package:maizeplant/home_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maizeplant/language_provider.dart';
import 'package:provider/provider.dart';

class DisplayImagePage extends StatefulWidget {
  final Uint8List imageData;
  final String prediction;
  final double confidenceLevel;

  const DisplayImagePage({
    super.key,
    required this.imageData,
    required this.prediction,
    required this.confidenceLevel,
  });

  @override
  _DisplayImagePageState createState() => _DisplayImagePageState();
}

class _DisplayImagePageState extends State<DisplayImagePage> {
  bool _showSymptoms = false;
  bool _showTreatments = false;

  String _getSymptoms(String disease) {
    Map<String, String> diseaseSymptoms = {
      "Blight":
          "1. White powdery spots appear on leaves and young shoots.\n2. Infected leaves may curl and distort as disease spreads.\n3. Flower panicles show white fungal growth on surface.\n4. Blossoms drop prematurely, reducing fruit formation significantly.\n5. Young fruits turn black and fall off early.\n6. Growth of affected parts becomes stunted or deformed.",
      "Common_Rust":
          "1. Orange pustules on leaves\n2. Yellowing of leaves\n3. Stunted growth\n4. Twisted and distorted leaves\n5. Powdery orange spores on stems\n6. Reduced fruit quality.",
      "Gray_Leaf_Spot":
          "1. Grayish spots on leaves\n2. Older leaves turning yellow\n3. Lesions along the veins of the leaves\n4. Spots becoming necrotic over time\n5. Premature leaf drop\n6. Reduced plant vigor.",
      "Healthy": "No symptoms. The plant is healthy.",
    };

    return diseaseSymptoms[disease] ?? "Symptoms not available.";
  }

  String _getTreatments(String disease) {
    Map<String, String> diseaseTreatments = {
      "Blight":
          "1. Spray sulfur-based fungicides during early flowering stage.\n2. Apply systemic fungicides like hexaconazole or carbendazim.\n3. Prune infected parts to improve air circulation.\n4. Avoid excessive nitrogen fertilizers that promote soft growth.\n5. Ensure proper spacing between trees to reduce humidity.\n6. Repeat fungicide sprays at 10-15 day intervals if needed.",
      "Common_Rust":
          "1. Apply fungicides\n2. Remove affected leaves\n3. Use rust-resistant varieties of plants\n4. Apply appropriate fertilizers to enhance plant resistance\n5. Implement crop rotation to reduce infection\n6. Manage weeds which can harbor rust pathogens.",
      "Gray_Leaf_Spot":
          "1. Apply fungicides\n2. Manage plant debris to reduce infection sources\n3. Use resistant varieties of plants\n4. Implement crop rotation to break disease cycle\n5. Maintain proper plant spacing to improve air circulation\n6. Apply foliar fungicides at the first sign of infection.",
      "Healthy": "No treatments required. The plant is healthy.",
    };

    return diseaseTreatments[disease] ?? "Treatments not available.";
  }

  String getDisplayPrediction(String prediction) {
    final overrides = {
      'blight': 'Powdery Mildew',
      'common rust': 'Sooty Mould',
      'gray leaf spot': 'Anthracnose',
    };
    return overrides[prediction.toLowerCase()] ?? prediction;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.imgDisplayTitle,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.green[700],
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.memory(widget.imageData),
              const SizedBox(height: 20.0),
              Text(
                AppLocalizations.of(context)!.prediction +
                    ': ' +
                    ({
                          'blight': 'Powdery Mildew',
                          'common rust': 'Sooty Mould',
                          'gray leaf spot': 'Anthracnose',
                        }[widget.prediction.toLowerCase()] ??
                        widget.prediction),
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                AppLocalizations.of(context)!.confidencelvl +
                    ': ${widget.confidenceLevel.toStringAsFixed(2)} %',
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showSymptoms = !_showSymptoms;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  AppLocalizations.of(context)!.symptomsbtn,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              if (_showSymptoms)
                Text(
                  _getSymptoms(widget.prediction),
                  style: const TextStyle(fontSize: 16.0),
                ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showTreatments = !_showTreatments;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  AppLocalizations.of(context)!.treatmentsbtn,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              if (_showTreatments)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    _getTreatments(widget.prediction),
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  await GeneratePdfPage.generatePdf(
                    imageData: widget.imageData,
                    prediction: getDisplayPrediction(widget.prediction),
                    confidenceLevel: widget.confidenceLevel,
                    symptoms: _getSymptoms(widget.prediction),
                    treatments: _getTreatments(widget.prediction),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  AppLocalizations.of(context)!.pdfbtn,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        },
        backgroundColor: Colors.green[700],
        tooltip: 'Home',
        child: const Icon(Icons.home, color: Colors.white),
      ),
    );
  }
}
