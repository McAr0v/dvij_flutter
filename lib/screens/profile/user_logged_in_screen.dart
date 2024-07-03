import 'package:dvij_flutter/elements/buttons/custom_only_text_button.dart';
import 'package:dvij_flutter/elements/exit_dialog/exit_dialog.dart';
import 'package:dvij_flutter/screens/profile/edit_profile_screen.dart';
import 'package:dvij_flutter/widgets_global/text_widgets/text_with_icon_and_divider.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:dvij_flutter/elements/custom_snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../cities/city_class.dart';
import '../../current_user/genders_class.dart';
import '../../current_user/user_class.dart';
import '../../dates/date_mixin.dart';
import '../../elements/loading_screen.dart';

// --- ЭКРАН ЗАЛОГИНЕВШЕГОСЯ ПОЛЬЗОВАТЕЛЯ -----

class UserLoggedInScreen extends StatefulWidget {
  const UserLoggedInScreen({Key? key}) : super(key: key);

  @override
  UserLoggedInScreenState createState() => UserLoggedInScreenState();
}

class UserLoggedInScreenState extends State<UserLoggedInScreen> {

  UserCustom userInfo = UserCustom.empty();
  City chosenCity = City(name: '', id: '');
  Genders chosenGender = Genders();
  bool loading = true;
  bool logOut = false;

  @override
  void initState() {
    super.initState();
    fetchAndSetData();
  }


  // --- Функция получения и ввода данных ---

  Future<void> fetchAndSetData() async {
    setState(() {
      loading = true;
    });

    userInfo = UserCustom.currentUser!;

    setState(() {
      loading = false;
    });
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
            else if (logOut) const LoadingScreen(loadingText: 'Выходим из профиля',)
            else ListView(

              // ---- Экран профиля -----

            children: [

              Container(
                decoration: const BoxDecoration(
                  color: AppColors.greyOnBackground, // Убедитесь, что цвет указан здесь, а не в свойстве color Container
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(30), bottomLeft: Radius.circular(30)), // Здесь устанавливается радиус скругления углов
                ),
                padding: const EdgeInsets.all(50),
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.greyBackground,
                      radius: 80,
                      backgroundImage: NetworkImage(userInfo.avatar),
                    ),

                    const SizedBox(height: 20,),

                    Text(
                      '${userInfo.name} ${userInfo.lastname}',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 5,),

                    Text(
                      userInfo.email,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.greyText),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        CustomOnlyTextButton(
                          buttonText: 'Редактировать',
                          onTap: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditProfileScreen(userInfo: userInfo))
                            );
                          },
                          textColor: AppColors.brandColor,
                        ),


                        const SizedBox(width: 40,),

                        CustomOnlyTextButton(
                          buttonText: 'Выйти из профиля',
                          onTap: () async {

                            bool? confirmed = await exitDialog(context, "Ты правда хочешь уйти от нас?" , 'Да', 'Нет', 'Выход из профиля');

                            // ---- Если пользователь нажал ВЫЙТИ ----

                            if (confirmed != null && confirmed) {

                              setState(() {
                                logOut = true;
                              });

                              String result = await UserCustom.empty().signOut();

                              if (result == 'ok') {
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
                              setState(() {
                                logOut = false;
                              });
                            }
                          },
                          textColor: AppColors.attentionRed,
                        ),

                      ],
                    )

                  ],
                ),
              ),

              // --- Контент под аватаркой -----

              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text('Контактная информация', style: Theme.of(context).textTheme.titleMedium,),
                    const SizedBox(height: 5.0),
                    Text('Для автоматического заполнения полей при создании мероприятий или акций', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.greyText),),
                    const SizedBox(height: 20.0),
                    //const SizedBox(height: 16.0),

                    TextWithIconAndDivider(
                        headline: userInfo.city.name.isNotEmpty ? userInfo.city.name : 'Город не указан',
                        description: 'Город',
                        icon: FontAwesomeIcons.locationDot,
                        iconSize: 20,
                    ),

                    TextWithIconAndDivider(
                        headline: userInfo.phone.isNotEmpty ? userInfo.phone : 'Телефон не указан',
                        description: 'Контактный телефон',
                        icon: FontAwesomeIcons.phone,
                        iconSize: 20,
                    ),
                    TextWithIconAndDivider(
                        headline: userInfo.telegram.isNotEmpty ? userInfo.telegram : 'Аккаунт Telegram не указан',
                        description: 'Telegram',
                        icon: FontAwesomeIcons.telegram
                    ),
                    TextWithIconAndDivider(
                        headline: userInfo.whatsapp.isNotEmpty ? userInfo.whatsapp : 'Аккаунт Whatsapp не указан',
                        description: 'Whatsapp',
                        icon: FontAwesomeIcons.whatsapp
                    ),
                    TextWithIconAndDivider(
                        headline: userInfo.instagram.isNotEmpty ? userInfo.instagram : 'Аккаунт Instagram не указан',
                        description: 'Instagram',
                        icon: FontAwesomeIcons.instagram
                    ),
                    TextWithIconAndDivider(
                        headline: userInfo.birthDate != DateTime(2100) ? DateMixin.getHumanDateFromDateTime(userInfo.birthDate) : 'Дата рождения не указана',
                        description: 'Дата рождения',
                        icon: FontAwesomeIcons.cakeCandles
                    ),
                    TextWithIconAndDivider(
                        headline: userInfo.gender.genderEnum != GenderEnum.notChosen ? userInfo.gender.getGenderString(needTranslate: true) : 'Пол не указан',
                        description: 'Пол',
                        icon: FontAwesomeIcons.genderless
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