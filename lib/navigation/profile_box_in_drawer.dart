import 'package:dvij_flutter/elements/profile_drawer_elements/profile_element_headline_desc.dart';
import 'package:dvij_flutter/elements/profile_drawer_elements/profile_element_logged_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/profile/profile_page.dart';
import 'custom_nav_containter.dart';

class ProfileBoxInDrawer extends StatefulWidget {
  const ProfileBoxInDrawer({super.key});

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

    double drawerWidthPercentage = 0.7;

    return GestureDetector(
      onTap: () {
        // Переход на страницу профиля
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/Profile', // Название маршрута, которое вы задаете в MaterialApp
              (route) => false,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_user != null && _isEmailVerified)

              ProfileElementLoggedUser(
                imageUrl: _user!.photoURL ?? '',
                name: _user!.displayName ?? '',
                email: _user!.email ?? '',
                widthPercentage: drawerWidthPercentage,
              )

            else if (_user != null && !_isEmailVerified)

              ProfileElementHeadlineDesc(
                widthPercentage: drawerWidthPercentage,
                headline: 'Подтверди почту',
                description: 'Миссия подтверждения активирована! Проверь свой Email – мы отправили тебе важное письмо. Следуй инструкции чтобы активировать аккаунт!',
                icon: const Icon(Icons.warning)
              )

            else

              ProfileElementHeadlineDesc(
                  widthPercentage: drawerWidthPercentage,
                  headline: 'Регистрация / вход',
                  description: 'Привет, дружище! Для полного доступа ко всем функциям приложения не забудь войти в аккаунт. Ждем тебя!',
                  icon: const Icon(Icons.login),
              )

          ],
        ),
      ),
    );
  }
}