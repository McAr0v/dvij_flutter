import 'package:dvij_flutter/elements/profile_drawer_elements/profile_element_headline_desc.dart';
import 'package:dvij_flutter/elements/profile_drawer_elements/profile_element_logged_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../classes/user_class.dart';
import '../classes/user_class.dart';
import '../database_firebase/user_database.dart';
import '../themes/app_colors.dart';

class ProfileBoxInDrawer extends StatefulWidget {
  final UserCustom userInfo;

  const ProfileBoxInDrawer({required this.userInfo, Key? key}) : super(key: key);

  @override
  _ProfileBoxInDrawerState createState() => _ProfileBoxInDrawerState();
}

// --- ВИДЖЕТ РАЗДЕЛА ПОЛЬЗОВАТЕЛЯ В DRAWER ----

class _ProfileBoxInDrawerState extends State<ProfileBoxInDrawer> {
  // Данные о пользователе
  User? _user;
  // Переключатель - подтвердил ли почту пользователь или нет
  bool _isEmailVerified = false;
  // Инициализируем базу данных пользователя
  //final UserDatabase userDatabase = UserDatabase();

  late UserCustom userNow;

  // Инициализируем состояние пользователя
  @override
  void initState() {
    super.initState();
    userNow = widget.userInfo;
    _getUser();
  }

  // --- Функция получения данных по пользователе ----

  Future<void> _getUser() async {
    // Инициализируем пользователя
    User? user = FirebaseAuth.instance.currentUser;

    // Если вошел, то меняем данные в нужные переменные
    if (user != null) {
      setState(() {
        _user = user;
        _isEmailVerified = user.emailVerified;
        userNow = UserCustom.currentUser!;
      });
    }
  }

  // --- САМ ВИДЖЕТ ОТОБРАЖЕНИЯ РАЗДЕЛА О ПОЛЬЗОВАТЕЛЕ -----

  @override
  Widget build(BuildContext context) {

    // Ширина виджета в зависимости от ширины экрана
    double drawerWidthPercentage = 0.7;

    return GestureDetector(
      onTap: () {
        // Переход на страницу профиля
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/Profile',
              (route) => false,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            // ---- ОТОБРАЖЕНИЕ РАЗНЫХ ЭЛЕМЕНТОВ, В ЗАВИСИМОТИ ОТ СОСТОЯНИЯ ПОЛЬЗОВАТЕЛЯ

            // ---- Если пользователь вошел и подтвердил почту

            if (_user != null && _isEmailVerified)

              ProfileElementLoggedUser(
                imageUrl: userNow.avatar ?? '',
                name: '${widget.userInfo.name} ${widget.userInfo.lastname}' ?? '',
                email: _user!.email ?? '',
                widthPercentage: drawerWidthPercentage,
              )


            else if (_user != null && !_isEmailVerified)
            // ---- Если зашел, но не подтвердил почту

              ProfileElementHeadlineDesc(
                widthPercentage: drawerWidthPercentage,
                headline: 'Подтверди почту',
                description: 'Миссия подтверждения активирована! Проверь свой Email – мы отправили тебе важное письмо. Следуй инструкции чтобы активировать аккаунт!',
                icon: const Icon(Icons.warning, color: AppColors.brandColor,)
              )


            else
            // ---- Если даже не зашел в аккаунт

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