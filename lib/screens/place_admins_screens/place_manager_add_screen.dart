import 'package:dvij_flutter/classes/place_category_class.dart';
import 'package:dvij_flutter/classes/place_role_class.dart';
import 'package:dvij_flutter/classes/user_class.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/elements/loading_screen.dart';
import 'package:dvij_flutter/elements/place_roles_elements/place_role_element_in_choose_dialog.dart';
import 'package:dvij_flutter/elements/places_elements/place_managers_element_list_item.dart';
import 'package:dvij_flutter/screens/place_admins_screens/place_manager_list_screen.dart';
import 'package:dvij_flutter/screens/place_categories_screens/place_categories_list_screen.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import '../../classes/city_class.dart';
import '../../classes/place_class.dart';
import '../../elements/choose_dialogs/city_choose_dialog.dart';
import '../../elements/cities_elements/city_element_in_edit_screen.dart';
import '../../elements/custom_snack_bar.dart';
import '../place_roles_screens/place_roles_choose_page.dart';

class PlaceManagerAddScreen extends StatefulWidget {
  final String placeId;

  const PlaceManagerAddScreen({Key? key, required this.placeId}) : super(key: key);

  @override
  _PlaceManagerAddScreenState createState() => _PlaceManagerAddScreenState();
}

// ---- Экран редактирования или создания города ----

// Принцип простой, если на экран не передается город, то это создание города
// Если передается, то название города уже вбито, его можно редактировать

// TODO При создании города Сделать проверку, существует ли уже город с таким названием?. Если да выводить всплывающее меню

class _PlaceManagerAddScreenState extends State<PlaceManagerAddScreen> {

  final TextEditingController _emailSearchController = TextEditingController();

  // Переменная, включающая экран загрузки
  bool loading = false;

  UserCustom? user;
  bool showNotFound = false;
  late PlaceRole chosenRole = PlaceRole(name: '', id: '', desc: '');
  List<PlaceRole> _roles = [];

  // --- Инициализируем состояние ----

  @override
  void initState() {
    super.initState();
    _roles = PlaceRole.currentPlaceRoleList;
  }

  // ---- Функция отображения всплывающего окна

  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void navigateToPlaceManageListScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PlaceManagersListScreen(placeId: widget.placeId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Добавление управляющего'),

          // Задаем особый выход на кнопку назад
          // Чтобы не плодились экраны назад с разным списком городов

          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              navigateToPlaceManageListScreen();
            },
          ),
        ),

        // --- Само тело страницы ----

        body: Stack(
          children: [
            if (loading) const LoadingScreen(loadingText: "Идет сохранение управляющего",)
            else Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      'Поиск пользователя',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    SizedBox(height: 20,),

                    TextField(
                      style: Theme.of(context).textTheme.bodyMedium,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailSearchController,
                      decoration: const InputDecoration(
                        labelText: 'Введи email для поиска пользователя',
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),

                    const SizedBox(height: 20.0),

                    // ---- Кнопка опубликовать -----

                    // TODO Пока публикуется сделать экран загрузки
                    CustomButton(
                        buttonText: 'Найти',
                        onTapMethod: () async {
                          if (_emailSearchController.text == ''){
                            showSnackBar(
                                'Ты не ввел Email( Как нам искать?',
                                AppColors.attentionRed,
                                2
                            );
                          } else {
                            //_publishPlaceCategory();

                            setState(() {
                              loading = true;
                              user = null;
                              showNotFound = false;
                            });


                            UserCustom? result = await UserCustom.getUserByEmail(_emailSearchController.text);

                            if (result != null)
                            {
                              setState(() {
                                showNotFound = false;
                                user = result;
                                _emailSearchController.text = '';
                              });
                            } else {
                              setState(() {
                                showNotFound = true;
                              });
                            }

                            setState(() {
                              loading = false;
                            });
                          }
                        }
                    ),

                    if (user != null) const SizedBox(height: 40.0),

                    if (user != null) Text(
                      'Найденный пользователь:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    if (user != null) const SizedBox(height: 10.0),

                    if (user != null) PlaceManagersElementListItem(user: user!, showButton: false),

                    if (user != null) const SizedBox(height: 20.0),

                    if (user != null) Text(
                      'Выбери роль:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    if (user != null) const SizedBox(height: 10.0),

                    if (chosenRole.id == '' && user != null) PlaceRoleElementInChooseDialog(
                      onActionPressed: () {
                        //_showCityPickerDialog();
                        _showRolePickerDialog();
                      },
                      roleName: '',
                    ),

                    if (chosenRole.id != '' && user != null) PlaceRoleElementInChooseDialog(
                      roleName: chosenRole.name,
                      onActionPressed: () {
                        //_showCityPickerDialog();
                        _showRolePickerDialog();
                      },
                    ),

                    if (showNotFound) const SizedBox(height: 40.0),
                    if (showNotFound) const Text('Пользователь не найден'),

                    const SizedBox(height: 40.0),

                    if (user != null) CustomButton(
                        state: 'success',
                        buttonText: "Сохранить изменения",
                        onTapMethod: () async {

                          setState(() {
                            loading = true;
                          });

                          String? resultUploadUser = await UserCustom.writeUserPlaceRole(user!.uid, widget.placeId, chosenRole.id);
                          if (resultUploadUser == 'success'){
                            String? resultUploadPlace = await Place.writeUserRoleInPlace(widget.placeId, user!.uid, chosenRole.id);
                            if (resultUploadPlace == 'success'){
                              setState(() {
                                loading = false;
                              });
                              navigateToPlaceManageListScreen();
                              showSnackBar('Пользователь успешно добавлен', Colors.green, 2);
                            } else {
                              setState(() {
                                loading = false;
                              });
                              showSnackBar('Произошла ошибка $resultUploadPlace при добавлении данных в место', AppColors.attentionRed, 2);
                            }
                          } else {
                            setState(() {
                              loading = false;
                            });
                            showSnackBar('Произошла ошибка $resultUploadUser при добавлении данных в пользователя', AppColors.attentionRed, 2);
                          }

                        }
                    ),

                    if (user != null) const SizedBox(height: 10.0),
                    // -- Кнопка отменить ----

                    if (user != null) CustomButton(
                        state: 'secondary',
                        buttonText: "Отменить",
                        onTapMethod: () {
                          navigateToPlaceManageListScreen();
                        }
                    )
                  ],
                ),
              ),
            ),
          ],
        )
    );
  }

  void _showRolePickerDialog() async {
    final selectedRole = await Navigator.of(context).push(_createPopup(_roles));

    if (selectedRole != null) {
      setState(() {
        chosenRole = selectedRole;
      });
      print("Selected city: ${selectedRole.name}, ID: ${selectedRole.id}");
    }
  }

  Route _createPopup(List<PlaceRole> roles) {
    return PageRouteBuilder(

      pageBuilder: (context, animation, secondaryAnimation) {

        return PlaceRolesChoosePage(roles: roles);
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