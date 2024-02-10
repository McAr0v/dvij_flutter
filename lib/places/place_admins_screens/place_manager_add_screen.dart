import 'package:dvij_flutter/places/place_role_class.dart';
import 'package:dvij_flutter/classes/user_class.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/elements/loading_screen.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import '../place_class.dart';
import '../../elements/custom_snack_bar.dart';
import '../place_roles_elements/place_role_element_in_choose_dialog.dart';
import '../place_roles_screens/place_roles_choose_page.dart';
import '../places_elements/place_managers_element_list_item.dart';
import '../places_screen/place_view_screen.dart';

class PlaceManagerAddScreen extends StatefulWidget {
  final String placeId;
  final String placeCreator;
  final bool isEdit;
  final PlaceRole? placeRole;
  final UserCustom? user;

  const PlaceManagerAddScreen({
    Key? key,
    required this.placeId,
    required this.placeCreator,
    required this.isEdit,
    this.placeRole,
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

  UserCustom? user;
  bool showNotFound = false;
  late PlaceRole chosenRole = PlaceRole(name: '', id: '', desc: '', controlLevel: '');
  List<PlaceRole> _roles = [];

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
    // Получаем список городов
    //_getCitiesFromDatabase();

    //_roles = PlaceRole.currentPlaceRoleListWithoutCreator;
    _roles = PlaceRole.currentPlaceRoleListWithoutCreator;

    if (widget.isEdit){
      //chosenRole = PlaceRole.getPlaceRoleFromListById(user!.roleInPlace!);

      chosenRole = widget.placeRole!;
    }

    if (widget.user != null) {
      user = widget.user;
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
                              user = null;
                              showNotFound = false;
                              showEditButton = true;
                            });


                            UserCustom? result = await UserCustom.getUserByEmail(_emailSearchController.text);

                            if (result != null)
                            {
                              if (result.uid == widget.placeCreator){
                                result.roleInPlace = '-NngrYovmKAw_cp0pYfJ';
                                chosenRole = PlaceRole.getPlaceRoleFromListById(result.roleInPlace!);
                                setState(() {
                                  showEditButton = false;
                                });
                              } else {

                                PlaceRole resultRole = await UserCustom.getPlaceRoleInUserById(widget.placeId, result.uid);

                                if (resultRole.name != ''){
                                  setState(() {
                                    chosenRole = resultRole;
                                  });
                                  result.roleInPlace = resultRole.id;
                                }

                              }

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

                    if (user != null && !widget.isEdit) const SizedBox(height: 40.0),

                    if (user != null) Text(
                      widget.isEdit ? 'Выбранный пользователь:' : 'Найденный пользователь:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    if (user != null) const SizedBox(height: 10.0),

                    if (user != null) PlaceManagersElementListItem(user: user!, showButton: false),

                    if (user != null) const SizedBox(height: 20.0),

                    if (user != null && showEditButton) Text(
                      'Роль:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    if (!showEditButton) Text(
                      'Это создатель заведения. Его нельзя редактировать или добавить в место',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                    if (user != null) const SizedBox(height: 10.0),

                    if (chosenRole.id == '' && user != null) PlaceRoleElementInChooseDialog(
                      onActionPressed: () {
                        //_showCityPickerDialog();
                        _showRolePickerDialog();
                      },
                      roleName: '',
                    ),

                    if (chosenRole.id != '' && user != null && showEditButton) PlaceRoleElementInChooseDialog(
                      roleName: chosenRole.name,
                      onActionPressed: () {
                        //_showCityPickerDialog();
                        _showRolePickerDialog();
                      },
                    ),

                    if (showNotFound) const SizedBox(height: 40.0),
                    if (showNotFound) const Text('Пользователь не найден'),

                    const SizedBox(height: 40.0),

                    if (user != null && showEditButton) CustomButton(
                        state: 'success',
                        buttonText: "Сохранить изменения",
                        onTapMethod: () async {

                          setState(() {
                            saving = true;
                          });

                          String? resultUploadUser = await UserCustom.writeUserPlaceRole(user!.uid, widget.placeId, chosenRole.id);
                          if (resultUploadUser == 'success'){
                            String? resultUploadPlace = await Place.writeUserRoleInPlace(widget.placeId, user!.uid, chosenRole.id);
                            if (resultUploadPlace == 'success'){
                              setState(() {
                                if (widget.isEdit == false){
                                  user = null;
                                  showNotFound = false;
                                  showEditButton = true;
                                } else {
                                  user?.roleInPlace = chosenRole.id;
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

                    if (user != null && showEditButton) const SizedBox(height: 10.0),
                    // -- Кнопка отменить ----

                    if (user != null) CustomButton(
                        state: 'secondary',
                        buttonText: "Отменить",
                        onTapMethod: () {
                          //navigateToPlaceViewScreen();
                          navigateBackWithResult();
                        }
                    ),

                    if (user != null) const SizedBox(height: 50.0),

                    if (user != null && widget.isEdit) CustomButton(
                        state: 'error',
                        buttonText: "Удалить пользователя из управляющих",
                        onTapMethod: () async {

                          setState(() {
                            deleting = true;
                          });

                          String? resultDeleteUser = await UserCustom.deleteUserPlaceRole(user!.uid, widget.placeId);

                          if (resultDeleteUser == 'success') {

                            String? resultDeletePlace = await Place.deleteUserRoleInPlace(widget.placeId, user!.uid);

                            if (resultDeletePlace == 'success'){
                              setState(() {
                                deleting = false;
                              });

                              user = null;
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