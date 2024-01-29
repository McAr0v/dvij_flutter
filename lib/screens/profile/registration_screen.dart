import 'package:dvij_flutter/database_firebase/user_database.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/elements/loading_screen.dart';
import 'package:dvij_flutter/elements/text_and_icons_widgets/text_with_link.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/authentication/auth_with_email.dart';
import '../../classes/user_class.dart';
import '../../elements/custom_snack_bar.dart';
import '../../themes/app_colors.dart';
import 'login_screen.dart';

// -- ЭКРАН РЕГИСТРАЦИИ ----

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {

  //late final AppState appState; -- Если все норм будет работать, удали эту строчку // От 30.11.2023

  // --- Инициализируем классы
  //final AuthWithEmail authWithEmail = AuthWithEmail();
  //final UserDatabase userDatabase = UserDatabase();

  // --- Инициализируем контроллеры для полей ввода
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // --- Функция перехода на страницу профиля ---

  void navigateToProfile() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/Profile', // Название маршрута, которое вы задаете в MaterialApp
          (route) => false,
    );
  }

  // ---- Функция отображения всплывающего окна

  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // ---- Переменная отображения экрана загрузки

  bool loading = false;

  // --- Обновление кнопки - Может нужно войти?

  bool showLogInButton = false;

  void updateShowLogInButton(bool newValue) {
    setState(() {
      showLogInButton = newValue;
    });
  }

  // ---- Чек-бокс о том, что прочитали правила политики конфиденциальности

  bool privacyPolicyChecked = false;

  void togglePrivacyPolicyChecked() {
    setState(() {
      privacyPolicyChecked = !privacyPolicyChecked;
    });
  }

  // ---- Видимость пароля ------

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

          // ---- Если идет загрузка, то отображается экран загрузки ----

          if (loading) const LoadingScreen(loadingText: 'Подожди, выполняется процесс регистрации',)

          // --- В остальных случаях экран регистрации ----

          else SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                // --- Заголовок и описание ------

                Text('Регистрация', style: Theme.of(context).textTheme.titleLarge,),
                const SizedBox(height: 15.0),
                Text('Спасибо, что присоединяешься к нам! Теперь ты часть нашей креативной семьи. Готовься к удивительным встречам и приключениям! 😊', style: Theme.of(context).textTheme.bodyMedium,),
                const SizedBox(height: 25.0),

                // ----- Поле Email -----
                // TODO Сделать фунции отрисовки полей ввода

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

                // ----- Поле пароль ------

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

                // ----- ЧЕК БОКС -------
                // TODO Сделать функцию отрисовки чек-бокса

                Row(
                  children: [

                    Checkbox(
                      value: privacyPolicyChecked,
                      onChanged: (value) {
                        togglePrivacyPolicyChecked();
                      },
                    ),
                    // ---- Надпись у чекбокса -----
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

                // ----- КНОПКА ЗАРЕГИСТРИРОВАТЬСЯ -----

                CustomButton(
                    buttonText: 'Зарегистрироваться',
                    onTapMethod: () async {

                      // ---- НАЧАЛО ПРОЦЕССА РЕГИСТРАЦИИ -----

                      // ---- УСТАНАВЛИВАЕМ ЭКРАН ЗАГРУЗКИ ------

                      setState(() {
                        loading = true;
                      });

                      // ---- ЕСЛИ НЕ ПОДТВЕРДИЛИ ЧЕК-БОКС, ВЫВОДИМ ОШИБКУ
                      if (!privacyPolicyChecked){

                        showSnackBar('Это важно! Поставь галочку, что согласен ты с правилами политики конфиденциальности 🤨📜', AppColors.attentionRed, 2);

                        // Останавливаем регистрацию
                        setState(() {
                          loading = false;
                        });

                      } else {

                        // ---- ЕСЛИ ЧЕК-БОКС ПОДТВЕРЖДЕН -----

                        String email = emailController.text;
                        String password = passwordController.text;

                        // Запускаем регистрацию и ждем
                        //String? uid = await authWithEmail.createUserWithEmailAndPassword(email, password);
                        String? uid = await UserCustom.createUserWithEmailAndPassword(email, password);

                        // ----- Если есть результат функции -----

                        if (uid != null) {

                          // ---- Обработка ошибок ------
                          // TODO Сделать обработчик ошибок, который возвращает текст для всплывающего меню. Должен возвращать либо текст ошибки, либо 'Ok'

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

                            // ---- Если результат регистрации не равен ошибкам, создаем почти пустого пользователя ---

                            UserCustom newUser = UserCustom.empty(uid, email);

                            // --- Создаем запись в базе данных в Firebase

                            // String? publishedInDatabase = await userDatabase.writeUserData(newUser);
                            String? publishedInDatabase = await UserCustom.writeUserData(newUser);

                            // ---- Если все прошло успешно ----

                            if (publishedInDatabase == 'success'){

                              // ----- Убираем экран загрузки ----

                              setState(() {
                                loading = false;
                              });

                              showSnackBar(
                                  "Прекрасно! Теперь ты часть клуба любителей веселья и отличного времяпровождения. "
                                      "Проверь свою почту - тебя ждет важное сообщение с инструкциями по завершению "
                                      "регистрации. Готовься к морю веселых мероприятий!",
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

                // ---- Если Email уже есть в базе данных -----

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

