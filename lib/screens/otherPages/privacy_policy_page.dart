// about_app_page.dart
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PrivacyPolicy'),
      ),
      body: const Center(
        child: Text('PrivacyPolicy'),
      ),
    );
  }
}