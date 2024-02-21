import 'package:dvij_flutter/classes/user_class.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/elements/loading_screen.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:dvij_flutter/users/place_admins_item_class.dart';
import 'package:dvij_flutter/users/place_user_class.dart';
import 'package:dvij_flutter/users/place_users_roles.dart';
import 'package:flutter/material.dart';
import '../place_class.dart';
import '../../elements/custom_snack_bar.dart';
import '../place_roles_elements/place_role_element_in_choose_dialog.dart';
import '../place_roles_screens/place_roles_choose_page.dart';
import '../places_elements/place_managers_element_list_item.dart';
import '../places_screen/place_view_screen.dart';

class PlaceManagerAddScreen extends StatefulWidget {
  final String placeId;
  final String placeCreatorUid;
  final List<PlaceAdminsListItem> admins;
  final bool isEdit;
  final PlaceUser? user;

  const PlaceManagerAddScreen({
    Key? key,
    required this.placeId,
    required this.placeCreatorUid,
    required this.isEdit,
    required this.admins,
    this.user
  }) : super(key: key);

  @override
  PlaceManagerAddScreenState createState() => PlaceManagerAddScreenState();
}

// ---- Экран редактирования или создания города ----

// Принцип простой, если на экран не передается город, то это создание города
// Если передается, то название города уже вбито, его можно редактировать

// TODO При создании города Сделать проверку, существует ли уже город с таким названием?. Если да выводить всплывающее меню

class PlaceManagerAddScreenState extends State<PlaceManagerAddScreen> {

  final TextEditingController _emailSearchController = TextEditingController();

  // Переменная, включающая экран загрузки
  bool loading = false;
  bool saving = false;
  bool deleting = false;
  bool showEditButton = true;

  PlaceUser user = PlaceUser();
  bool showNotFound = false;
  PlaceUserRole chosenRole = PlaceUserRole();

  // --- Инициализируем состояние ----

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {

    setState(() {
      loading = true;
    });

    if (widget.user != null) {
      user = widget.user!;
    }


    if (widget.isEdit){
      //chosenRole = PlaceRole.getPlaceRoleFromListById(user!.roleInPlace!);

      chosenRole = widget.user!.roleInPlace;
    }



    setState(() {
      loading = false;
    });

  }

