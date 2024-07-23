import 'package:flutter/material.dart';

class Testtest extends StatelessWidget {
  const Testtest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aufträge'),
        backgroundColor: Colors.grey[300],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBox('Erste Box',
                    width: 400, height: 300, borderRadius: 30.0),
                SizedBox(height: 20),
                _buildBox('Zweite Box',
                    width: 250, height: 120, borderRadius: 20.0),
                SizedBox(height: 100),
                _buildBox('Dritte Box',
                    width: 300, height: 50, borderRadius: 40.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBox(String text,
      {double width = 200, double height = 100, double borderRadius = 20.0}) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
      ),
    );
  }
}
