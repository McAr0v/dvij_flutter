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
  bool _isEmailVerified = false;

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
        _isEmailVerified = user.emailVerified;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    double drawerWidthPercentage = 0.75;

    return GestureDetector(
      onTap: () {
        if (_user != null && _isEmailVerified) {
          // Переход на страницу профиля
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/Profile', // Название маршрута, которое вы задаете в MaterialApp
                (route) => false,
          );
        } else if (_user == null) {
          // Переход на страницу профиля
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/Profile', // Название маршрута, которое вы задаете в MaterialApp
                (route) => false,
          );
        }


      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_user != null && _isEmailVerified)
              Container(
                width: MediaQuery.of(context).size.width * drawerWidthPercentage,
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(_user!.photoURL ?? ''),
                        ),
                        SizedBox(width: 15.0),

                        Column(

                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              //_user!.displayName ?? '',
                              'Имя и фамилия',
                              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _user!.email ?? '',
                              style: TextStyle(fontSize: 14.0),
                            ),
                          ],
                        ),

                        SizedBox(width: 15.0),
                      ],
                    ),

                    Icon(Icons.edit),

                  ],
                ) ,

                )

            else if (_user != null && !_isEmailVerified)
              Text(
                'Для успешного завершения регистрации подтвердите свою почту',
                style: TextStyle(fontSize: 14.0),
              )
            else
              Row(
                children: [
                  Text(
                    'Регистрация / вход',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(width: 16.0),
                  Icon(Icons.login),
                ],
              ),
          ],
        ),
      ),
    );
  }
}