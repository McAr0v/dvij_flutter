import 'package:dvij_flutter/current_user/user_class.dart';
import 'package:dvij_flutter/elements/users_list_elements/user_element_in_users_list.dart';
import 'package:dvij_flutter/users_mixin/users_lists_mixin.dart';
import 'package:flutter/material.dart';
import '../../elements/custom_snack_bar.dart';
import '../../elements/loading_screen.dart';
import '../../themes/app_colors.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({Key? key}) : super(key: key);

  @override
  _UsersListScreenState createState() => _UsersListScreenState();
}

// ---- Страница списка ролей (Должна быть доступна только для админа)------

class _UsersListScreenState extends State<UsersListScreen> with UsersListsMixin {

  // Список пользователей
  List<UserCustom> _usersList = [];

  // Переменная для отслеживания направления сортировки
  bool _isAscending = true;

  // Переменная, включающая экран загрузки
  bool loading = true;

  //List<String> rolesList = [];

  @override
  void initState() {
    super.initState();
    // Call the asynchronous initialization method
    _initializeData();
  }

  // Asynchronous initialization method
  Future<void> _initializeData() async {


    // Enable loading screen
    setState(() {
      //rolesList.clear();
      loading = true;
    });

    // Retrieve the list of users asynchronously
    if (UsersListsMixin.downloadedUsers.isNotEmpty){
      _usersList = UsersListsMixin.downloadedUsers;
    } else {
      _usersList = await getAllUsersFromDb();
    }


    //rolesList = await setRoleName(_usersList);

    // Disable loading screen
    setState(() {
      loading = false;
    });
  }


  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- Верхняя панель -----
        appBar: AppBar(
          title: const Text('Список пользователей'),

          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              // Ваш кастомный стиль для иконки
            ),
            onPressed: () {
              // Ваш обработчик события для кнопки "назад"
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/Events', // Название маршрута, которое вы задаете в MaterialApp
                    (route) => false,
              );
            },
          ),

          // ---- Кнопки управления в AppBar ---
          actions: [

            // СОРТИРОВКА

            IconButton(
              icon: Icon(
                Icons.sort,
                color: _isAscending ? AppColors.white : AppColors.brandColor, // Изменение цвета иконки
              ),
              onPressed: () {
                // Инвертируем направление сортировки
                setState(() {
                  _isAscending = !_isAscending;
                });
                // Сортируем список ролей
                sortUsersByEmail(_usersList, _isAscending);

              },
            ),
          ],
        ),

        // ----- Само тело экрана ------

        body: Stack (
          children: [
            // --- ЕСЛИ ЭКРАН ЗАГРУЗКИ -----
            if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка пользователей')
            // --- ЕСЛИ ГОРОДОВ НЕТ -----
            else if (_usersList.isEmpty) const Center(child: Text('Список пользователей пуст'))
            // --- ЕСЛИ ГОРОДА ЗАГРУЗИЛИСЬ
            else ListView.builder(
                // Открываем создатель списков
                  padding: const EdgeInsets.all(20.0),
                  itemCount: _usersList.length,
                  // Шаблоны для элементов
                  itemBuilder: (context, index) {
                    return UserElementInUsersListScreen(
                        user: _usersList[index],
                        //roleName: rolesList[index],
                        onTapMethod: () async {
                          /*
                          setState(() {

                            loading = true;
                          });

                          String result = await RoleInApp.deleteRoleInApp(_usersList[index].id);

                          if (result == 'success') {
                            setState(() {
                              _usersList = UserCustom.getAllUsers(order: _isAscending) as List<UserCustom>;
                            });
                            //_getCitiesFromDatabase();
                            showSnackBar('Роль успешно удалена', Colors.green, 3);
                          } else {
                            showSnackBar('Произошла ошибка удаления роли(', AppColors.attentionRed, 3);
                          }

                          setState(() {
                            loading = false;
                          });*/

                        },
                        index: index);
                  }
              )
          ],
        )
    );
  }

}
