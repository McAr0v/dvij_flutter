import 'package:dvij_flutter/database_firebase/user_database.dart';
import 'package:dvij_flutter/elements/headline_and_desc.dart';
import 'package:dvij_flutter/methods/date_functions.dart';
import 'package:dvij_flutter/screens/profile/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:dvij_flutter/elements/custom_button.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:dvij_flutter/authentication/auth_with_email.dart';
import 'package:dvij_flutter/elements/custom_snack_bar.dart';
import 'package:dvij_flutter/elements/pop_up_dialog.dart';
import '../../classes/city_class.dart';
import '../../classes/user_class.dart';
import '../../classes/user_class.dart';
import '../../elements/loading_screen.dart';


// --- ЭКРАН ЗАЛОГИНЕВШЕГОСЯ ПОЛЬЗОВАТЕЛЯ -----

class UserLoggedInScreen extends StatefulWidget {
  UserLoggedInScreen({Key? key}) : super(key: key);

  @override
  _UserLoggedInScreenState createState() => _UserLoggedInScreenState();
}

class _UserLoggedInScreenState extends State<UserLoggedInScreen> {
  // --- Инициализируем дополнительные классы ---

  //final UserDatabase userDatabase = UserDatabase();
  //final AuthWithEmail authWithEmail = AuthWithEmail();

  // ---- Инициализируем базу данных ------
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  //final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  // ---- Инициализируем пустые переменные ----

  String? uid = '';
  String? userEmail = '';
  UserCustom userInfo = UserCustom.empty('', '');

  City chosenCity = City(name: '', id: '');

  // --- Переключатель показа экрана загрузки -----

  bool loading = true;

  // ---- Инициализация экрана -----
  @override
  void initState() {
    super.initState();
    // --- Получаем и устанавливаем данные ---
    fetchAndSetData();

  }


  // --- Функция получения и ввода данных ---

  Future<void> fetchAndSetData() async {
    try {

      userInfo = UserCustom.currentUser!;

      // --- Получаем email нашего пользователя
      userEmail = userInfo.email;
      // ---- Получаем uid нашего пользователя
      uid = userInfo.uid;
      // --- Читаем данные пользователя из БД

      chosenCity = await City.getCityById(userInfo.city) as City;

      // ---- Убираем экран загрузки -----
      setState(() {

        loading = false;
      });
    } catch (e) {
      // TODO Сделать обработку ошибок, если не получилось считать данные
    }
  }

  // ---- Функция перехода в профиль ----
  void navigateToProfile() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/Events',
          (route) => false,
    );
  }

  // ---- Функция отображения всплывающих сообщений -----
  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack (
          children: [
            // ---- Экран загрузки ----
            if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка данных',)
            else ListView(

              // ---- Экран профиля -----

            children: [
              if (userInfo.avatar != '') // Проверяем, есть ли ссылка на аватар
                // TODO - Сделать более проработанную проверку аватарки

                Card(
                  child: Image.network(
                    userInfo.avatar, // Предполагаем, что avatar - это строка с URL изображения
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return const LoadingScreen(loadingText: 'Подожди, идет загрузка фото',);
                        // --- БЫЛО ВМЕСТО ЛОАДИНГ СКРИН. НАДО ПОТЕСТИТЬ ---
                        /*const Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );*/
                      }
                    },
                  ),
                ),

              // --- Контент под аватаркой -----

              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // TODO - Такая проверка не пойдет. Иначе пользователь никак не сможет перейти на экран редактирования

                    if (userInfo.name != '') Row(
                      children: [
                        Expanded(
                          child: HeadlineAndDesc(
                            headline: '${userInfo.name} ${userInfo.lastname}',
                            description: 'Имя',
                            textSize: 'big',
                          ),
                        ),
                        const SizedBox(width: 16.0),

                        // --- Кнопка редактирования ----
                        IconButton(
                          icon: Icon(
                              Icons.edit,
                            color: Theme.of(context).colorScheme.background,
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.yellow),
                          ),
                          onPressed: () async {
                            Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditProfileScreen(userInfo: userInfo))
                          );
                        },
                            // Действие при нажатии на кнопку редактирования
                        ),
                      ],
                    ),

                    // ---- Остальные данные пользователя ----

                    const SizedBox(height: 16.0),
                    if (userEmail != '' && userEmail != null) HeadlineAndDesc(headline: userEmail!, description: 'email профиля'),

                    const SizedBox(height: 16.0),
                    if (userInfo.city != '') HeadlineAndDesc(headline: chosenCity.name, description: 'Город'),

                    const SizedBox(height: 16.0),
                    if (userInfo.phone != '') HeadlineAndDesc(headline: userInfo.phone, description: 'Телефон для связи'),

                    const SizedBox(height: 16.0),
                    if (userInfo.telegram != '') HeadlineAndDesc(headline: userInfo.telegram, description: 'Telegram'),

                    const SizedBox(height: 16.0),
                    if (userInfo.whatsapp != '') HeadlineAndDesc(headline: userInfo.whatsapp, description: 'Whatsapp'),

                    const SizedBox(height: 16.0),
                    if (userInfo.instagram != '') HeadlineAndDesc(headline: userInfo.instagram, description: 'Instagram'),

                    if (userInfo.birthDate != '') const SizedBox(height: 16.0),
                    if (userInfo.birthDate != '') HeadlineAndDesc(headline: getHumanDate(userInfo.birthDate, '-'), description: 'Дата рождения'),

                    const SizedBox(height: 16.0),
                    if (userInfo.gender != '') HeadlineAndDesc(headline: userInfo.gender, description: 'Пол'),

                    // TODO - Решить, эта кнопка нужна или нет?
                    const SizedBox(height: 16.0),
                    CustomButton(
                      buttonText: 'Редактировать профиль',
                      onTapMethod: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditProfileScreen(userInfo: userInfo))
                        );
                      },
                    ),

                    // --- Выход из профиля ----

                    const SizedBox(height: 16.0),
                    CustomButton(
                      state: 'error',
                      buttonText: 'Выйти из профиля',
                      onTapMethod: () async {

                        // --- Открываем диалог ----
                        // TODO - Доделать экран диалога!!!

                        bool? confirmed = await PopUpDialog.showConfirmationDialog(
                          context,
                          title: "Вы действительно хотите выйти?",
                          backgroundColor: AppColors.greyBackground,
                          confirmButtonText: "Да",
                          cancelButtonText: "Нет",
                        );

                        // ---- Если пользователь нажал ВЫЙТИ ----

                        if (confirmed != null && confirmed) {

                          //TODO Сделать экран загрузки при выходе их профила
                          // --- Функция выхода из профиля
                          String result = await UserCustom.signOut();

                          if (result == 'success') {
                            showSnackBar(
                              'Как жаль, что ты уходишь! В любом случае, мы всегда будем рады видеть тебя снова. До скорой встречи!',
                              Colors.green,
                              5,
                            );
                            navigateToProfile();
                          } else {
                            showSnackBar(
                              'Что-то пошло не так при попытке выхода. Возможно, это заговор темных сил! Пожалуйста, попробуй еще раз, и если проблема сохранится, обратись в нашу техподдержку.',
                              AppColors.attentionRed,
                              5,
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          )
       ],
      )
    );
  }
}