// about_app_page.dart
import 'package:flutter/material.dart';

class AboutAdPage extends StatelessWidget {
  const AboutAdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Ad'),
      ),
      body: const Center(
        child: Text('Content of About Ad Page'),
      ),
    );
  }
}