  // ---- Функция отображения всплывающего окна

  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void navigateToPlaceViewScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PlaceViewScreen(placeId: widget.placeId))
    );
  }

  void navigateBackWithResult() {
    Navigator.pop(context, 'Результат с Second Page');
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
              //navigateToPlaceViewScreen();
              navigateBackWithResult();
            },
          ),
        ),

        // --- Само тело страницы ----

        body: Stack(
          children: [
            if (loading) const LoadingScreen(loadingText: "Идет загрузка управляющего",)
            else if (saving) const LoadingScreen(loadingText: "Идет сохранение управляющего",)
            else if (deleting) const LoadingScreen(loadingText: "Идет удаление управляющего",)
            else Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    if (!widget.isEdit) Text(
                      'Поиск пользователя',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    if (!widget.isEdit) SizedBox(height: 20,),

                    if (!widget.isEdit) TextField(
                      style: Theme.of(context).textTheme.bodyMedium,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailSearchController,
                      decoration: const InputDecoration(
                        labelText: 'Введи email для поиска пользователя',
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),

                    if (!widget.isEdit) const SizedBox(height: 20.0),

                    // ---- Кнопка опубликовать -----

                    // TODO Пока публикуется сделать экран загрузки
                    if (!widget.isEdit) CustomButton(
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
                              user = PlaceUser();
                              showNotFound = false;
                              showEditButton = true;
                            });

                            PlaceUser foundUser = await user.getPlaceUserByEmail(_emailSearchController.text);

                            if (foundUser.uid != ''){
                              if (foundUser.uid == widget.placeCreatorUid){
                                setState(() {
                                  chosenRole = chosenRole.getPlaceUserRole(PlaceUserRoleEnum.creator);
                                  showEditButton = false;
                                  foundUser.roleInPlace = chosenRole;
                                });
                              } else{
                                setState(() {
                                  chosenRole = chosenRole.searchPlaceUserRoleInAdminsList(widget.admins, foundUser);
                                  foundUser.roleInPlace = chosenRole;
                                });
                              }

                              setState(() {
                                showNotFound = false;
                                user = foundUser;
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

                    if (user.uid != '' && !widget.isEdit) const SizedBox(height: 40.0),

                    if (user.uid != '') Text(
                      widget.isEdit ? 'Выбранный пользователь:' : 'Найденный пользователь:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    if (user.uid != '') const SizedBox(height: 10.0),

                    if (user.uid != '') PlaceManagersElementListItem(user: user, showButton: false),

                    if (user.uid != '') const SizedBox(height: 20.0),

                    if (user.uid != '' && showEditButton) Text(
                      'Роль:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    if (!showEditButton) Text(
                      'Это создатель заведения. Его нельзя редактировать или добавить в место',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                    if (user.uid != '') const SizedBox(height: 10.0),

                    if (user.uid != '' && showEditButton) PlaceRoleElementInChooseDialog(
                      roleName: chosenRole.title,
                      onActionPressed: () {
                        //_showCityPickerDialog();
                        _showRolePickerDialog();
                      },
                    ),

                    if (showNotFound) const SizedBox(height: 40.0),
                    if (showNotFound) const Text('Пользователь не найден'),

                    const SizedBox(height: 40.0),

                    if (user.uid != '' && showEditButton) CustomButton(
                        state: 'success',
                        buttonText: "Сохранить изменения",
                        onTapMethod: () async {

                          setState(() {
                            saving = true;
                          });

                          String? resultUploadUser = await UserCustom.writeUserPlaceRole(user.uid, widget.placeId, chosenRole.generatePlaceRoleEnumForPlaceUser(chosenRole.roleInPlace));
                          if (resultUploadUser == 'success'){
                            String? resultUploadPlace = await Place.writeUserRoleInPlace(widget.placeId, user.uid, chosenRole.generatePlaceRoleEnumForPlaceUser(chosenRole.roleInPlace));
                            if (resultUploadPlace == 'success'){
                              setState(() {
                                if (widget.isEdit == false){
                                  user = PlaceUser();
                                  showNotFound = false;
                                  showEditButton = true;
                                } else {
                                  user.roleInPlace = chosenRole;
                                }
                                saving = false;
                                //loading = true;

                              });
                              //navigateToPlaceViewScreen();
                              showSnackBar('Пользователь успешно добавлен', Colors.green, 2);
                            } else {
                              setState(() {
                                saving = false;
                              });
                              showSnackBar('Произошла ошибка $resultUploadPlace при добавлении данных в место', AppColors.attentionRed, 2);
                            }
                          } else {
                            setState(() {
                              saving = false;
                            });
                            showSnackBar('Произошла ошибка $resultUploadUser при добавлении данных в пользователя', AppColors.attentionRed, 2);
                          }

                        }
                    ),

                    if (user.uid != '' && showEditButton) const SizedBox(height: 10.0),
                    // -- Кнопка отменить ----

                    if (user.uid != '') CustomButton(
                        state: 'secondary',
                        buttonText: "Отменить",
                        onTapMethod: () {
                          //navigateToPlaceViewScreen();
                          navigateBackWithResult();
                        }
                    ),

                    if (user.uid != '') const SizedBox(height: 50.0),

                    if (user.uid != '' && widget.isEdit) CustomButton(
                        state: 'error',
                        buttonText: "Удалить пользователя из управляющих",
                        onTapMethod: () async {

                          setState(() {
                            deleting = true;
                          });

                          String? resultDeleteUser = await UserCustom.deleteUserPlaceRole(user.uid, widget.placeId);

                          if (resultDeleteUser == 'success') {

                            String? resultDeletePlace = await Place.deleteUserRoleInPlace(widget.placeId, user.uid);

                            if (resultDeletePlace == 'success'){
                              setState(() {
                                deleting = false;
                              });

                              user = PlaceUser();
                              showNotFound = false;
                              showEditButton = true;

                              navigateBackWithResult();

                              showSnackBar('Пользователь успешно удален', Colors.green, 2);
                            } else {
                              setState(() {
                                saving = false;
                              });
                              showSnackBar('Произошла ошибка $resultDeletePlace при удалении пользователя из места', AppColors.attentionRed, 2);
                            }

                          } else {

                            setState(() {
                              saving = false;
                            });
                            showSnackBar('Произошла ошибка $resultDeleteUser при удаления данных о месте из пользователя', AppColors.attentionRed, 2);

                          }
                        }
                    ),

                  ],
                ),
              ),
            ),
          ],
        )
    );
  }

  void _showRolePickerDialog() async {
    final selectedRole = await Navigator.of(context).push(_createPopup());

    if (selectedRole != null) {
      setState(() {
        chosenRole = selectedRole;
      });
    }
  }

  Route _createPopup() {
    return PageRouteBuilder(

      pageBuilder: (context, animation, secondaryAnimation) {

        return PlaceRolesChoosePage();
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