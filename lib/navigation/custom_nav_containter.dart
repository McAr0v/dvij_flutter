import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_user;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../classes/user_class.dart';
import '../database_firebase/user_database.dart';
import 'custom_drawer.dart';
import 'custom_bottom_navigation_bar.dart';
import 'package:dvij_flutter/screens/profile/profile_page.dart';
import 'package:dvij_flutter/screens/events/events_page.dart';
import 'package:dvij_flutter/screens/places/places_page.dart';
import 'package:dvij_flutter/screens/promotions/promotions_page.dart';
import '../../classes/user_class.dart' as local_user;

// ---- ВСЯ НАВИГАЦИЯ ЗДЕСЬ! ----

class CustomNavContainer extends StatefulWidget {
  final int initialTabIndex;

  const CustomNavContainer({Key? key, this.initialTabIndex = 1})
      : super(key: key);

  @override
  _CustomNavContainerState createState() => _CustomNavContainerState();
}

class _CustomNavContainerState extends State<CustomNavContainer>
    with SingleTickerProviderStateMixin {
  // Переменная, управляющая табами
  late TabController _tabController;
  // Названия табов
  final List<String> _tabTitles = ['Профиль', 'Мероприятия', 'Места', 'Акции'];

  // Инициализируем базу данных о пользователе
  //final UserDatabase userDatabase = UserDatabase();

  late firebase_user.User? _user; // Объявление пользователя

  // Изначальная информация о пользователе
  local_user.UserCustom userInfo = local_user.UserCustom(
      uid: '',
      email: '',
      role: '1113',
      name: '',
      lastname: '',
      phone: '',
      whatsapp: '',
      telegram: '',
      instagram: '',
      city: '',
      birthDate: '',
      gender: '',
      avatar: ''
  );

  // --- ИНИЦИАЛИЗИРУЕМ СОСТОЯНИЕ -----
  @override
  void initState() {
    super.initState();

    // В зависимости от действий, меняем состояние контроллера табов
    _tabController =
        TabController(length: _tabTitles.length, vsync: this, initialIndex: widget.initialTabIndex);

    // --- Слушаем изменение статуса пользователя - залогинился и тд.
    FirebaseAuth.instance.authStateChanges().listen((firebase_user.User? user) {

      // Если что-то изменилось, в пользователя присваиваем новый статус пользователя
      setState(() {
        if (user != null) {
          _user = user;
        } else {
          _user = null;
        }

      });

      // Если пользователь вошел в систему, обновляем userInfo
      if (user != null) {
        userInfo = UserCustom.currentUser!;
      }
    });
  }

  // --- Функция считывания информации о пользователе

  /*Future<void> _updateUserInfo(firebase_user.User user) async {
    userInfo = (await userDatabase.readUserData(user.uid))!;

    // Если считали, устанавливаем данные пользователя
    setState(() {
      userInfo = userInfo;
    });
  }*/

  // --- Сам виджет меню табов ----

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _tabTitles[_tabController.index],
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
      drawer: CustomDrawer(userInfo: userInfo),
      body: TabBarView(
        controller: _tabController,
        children: [
          ProfilePage(),
          const EventsPage(),
          const PlacesPage(),
          const PromotionsPage(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onTabTapped: (index){
          setState(() {
            _tabController.index = index;
          });
        },
        tabController: _tabController,
      ),
    );
  }
}