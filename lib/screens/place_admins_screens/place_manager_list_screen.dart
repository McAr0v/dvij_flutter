import 'package:dvij_flutter/classes/place_category_class.dart';
import 'package:dvij_flutter/classes/place_role_class.dart';
import 'package:dvij_flutter/classes/user_class.dart';
import 'package:dvij_flutter/elements/place_category_elements/place_category_element_in_categories_screen.dart';
import 'package:dvij_flutter/elements/place_roles_elements/place_role_element_in_roles_screen.dart';
import 'package:dvij_flutter/elements/places_elements/place_managers_element_list_item.dart';
import 'package:dvij_flutter/screens/place_admins_screens/place_manager_add_screen.dart';
import 'package:dvij_flutter/screens/place_categories_screens/place_category_add_or_edit_screen.dart';
import 'package:dvij_flutter/screens/place_roles_screens/place_roles_add_or_edit_screen.dart';
import 'package:flutter/material.dart';
import '../../elements/custom_snack_bar.dart';
import '../../elements/loading_screen.dart';
import '../../themes/app_colors.dart';

class PlaceManagersListScreen extends StatefulWidget {
  final String placeId;

  const PlaceManagersListScreen({Key? key, required this.placeId}) : super(key: key);

  @override
  _PlaceManagersListScreenState createState() => _PlaceManagersListScreenState();
}

// ---- Страница списка городов (Должна быть доступна только для админа)------

class _PlaceManagersListScreenState extends State<PlaceManagersListScreen> {

  // Список городов
  List<PlaceRole> _roles = [];

  List<UserCustom> users = [];

  // Переменная для отслеживания направления сортировки
  bool _isAscending = true;

  // Переменная, включающая экран загрузки
  bool loading = true;

  // --- Инициализируем состояние экрана ----
  @override
  void initState(){
    super.initState();

    _initializeData();
  }

  Future<void> _initializeData() async {

    setState(() {
      loading = true;
    });
    // Получаем список городов
    //_getCitiesFromDatabase();

    if (PlaceCategory.currentPlaceCategoryList.isNotEmpty)
    {
      _roles = PlaceRole.currentPlaceRoleList;
    }

    users = await UserCustom.getPlaceAdminsUsers(widget.placeId);

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
          title: const Text('Список управляющих местом'),

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
                UserCustom.sortUsersByName (users, _isAscending);

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
                    builder: (context) => PlaceManagerAddScreen(placeId: widget.placeId),
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
            if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка управляющих')
            // --- ЕСЛИ ГОРОДОВ НЕТ -----
            else if (users.isEmpty) const Center(child: Text('Список управляющих пуст'))
            // --- ЕСЛИ ГОРОДА ЗАГРУЗИЛИСЬ
            else ListView.builder(
                // Открываем создатель списков
                  padding: const EdgeInsets.all(20.0),
                  itemCount: users.length,
                  // Шаблоны для элементов
                  itemBuilder: (context, index) {
                    return PlaceManagersElementListItem(
                        user: users[index],
                        showButton: true,
                      onTapMethod: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PlaceManagerAddScreen(placeId: widget.placeId))
                        );
                      },
                    );
                  }
              )
          ],
        )
    );
  }
}
