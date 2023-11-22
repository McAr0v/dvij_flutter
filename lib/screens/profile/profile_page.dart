
import 'package:dvij_flutter/screens/profile/user_logged_in_screen.dart';
import 'package:dvij_flutter/screens/profile/user_not_sign_in_screen.dart';
import 'package:dvij_flutter/screens/profile/user_not_verified.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {

    if (_auth.currentUser?.uid != null && !_auth.currentUser!.emailVerified){

      return const UserNotVerifiedScreen();

    } else if (_auth.currentUser?.uid == null){

      return const UserNotSignInScreen();

    } else {

      return UserLoggedInScreen();

    }
  }
}