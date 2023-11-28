import 'package:dvij_flutter/database_firebase/user_database.dart';
import 'package:dvij_flutter/elements/headline_and_desc.dart';
import 'package:dvij_flutter/screens/profile/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:dvij_flutter/elements/custom_button.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:dvij_flutter/authentication/auth_with_email.dart';
import 'package:dvij_flutter/elements/custom_snack_bar.dart';
import 'package:dvij_flutter/elements/pop_up_dialog.dart';
import '../../classes/user_class.dart' as local_user;
import '../../elements/loading_screen.dart';

class UserLoggedInScreen extends StatefulWidget {
  UserLoggedInScreen({Key? key}) : super(key: key);

  @override
  _UserLoggedInScreenState createState() => _UserLoggedInScreenState();
}

class _UserLoggedInScreenState extends State<UserLoggedInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthWithEmail authWithEmail = AuthWithEmail();
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  final UserDatabase userDatabase = UserDatabase();
  String? uid = '';
  String? userEmail = '';
  local_user.User userInfo = local_user.User(
      uid: '',
      role: '1113',
      name: '',
      lastname: '',
      phone: '',
      whatsapp: '',
      telegram: '',
      instagram: '',
      city: '',
      birthDate: '',
      sex: '',
      avatar: ''
  );

  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchAndSetData();
  }



  Future<void> fetchAndSetData() async {
    try {
      userEmail = _auth.currentUser?.email;
      uid = _auth.currentUser?.uid;
      userInfo = (await userDatabase.readUserData(uid!))!;
      setState(() {
        loading = false;
      });
    } catch (e) {
      print('Error initializing data: $e');
    }
  }

  void navigateToProfile() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/Events',
          (route) => false,
    );
  }



  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack (
          children: [
          if (loading || userInfo.avatar == '') const LoadingScreen(loadingText: 'Подожди, идет загрузка данных',)
          else ListView(
            children: [
              if (userInfo.avatar != '') // Проверяем, есть ли ссылка на аватар
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
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      }
                    },
                  ),
                ),

              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

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
                    const SizedBox(height: 16.0),
                    if (userEmail != '' && userEmail != null) HeadlineAndDesc(headline: userEmail!, description: 'email профиля'),
                    const SizedBox(height: 16.0),
                    if (userInfo.city != '') HeadlineAndDesc(headline: userInfo.city, description: 'Город'),
                    const SizedBox(height: 16.0),
                    if (userInfo.phone != '') HeadlineAndDesc(headline: userInfo.phone, description: 'Телефон для связи'),
                    const SizedBox(height: 16.0),
                    if (userInfo.telegram != '') HeadlineAndDesc(headline: userInfo.telegram, description: 'Telegram'),
                    const SizedBox(height: 16.0),
                    if (userInfo.whatsapp != '') HeadlineAndDesc(headline: userInfo.whatsapp, description: 'Whatsapp'),
                    const SizedBox(height: 16.0),
                    if (userInfo.instagram != '') HeadlineAndDesc(headline: userInfo.instagram, description: 'Instagram'),
                    const SizedBox(height: 16.0),
                    if (userInfo.birthDate != '') HeadlineAndDesc(headline: userInfo.birthDate, description: 'Дата рождения'),
                    const SizedBox(height: 16.0),
                    if (userInfo.sex != '') HeadlineAndDesc(headline: userInfo.sex, description: 'Пол'),


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

                    const SizedBox(height: 16.0),
                    CustomButton(
                      state: 'error',
                      buttonText: 'Выйти из профиля',
                      onTapMethod: () async {
                        bool? confirmed = await PopUpDialog.showConfirmationDialog(
                          context,
                          title: "Вы действительно хотите выйти?",
                          backgroundColor: AppColors.greyBackground,
                          confirmButtonText: "Да",
                          cancelButtonText: "Нет",
                        );
                        if (confirmed != null && confirmed) {
                          String result = await authWithEmail.signOut();

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