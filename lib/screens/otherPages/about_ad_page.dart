// about_app_page.dart
import 'package:flutter/material.dart';

class AboutAdPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Ad'),
      ),
      body: Center(
        child: Text('Content of About Ad Page'),
      ),
    );
  }
}