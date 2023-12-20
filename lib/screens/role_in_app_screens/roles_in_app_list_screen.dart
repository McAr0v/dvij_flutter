import 'package:dvij_flutter/classes/role_in_app.dart';
import 'package:dvij_flutter/elements/role_in_app_elements/role_in_app_element_in_roles_in_app_screen.dart';
import 'package:dvij_flutter/screens/role_in_app_screens/role_in_app_add_or_edit_screen.dart';
import 'package:flutter/material.dart';
import '../../classes/city_class.dart';
import '../../elements/cities_elements/city_element_in_cities_screen.dart';
import '../../elements/custom_snack_bar.dart';
import '../../elements/loading_screen.dart';
import '../../themes/app_colors.dart';

class RolesInAppListScreen extends StatefulWidget {
  const RolesInAppListScreen({Key? key}) : super(key: key);

  @override
  _RolesInAppListScreenState createState() => _RolesInAppListScreenState();
}

// ---- Страница списка ролей (Должна быть доступна только для админа)------

class _RolesInAppListScreenState extends State<RolesInAppListScreen> {

  // Список ролей
  List<RoleInApp> _rolesInApp = [];

  // Переменная для отслеживания направления сортировки
  bool _isAscending = true;

  // Переменная, включающая экран загрузки
  bool loading = true;

  // --- Инициализируем состояние экрана ----
  @override
  void initState() {
    super.initState();

    // Влючаем экран загрузки
    loading = true;
    // Получаем список ролей
    //_getCitiesFromDatabase();

    if (City.currentCityList.isNotEmpty)
    {
      _rolesInApp = RoleInApp.currentRoleInAppList;
    }

    loading = false;

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
          title: const Text('Список ролей в приложении'),

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
                RoleInApp.sortRoleInAppByName(_rolesInApp, _isAscending);
              },
            ),

            // Добавление новой роли

            IconButton(
              icon: const Icon(Icons.add),

              // Переход на страницу создания роли
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RoleInAppAddOrEditScreen(),
                  ),
                );
              },
            ),
          ],
        ),

        // ----- Само тело экрана ------

        body: Stack (
          children: [
            // --- ЕСЛИ ЭКРАН ЗАГРУЗКИ -----
            if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка ролей в приложении')
            // --- ЕСЛИ ГОРОДОВ НЕТ -----
            else if (_rolesInApp.isEmpty) const Center(child: Text('Список ролей пуст'))
            // --- ЕСЛИ ГОРОДА ЗАГРУЗИЛИСЬ
            else ListView.builder(
                // Открываем создатель списков
                  padding: const EdgeInsets.all(20.0),
                  itemCount: _rolesInApp.length,
                  // Шаблоны для элементов
                  itemBuilder: (context, index) {
                    return RoleInAppElementInRoleInAppScreen(
                        roleInApp: _rolesInApp[index],
                        onTapMethod: () async {

                          setState(() {
                            loading = true;
                          });

                          String result = await RoleInApp.deleteRoleInApp(_rolesInApp[index].id);

                          if (result == 'success') {
                            setState(() {
                              _rolesInApp = RoleInApp.currentRoleInAppList;
                            });
                            //_getCitiesFromDatabase();
                            showSnackBar('Роль успешно удалена', Colors.green, 3);
                          } else {
                            showSnackBar('Произошла ошибка удаления роли(', AppColors.attentionRed, 3);
                          }

                          setState(() {
                            loading = false;
                          });

                        },
                        index: index);
                  }
              )
          ],
        )
    );
  }

}
