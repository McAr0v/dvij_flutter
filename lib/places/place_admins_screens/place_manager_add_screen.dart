import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/elements/loading_screen.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:dvij_flutter/users/place_admins_item_class.dart';
import 'package:dvij_flutter/users/place_user_class.dart';
import 'package:dvij_flutter/users/place_users_roles.dart';
import 'package:flutter/material.dart';
import '../../elements/exit_dialog/exit_dialog.dart';
import '../place_class.dart';
import '../../elements/custom_snack_bar.dart';
import '../place_roles_elements/place_role_element_in_choose_dialog.dart';
import '../place_roles_screens/place_roles_choose_page.dart';
import '../places_widgets/place_managers_element_list_item.dart';

class PlaceManagerAddScreen extends StatefulWidget {
  final Place place;
  final PlaceUser? placeUser;

  const PlaceManagerAddScreen({super.key,
    required this.place,
    this.placeUser
  });

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

  bool edit = false;

  PlaceUser user = PlaceUser();
  bool showNotFound = false;
  PlaceUserRole chosenRole = PlaceUserRole();

  Place _place = Place.emptyPlace;
  List<PlaceAdminsListItem> admins = [];

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

    if (widget.placeUser != null){
      edit = true;
      user = widget.placeUser!;
      chosenRole = user.placeUserRole;
    }

    _place = widget.place;

    admins = _place.admins!;

    setState(() {
      loading = false;
    });

  }

  // ---- Функция отображения всплывающего окна

  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _navigateBackWithoutResult() {
    Navigator.of(context).pop();
  }

  void _navigateBackWithResult() {
    Navigator.of(context).pop(admins);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(!edit ? 'Добавление пользователя' : 'Редактирование пользователя'),

          // Задаем особый выход на кнопку назад
          // Чтобы не плодились экраны назад с разным списком городов

          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              _navigateBackWithResult();
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

                    if (!edit) Text(
                      'Поиск пользователя',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    if (!edit) const SizedBox(height: 20,),

                    if (!edit) TextField(
                      style: Theme.of(context).textTheme.bodyMedium,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailSearchController,
                      decoration: const InputDecoration(
                        labelText: 'Введи email для поиска пользователя',
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),

                    if (!edit) const SizedBox(height: 20.0),

                    // ---- Кнопка опубликовать -----

                    if (!edit) CustomButton(
                        buttonText: 'Найти',
                        onTapMethod: () async {
                          _findAdmin();
                        }
                    ),

                    if (user.uid != '' && !edit) const SizedBox(height: 40.0),

                    if (user.uid != '') Text(
                      !edit ? 'Найденный пользователь:' : 'Выбранный пользователь:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    if (user.uid != '') const SizedBox(height: 30.0),

                    if (user.uid != '') PlaceManagersElementListItem(user: user, showButton: false),

                    if (user.uid != '') const SizedBox(height: 20.0),

                    if (user.uid != '') Text(
                      'Сменить роль пользователя:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    if (user.uid == _place.creatorId) Text(
                      'Это создатель заведения. Его нельзя редактировать или добавить в место',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                    if (user.uid != '') const SizedBox(height: 10.0),

                    if (user.uid != '' && user.uid != _place.creatorId) PlaceRoleElementInChooseDialog(
                      roleName: chosenRole.title,
                      onActionPressed: () {
                        _showRolePickerDialog();
                      },
                    ),

                    if (showNotFound) const SizedBox(height: 40.0),
                    if (showNotFound) const Text('Пользователь не найден'),

                    const SizedBox(height: 20.0),

                    if (user.uid != '' && user.uid != _place.creatorId && user.placeUserRole.roleInPlaceEnum != chosenRole.roleInPlaceEnum) CustomButton(
                        state: 'success',
                        buttonText: "Сохранить изменения",
                        onTapMethod: () async {
                          _saveAdmin();
                        }
                    ),

                    if (user.uid != '') const SizedBox(height: 10.0),

                    if (user.uid != '') CustomButton(
                        state: 'secondary',
                        buttonText: "Отменить",
                        onTapMethod: () {
                          _navigateBackWithoutResult();
                        }
                    ),

                    if (user.uid != '' && user.uid != _place.creatorId && user.placeUserRole.roleInPlaceEnum != PlaceUserRoleEnum.reader) const SizedBox(height: 20.0),

                    if (user.uid != '' && user.uid != _place.creatorId && user.placeUserRole.roleInPlaceEnum != PlaceUserRoleEnum.reader) CustomButton(
                        state: 'error',
                        buttonText: "Удалить пользователя",
                        onTapMethod: () async {
                          bool? confirmed = await exitDialog(context, "Ты правда хочешь удалить пользователя?" , 'Да', 'Нет', 'Удаление пользователя');
                          if (confirmed != null && confirmed){
                            _deleteAdmin();
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
        const curve = Curves.easeInQuad;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 200),

    );
  }

  Future<void> _deleteAdmin() async {
    // Если выбранная роль читатель и отличается от старой роли
    setState(() {
      deleting = true;
    });

    String deleteResult = await user.deletePlaceRoleInManagerAndPlace(_place.id);

    if (deleteResult == 'success') {
      admins.removeWhere((element) => element.userId == user.uid);
      showSnackBar('Роль успешно изменена', Colors.green, 2);

    } else {
      showSnackBar(deleteResult, AppColors.attentionRed, 2);
    }

    setState(() {
      deleting = false;
    });
    _navigateBackWithResult();
  }

  Future<void> _saveAdmin() async {
    setState(() {
      saving = true;
    });

    user.placeUserRole = chosenRole;

    if (chosenRole.roleInPlaceEnum != PlaceUserRoleEnum.reader){
      // Если выбранная роль не обычный пользователь

      String publishResult = await user.writePlaceRoleInManagerAndPlace(_place.id);

      if (publishResult == 'success'){
        admins.removeWhere((element) => element.userId == user.uid);

        admins.add(PlaceAdminsListItem(
            userId: user.uid, placeRole: user.placeUserRole.roleInPlaceEnum.name
        ));

        showSnackBar('Роль успешно изменена', Colors.green, 2);

        _navigateBackWithResult();

      } else {
        showSnackBar(publishResult, AppColors.attentionRed, 2);
      }

      setState(() {
        saving = false;
      });

    } else {
      _deleteAdmin();
    }
  }

  Future<void> _findAdmin() async {
    if (_emailSearchController.text == ''){
      showSnackBar(
          'Ты не ввел Email( Как нам искать?',
          AppColors.attentionRed,
          2
      );
    } else {

      setState(() {
        loading = true;
        user = PlaceUser();
        showNotFound = false;
      });

      PlaceUser foundUser = await user.getPlaceUserByEmail(_emailSearchController.text);

      if (foundUser.uid != ''){
        if (foundUser.uid == _place.creatorId){
          setState(() {
            chosenRole = chosenRole.getPlaceUserRole(PlaceUserRoleEnum.creator);
            foundUser.placeUserRole = chosenRole;
          });
        } else{
          setState(() {
            chosenRole = chosenRole.searchPlaceUserRoleInAdminsList(admins, foundUser);
            foundUser.placeUserRole = chosenRole;
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

}