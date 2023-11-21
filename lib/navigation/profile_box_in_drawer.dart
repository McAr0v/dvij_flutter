import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/profile/profile_page.dart';
import 'custom_nav_containter.dart';

class ProfileBoxInDrawer extends StatefulWidget {
  @override
  _ProfileBoxInDrawerState createState() => _ProfileBoxInDrawerState();
}

class _ProfileBoxInDrawerState extends State<ProfileBoxInDrawer> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Переход на страницу профиля
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CustomNavContainer())
        );
      },
      child: UserAccountsDrawerHeader(
        accountName: _user != null ? Text(_user!.displayName ?? '') : null,
        accountEmail: _user != null ? Text(_user!.email ?? '') : null,
        currentAccountPicture: _user != null
            ? CircleAvatar(
          backgroundImage: NetworkImage(_user!.photoURL ?? ''),
        )
            : null,
      ),
    );
  }
}