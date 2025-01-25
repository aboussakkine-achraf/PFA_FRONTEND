import 'package:flutter/material.dart';
import 'signup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCR Carte Étudiant',
      home: SignUpScreen(), // Utilisation de la page Extraction
    );
  }
}
