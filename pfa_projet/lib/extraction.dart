import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'api_service.dart'; // Import ApiService to access saveCardData method
import 'signup_screen.dart'; // Import SignUpScreen to navigate after logout

class ExtractionPage extends StatefulWidget {
  const ExtractionPage({Key? key}) : super(key: key);

  @override
  _ExtractionPageState createState() => _ExtractionPageState();
}

class _ExtractionPageState extends State<ExtractionPage> {
  File? _imageFile;
  String _extractedData = '';
  final ImagePicker _picker = ImagePicker();

  // List of static keywords to filter out
  final List<String> staticKeywords = [
    "CARTE",
    "D'ÉTUDIANT",
    "EMSI",
    "BOUIZGAREN",
    "ETUDIANT",
    "MSI",
    "DETUDIANT",
    "EMASI",
    "EM",
    "SI",
    "ESP",
    "EASI",
    "BOU",
    "ZGA",
    "GAREN",
    "REN",
    "ZGAREN",
    "BOUZGAREN",
    "GAR",
    "ZGA",
    "IZG",
    "MISI",
    "EMISI",
    "ASI",
    "EMAS",
  ];

  // Static data to always store
  final String staticCardType = "CARTE D'ÉTUDIANT";
  final String staticSchoolName = "École Marocaine des Sciences de l'Ingénieur";
  final String staticShortSchoolName = "EMSI";
  final String staticAddress = "5 Lot. BOUIZGAREN - Route de Safi - Marrakech";
  final String staticPhone = "05 24 42 22 22";

  // Method to handle logout
  Future<void> _logout(BuildContext context) async {
    // Clear the tokens using ApiService
    await ApiService.logout();

    // Navigate to the SignUpScreen after logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignUpScreen()),
    );
  }

  // Method to pick or capture an image
  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _extractedData = 'Analyse de l\'image en cours...';
      });
      _processImage(_imageFile!);
    }
  }

  // Method to process the image with Google ML Kit
  Future<void> _processImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      String fullText = recognizedText.text;

      // Extract and filter uppercase words from the first code logic
      String filteredText = _extractAndFilterNames(fullText);

      // Regular expressions to extract other data
      final yearPattern = RegExp(r'\b\d{4}-\d{4}\b');
      final levelPattern = RegExp(r'\b\d+ème Année\b');

      // Extraction of other data
      String year = yearPattern.stringMatch(fullText) ?? 'Non trouvé';
      String level = levelPattern.stringMatch(fullText) ?? 'Non trouvé';

      // Save the extracted data and static data
      await _saveCardData(year, level, filteredText);

      setState(() {
        _extractedData = '''
Type de carte : $staticCardType
Nom court de l'école : $staticShortSchoolName
Nom complet de l'école : $staticSchoolName
Adresse : $staticAddress
Téléphone : $staticPhone
Année scolaire : $year
Nom complet de l'étudiant : $filteredText
Niveau d'études : $level
        ''';
      });
    } catch (e) {
      setState(() {
        _extractedData = 'Erreur lors de l\'analyse de l\'image : $e';
      });
    } finally {
      textRecognizer.close();
    }
  }

  // Method to extract and filter uppercase words (from the first code)
  String _extractAndFilterNames(String fullText) {
    // Regex to extract uppercase words without accents or special characters
    final RegExp regex = RegExp(r'\b[A-Z]{2,}\b');
    final List<String> uppercaseWords =
        regex.allMatches(fullText).map((match) => match.group(0)!).toList();

    // Filter out static keywords
    final filteredWords =
        uppercaseWords.where((word) => !staticKeywords.contains(word)).toList();

    // Combine remaining words into a single string (e.g., for a full name)
    return filteredWords.join(' ');
  }

  // Method to save the data (both static and dynamic) after extraction
  Future<void> _saveCardData(
      String year, String level, String studentName) async {
    try {
      // Ensure address is not null or empty
      String addressToSave =
          staticAddress.isNotEmpty ? staticAddress : 'Adresse non fournie';

      // Save the static and extracted data using ApiService
      await ApiService.saveCardData(
        staticCardType,
        staticShortSchoolName,
        staticSchoolName,
        addressToSave, // Ensure address is passed
        staticPhone,
        year,
        studentName,
        level,
      );
    } catch (e) {
      // Handle any errors during the data saving process
      print('Error saving card data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Carte Étudiant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => _getImage(ImageSource.gallery),
              child: const Text('Télécharger une image'),
            ),
            ElevatedButton(
              onPressed: () => _getImage(ImageSource.camera),
              child: const Text('Prendre une photo'),
            ),
            const SizedBox(height: 20),
            _imageFile != null
                ? Image.file(
                    _imageFile!,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : const Placeholder(
                    fallbackHeight: 200,
                    fallbackWidth: double.infinity,
                  ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _extractedData,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
