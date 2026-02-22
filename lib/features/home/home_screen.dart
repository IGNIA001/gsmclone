import 'package:flutter/material.dart';
import '../../shared/export_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GSM Clone Home")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Welcome back!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Compare the latest mobile chipsets and save your favorites offline."),
            const Spacer(),
            const Text("Export your favorites locally:"),
            const SizedBox(height: 10),
            const ExportButton(), // Your locally stored data export
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}