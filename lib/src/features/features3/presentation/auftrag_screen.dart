import 'package:flutter/material.dart';
import 'package:meetkoch/src/features/features3/presentation/screen3/auftrag_liste.dart';

class AuftragScreen extends StatelessWidget {
  const AuftragScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF4B2F3E),
                Color(0xFFB16F92),
              ],
            ),
          ),
          child: const AuftraegeListe(),
        ),
      ),
    );
  }
}
