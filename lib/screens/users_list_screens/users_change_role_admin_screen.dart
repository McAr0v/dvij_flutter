import 'dart:io';
import 'package:dvij_flutter/classes/gender_class.dart';
import 'package:dvij_flutter/elements/date_elements/data_picker.dart';
import 'package:dvij_flutter/elements/genders_elements/gender_element_in_edit_screen.dart';
import 'package:dvij_flutter/elements/genders_elements/gender_picker_page.dart';
import 'package:dvij_flutter/elements/text_and_icons_widgets/headline_and_desc.dart';
import 'package:dvij_flutter/elements/role_in_app_elements/role_in_app_element_in_edit_screen.dart';
import 'package:dvij_flutter/elements/role_in_app_elements/role_in_app_picker_page.dart';
import 'package:dvij_flutter/methods/date_functions.dart';
import 'package:dvij_flutter/screens/users_list_screens/users_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import '../../classes/city_class.dart';
import '../../classes/role_in_app.dart';
import '../../classes/user_class.dart';
import '../../classes/user_class.dart';
import '../../elements/choose_dialogs/city_choose_dialog.dart';
import '../../elements/cities_elements/city_element_in_edit_screen.dart';
import '../../elements/custom_snack_bar.dart';
import 'package:image_picker/image_picker.dart';
import '../../elements/image_in_edit_screen.dart';
import '../../elements/loading_screen.dart';
import '../../image_Uploader/image_uploader.dart';
import '../../image_uploader/image_picker.dart';
import '../../themes/app_colors.dart';

class UsersChangeRoleAdminScreen extends StatefulWidget {
  final UserCustom userInfo;

  const UsersChangeRoleAdminScreen({Key? key, required this.userInfo}) : super(key: key);



  @override
  _UsersChangeRoleAdminScreenState createState() => _UsersChangeRoleAdminScreenState();

}

// ----- ЭКРАН РЕДАКТИРОВАНИЯ ПРОФИЛЯ -------

class _UsersChangeRoleAdminScreenState extends State<UsersChangeRoleAdminScreen> {

  late RoleInApp chosenRoleInApp;

  bool loading = true;

  late List<RoleInApp> _rolesInApp = [];

  // --- Функция перехода на страницу профиля ----

  void navigateToUsersList() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const UsersListScreen()),
    );

  }

  // ----- Отображение всплывающего сообщения ----

  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(
      message: message,
      backgroundColor: color,
      showTime: showTime,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    loading = true;

    _rolesInApp = RoleInApp.currentRoleInAppList;

    // Подгружаем в контроллеры содержимое из БД.
    Future.delayed(Duration.zero, () async {

      chosenRoleInApp = await RoleInApp.getRoleInAppById(widget.userInfo.role) as RoleInApp;

      setState(() {
        loading = false;
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Редактирование роли пользователя'),
        ),
        body: Stack (
            children: [
              if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка данных',)
              else SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    HeadlineAndDesc(headline: '${widget.userInfo.name} ${widget.userInfo.lastname}', description: 'Имя'),
                    const SizedBox(height: 20.0),
                    HeadlineAndDesc(headline: widget.userInfo.email, description: 'email'),
                    const SizedBox(height: 20.0),
                    HeadlineAndDesc(headline: widget.userInfo.uid, description: 'ID'),

                    if (UserCustom.accessLevel >= 100) const SizedBox(height: 20.0),

                    if (UserCustom.accessLevel >= 100) RoleInAppElementInEditScreen(
                      onActionPressed: _showRoleInAppPickerDialog,
                      roleInAppName: chosenRoleInApp.name,
                    ),

                    const SizedBox(height: 40.0),

                    // --- КНОПКА Сохранить изменения -------

                    CustomButton(
                      buttonText: 'Сохранить изменения',
                      onTapMethod: () async {

                        // Включаем экран загрузки
                        setState(() {
                          loading = true;
                        });

                        // Заполняем пользователя
                        UserCustom updatedUser = UserCustom(
                          uid: widget.userInfo.uid,
                          email: widget.userInfo.email,
                          role: chosenRoleInApp.id,
                          name: widget.userInfo.name,
                          lastname: widget.userInfo.lastname,
                          phone: widget.userInfo.phone,
                          whatsapp: widget.userInfo.whatsapp,
                          telegram: widget.userInfo.telegram,
                          instagram: widget.userInfo.instagram,
                          city: widget.userInfo.city,
                          birthDate: widget.userInfo.birthDate,
                          gender: widget.userInfo.gender,
                          avatar: widget.userInfo.avatar,
                        );

                        // Выгружаем пользователя в БД
                        String? editInDatabase = await UserCustom.writeUserData(updatedUser, notAdminChanges: false);

                        // Если выгрузка успешна
                        if (editInDatabase == 'success') {

                          // Выключаем экран загрузки
                          setState(() {
                            loading = false;
                          });
                          // Показываем всплывающее сообщение
                          showSnackBar(
                            "Прекрасно! Данные отредактированы!",
                            Colors.green,
                            1,
                          );

                          // Уходим в профиль
                          navigateToUsersList();

                        }

                      },
                    ),
                    const SizedBox(height: 16.0),
                    CustomButton(
                      state: 'error',
                      buttonText: 'Отмена',
                      onTapMethod: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ]
        )
    );
  }

  void _showRoleInAppPickerDialog() async {
    final selectedRoleInApp = await Navigator.of(context).push(_createPopupRoleInApp(_rolesInApp));

    if (selectedRoleInApp != null) {
      setState(() {
        chosenRoleInApp = selectedRoleInApp;
      });
      print("Selected roleInApp: ${selectedRoleInApp.name}, ID: ${selectedRoleInApp.id}");
    }
  }

  Route _createPopupRoleInApp(List<RoleInApp> roleInApp) {
    return PageRouteBuilder(

      pageBuilder: (context, animation, secondaryAnimation) {

        return RoleInAppPickerPage(rolesInApp: roleInApp);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: Duration(milliseconds: 100),

    );
  }

}