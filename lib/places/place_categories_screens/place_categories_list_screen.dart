import 'package:dvij_flutter/places/place_categories_screens/place_category_add_or_edit_screen.dart';
import 'package:dvij_flutter/places/place_category_class.dart';
import 'package:dvij_flutter/places/place_extensions.dart';
import 'package:flutter/material.dart';
import '../../elements/custom_snack_bar.dart';
import '../../elements/loading_screen.dart';
import '../../themes/app_colors.dart';
import '../place_category_elements/place_category_element_in_categories_screen.dart';

class PlaceCategoriesListScreen extends StatefulWidget {
  const PlaceCategoriesListScreen({Key? key}) : super(key: key);

  @override
  PlaceCategoriesListScreenState createState() => PlaceCategoriesListScreenState();
}

// ---- Страница списка городов (Должна быть доступна только для админа)------

class PlaceCategoriesListScreenState extends State<PlaceCategoriesListScreen> {

  // Список городов
  List<PlaceCategory> _categories = [];

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

    if (PlaceCategory.currentPlaceCategoryList.isNotEmpty)
    {
      _categories = PlaceCategory.currentPlaceCategoryList;
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
          title: const Text('Список категорий мест'),

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
                _categories.sortPlaceCategories(_isAscending);

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
                    builder: (context) => const PlaceCategoryEditScreen(),

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
            else if (_categories.isEmpty) const Center(child: Text('Список категорий мест пуст'))
            // --- ЕСЛИ ГОРОДА ЗАГРУЗИЛИСЬ
            else ListView.builder(
                // Открываем создатель списков
                  padding: const EdgeInsets.all(20.0),
                  itemCount: _categories.length,
                  // Шаблоны для элементов
                  itemBuilder: (context, index) {
                    return PlaceCategoryElementInCategoriesScreen(
                        placeCategory: _categories[index],
                        onTapMethod: () async {

                          setState(() {
                            loading = true;
                          });

                          String result = await _categories[index].deleteEntityFromDb();

                          if (result == 'success') {
                            setState(() {
                              _categories = PlaceCategory.currentPlaceCategoryList;
                            });
                            //_getCitiesFromDatabase();
                            showSnackBar('Категория успешно удалена', Colors.green, 3);
                          } else {
                            showSnackBar('Произошла ошибка удаления категории(', AppColors.attentionRed, 3);
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
