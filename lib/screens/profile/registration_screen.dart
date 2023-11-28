import 'package:dvij_flutter/database_firebase/user_database.dart';
import 'package:dvij_flutter/elements/custom_button.dart';
import 'package:dvij_flutter/elements/loading_screen.dart';
import 'package:dvij_flutter/elements/text_with_link.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/authentication/auth_with_email.dart';
import '../../app_state/appstate.dart';
import '../../classes/user_class.dart';
import '../../elements/custom_snack_bar.dart';
import '../../themes/app_colors.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late final AppState appState;
  final AuthWithEmail authWithEmail = AuthWithEmail();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final UserDatabase userDatabase = UserDatabase();


  void navigateToProfile() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/Profile', // Название маршрута, которое вы задаете в MaterialApp
          (route) => false,
    );
  }

  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  bool showLogInButton = false;
  bool privacyPolicyChecked = false;
  bool loading = false;

  void updateShowLogInButton(bool newValue) {
    setState(() {
      showLogInButton = newValue;
    });
  }

  void togglePrivacyPolicyChecked() {
    setState(() {
      privacyPolicyChecked = !privacyPolicyChecked;
    });
  }

  bool _isObscured = true;

  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация'),
      ),
      body: Stack (

        children: [

          if (loading) const LoadingScreen(loadingText: 'Подожди, выполняется процесс регистрации',)

          else SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Text('Регистрация', style: Theme.of(context).textTheme.titleLarge,),
                const SizedBox(height: 15.0),
                Text('Спасибо, что присоединяешься к нам! Теперь ты часть нашей креативной семьи. Готовься к удивительным встречам и приключениям! 😊', style: Theme.of(context).textTheme.bodyMedium,),
                const SizedBox(height: 25.0),

                TextField(
                  style: Theme.of(context).textTheme.bodyMedium,
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  style: Theme.of(context).textTheme.bodyMedium,
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                    prefixIcon: const Icon(Icons.key),
                  ),
                  obscureText: _isObscured,
                ),
                const SizedBox(height: 40.0),

                Row(
                  children: [

                    Checkbox(
                      value: privacyPolicyChecked,
                      onChanged: (value) {
                        togglePrivacyPolicyChecked();
                      },
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.75,
                      child: const TextWithLink(
                        linkedText: 'политики конфиденциальности',
                        uri: '/privacy_policy',
                        text: 'Галочку, пожалуйста! Подтвердите, что вы в курсе и согласны с правилами',
                      ),
                    )

                  ],
                ),

                const SizedBox(height: 40.0),

                CustomButton(
                    buttonText: 'Зарегистрироваться',
                    onTapMethod: () async {

                      setState(() {
                        loading = true;
                      });

                      if (!privacyPolicyChecked){

                        showSnackBar('Это важно! Поставь галочку, что согласен ты с правилами политики конфиденциальности 🤨📜', AppColors.attentionRed, 2);

                      } else {

                        String email = emailController.text;
                        String password = passwordController.text;
                        // Регистрация пользователя
                        String? uid = await authWithEmail.createUserWithEmailAndPassword(email, password);

                        if (uid != null) {

                          if (uid == 'weak-password'){

                            updateShowLogInButton(false);

                            showSnackBar(
                                "Твой текущий пароль - как стеклянное окно. Давай заменим его на стальные двери с кодовым замком!",
                                AppColors.attentionRed,
                                2
                            );

                          } else if (uid == 'email-already-in-use'){

                            updateShowLogInButton(true);

                            showSnackBar(
                                "Вот это совпадение! Если это ты, дружище, давай вспомним, как заходить - твой аккаунт ждет!",
                                AppColors.attentionRed,
                                5
                            );

                          } else if (uid == 'channel-error'){

                            updateShowLogInButton(false);

                            // TODO Сделать функцию возвращения текста в снакбар, в зависимости от кода ошибки

                            showSnackBar(
                                "Ой! Кажется, ты забыл важные детали. Пожалуйста, убедись, что ти ввел свой email и придумал надежный пароль, и тогда мы сможем тебя зарегистрировать!",
                                AppColors.attentionRed,
                                5
                            );

                          } else if (uid == 'invalid-email'){

                            updateShowLogInButton(false);

                            showSnackBar(
                                "Ой, что-то с форматом Email пошло не так. Удостоверься, что вводишь его правильно, и давай еще раз! 📭🔄",
                                AppColors.attentionRed,
                                2
                            );

                          } else {

                            User newUser = User(
                                uid: uid,
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
                                avatar: 'https://firebasestorage.googleapis.com/v0/b/dvij-flutter.appspot.com/o/avatars%2F4632379.jpg?alt=media&token=1a96beed-155f-489a-b676-a2326ebeae36'
                            );

                            String? publishedInDatabase = await userDatabase.writeUserData(newUser);

                            if (publishedInDatabase == 'success'){

                              setState(() {
                                loading = true;
                              });

                              showSnackBar(
                                  "Прекрасно! Теперь вы часть клуба любителей веселья и отличного времяпровождения. "
                                      "Проверьте свою почту - вас ждет важное сообщение с инструкциями по завершению "
                                      "регистрации. Готовьтесь к морю веселых мероприятий!",
                                  Colors.green,
                                  5
                              );

                              navigateToProfile();

                            } else {

                              // TODO: Сделать обработку ошибок, если не удалось загрузить в базу данных пользователя

                            }



                          }

                        } else {
                          // Обработка случая, когда создание пользователя не удалось
                          // Можно показать сообщение об ошибке или принять соответствующие меры

                          showSnackBar(
                              "Что-то пошло не так при регистрации. Возможно, где-то ошибка. "
                                  "Пожалуйста, перепроверь данные и попробуй еще раз. "
                                  "Если проблема сохранится, сообщи нам!",
                              AppColors.attentionRed,
                              5
                          );

                        }
                      }

                    }


                ),

                if (showLogInButton) const SizedBox(height: 50.0),

                if (showLogInButton) Text(
                    'Опачки, кажется, твой кибер-двойник уже в сети! Может, пора вспомнить свой пароль и попробовать войти?',
                    style: Theme.of(context).textTheme.bodyMedium
                ),

                if (showLogInButton) const SizedBox(height: 20.0),

                if (showLogInButton) CustomButton(
                  state: 'secondary',
                  buttonText: 'Войти?',
                  onTapMethod: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },

                ),
              ],
            ),
          ),

        ],


      )


    );
  }
}

