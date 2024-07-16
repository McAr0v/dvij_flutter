import 'package:dvij_flutter/current_user/app_role.dart';
import 'package:dvij_flutter/widgets_global/text_widgets/headline_and_desc.dart';
import 'package:dvij_flutter/screens/users_list_screens/users_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import '../../current_user/user_class.dart';
import '../../elements/custom_snack_bar.dart';
import '../../elements/loading_screen.dart';

class UsersChangeRoleAdminScreen extends StatefulWidget {
  final UserCustom userInfo;

  const UsersChangeRoleAdminScreen({Key? key, required this.userInfo}) : super(key: key);

  @override
  _UsersChangeRoleAdminScreenState createState() => _UsersChangeRoleAdminScreenState();

}

// ----- ЭКРАН РЕДАКТИРОВАНИЯ ПРОФИЛЯ -------

class _UsersChangeRoleAdminScreenState extends State<UsersChangeRoleAdminScreen> {

  late AppRole appRole;

  bool loading = true;

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

    appRole = widget.userInfo.role;

    setState(() {
      loading = false;
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

                    if (widget.userInfo.role.getAccessNumber() >= 100) const SizedBox(height: 20.0),

                    /*if (widget.userInfo.role.getAccessNumber() >= 100) RoleInAppElementInEditScreen(
                      onActionPressed: _showRoleInAppPickerDialog,
                      roleInAppName: appRole.getRoleNameInString(roleEnum: appRole.role, needTranslate: true),
                    ),*/

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
                          role: appRole,
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
                          registrationDate: widget.userInfo.registrationDate,
                          myPlaces: widget.userInfo.myPlaces,

                        );

                        // Выгружаем пользователя в БД
                        //String? editInDatabase = await UserCustom.publishUserToDb(updatedUser, notAdminChanges: false);
                        String? editInDatabase = await updatedUser.publishUserToDb(notAdminChanges: false);

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
                      state: CustomButtonState.error,
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

  /*void _showRoleInAppPickerDialog() async {
    final selectedRoleInApp = await Navigator.of(context).push(_createPopupRoleInApp(_rolesInApp));

    if (selectedRoleInApp != null) {
      setState(() {
        appRole = selectedRoleInApp;
      });
      print("Selected roleInApp: ${selectedRoleInApp.name}, ID: ${selectedRoleInApp.id}");
    }
  }*/

  /*Route _createPopupRoleInApp(List<RoleInApp> roleInApp) {
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
  }*/

}