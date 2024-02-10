import 'package:dvij_flutter/places/place_category_class.dart';
import 'package:dvij_flutter/places/place_role_class.dart';
import 'package:dvij_flutter/places/place_roles_screens/place_roles_add_or_edit_screen.dart';
import 'package:flutter/material.dart';
import '../../elements/custom_snack_bar.dart';
import '../../elements/loading_screen.dart';
import '../../themes/app_colors.dart';
import '../place_roles_elements/place_role_element_in_roles_screen.dart';

class PlaceRolesListScreen extends StatefulWidget {
  const PlaceRolesListScreen({Key? key}) : super(key: key);

  @override
  PlaceRolesListScreenState createState() => PlaceRolesListScreenState();
}

// ---- Страница списка городов (Должна быть доступна только для админа)------

class PlaceRolesListScreenState extends State<PlaceRolesListScreen> {

  // Список городов
  List<PlaceRole> _roles = [];

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
    // Получаем список городов
    //_getCitiesFromDatabase();

    if (PlaceCategory.currentPlaceCategoryList.isNotEmpty)
    {
      _roles = PlaceRole.currentPlaceRoleList;
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
          title: const Text('Список ролей мест'),

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
                // Сортируем список городов
                //PlaceRole.sortPlaceRolesByName(_roles, _isAscending);
                PlaceRole.sortPlaceRolesByControlLevel(_roles, _isAscending);

              },
            ),

            // Добавление нового города

            IconButton(
              icon: const Icon(Icons.add),

              // Переход на страницу создания города
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlaceRoleAddOrEditScreen(),
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
            if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка категорий мест')
            // --- ЕСЛИ ГОРОДОВ НЕТ -----
            else if (_roles.isEmpty) const Center(child: Text('Список ролей мест пуст'))
            // --- ЕСЛИ ГОРОДА ЗАГРУЗИЛИСЬ
            else ListView.builder(
                // Открываем создатель списков
                  padding: const EdgeInsets.all(20.0),
                  itemCount: _roles.length,
                  // Шаблоны для элементов
                  itemBuilder: (context, index) {
                    return PlaceRoleElementInRolesScreen(
                        placeRole: _roles[index],
                        onTapMethod: () async {

                          setState(() {
                            loading = true;
                          });

                          String result = await PlaceRole.deletePlaceRole(_roles[index].id);

                          if (result == 'success') {
                            setState(() {
                              _roles = PlaceRole.currentPlaceRoleList;
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
                        index: index
                    );
                  }
              )
          ],
        )
    );
  }
}
