import 'package:dvij_flutter/classes/event_category_class.dart';
import 'package:dvij_flutter/classes/place_category_class.dart';
import 'package:dvij_flutter/elements/event_category_elements/event_category_element_in_categories_screen.dart';
import 'package:dvij_flutter/elements/place_category_elements/place_category_element_in_categories_screen.dart';
import 'package:dvij_flutter/elements/promo_category_elements/promo_category_element_in_categories_screen.dart';
import 'package:dvij_flutter/screens/place_categories_screens/place_category_add_or_edit_screen.dart';
import 'package:dvij_flutter/screens/promo_categories_screen/promo_category_add_or_edit_screen.dart';
import 'package:flutter/material.dart';
import '../../classes/promo_category_class.dart';
import '../../elements/custom_snack_bar.dart';
import '../../elements/loading_screen.dart';
import '../../elements/snack_bar.dart';
import '../../themes/app_colors.dart';

class PromoCategoriesListScreen extends StatefulWidget {
  const PromoCategoriesListScreen({Key? key}) : super(key: key);

  @override
  _PromoCategoriesListScreenState createState() => _PromoCategoriesListScreenState();
}

// ---- Страница списка городов (Должна быть доступна только для админа)------

class _PromoCategoriesListScreenState extends State<PromoCategoriesListScreen> {

  // Список городов
  List<PromoCategory> _categories = [];

  // Переменная для отслеживания направления сортировки
  bool _isAscending = true;

  // Переменная, включающая экран загрузки
  bool loading = true;
  bool deleting = false;

  // --- Инициализируем состояние экрана ----
  @override
  void initState() {
    super.initState();

    // Влючаем экран загрузки
    loading = true;
    // Получаем список городов
    //_getCitiesFromDatabase();

    if (PromoCategory.currentPromoCategoryList.isNotEmpty)
    {
      _categories = PromoCategory.currentPromoCategoryList;
    }

    loading = false;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- Верхняя панель -----
        appBar: AppBar(
          title: const Text('Список категорий акций'),

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
                PromoCategory.sortPromoCategoryByName(_categories, _isAscending);
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
                    builder: (context) => const PromoCategoryAddOrEditScreen(),
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
            if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка категорий акций')
            else if (deleting) const LoadingScreen(loadingText: "Удаляем категорию",)
            // --- ЕСЛИ ГОРОДОВ НЕТ -----
            else if (_categories.isEmpty) const Center(child: Text('Список категорий акций пуст'))
            // --- ЕСЛИ ГОРОДА ЗАГРУЗИЛИСЬ
            else ListView.builder(
                // Открываем создатель списков
                  padding: const EdgeInsets.all(20.0),
                  itemCount: _categories.length,
                  // Шаблоны для элементов
                  itemBuilder: (context, index) {
                    return PromoCategoryElementInCategoriesScreen(
                        promoCategory: _categories[index],
                        onTapMethod: () async {

                          setState(() {
                            deleting = true;
                          });

                          String result = await PromoCategory.deletePromoCategory(_categories[index].id);

                          if (result == 'success') {
                            setState(() {
                              _categories = PromoCategory.currentPromoCategoryList;
                            });

                            _showSnackBar('Категория успешно удалена', Colors.green, 3);

                          } else {
                            _showSnackBar('Произошла ошибка удаления категории(', AppColors.attentionRed, 3);
                          }

                          setState(() {
                            deleting = false;
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

  void _showSnackBar(String text, Color color, int time){
    showSnackBar(context, text, color, time);
  }
}
