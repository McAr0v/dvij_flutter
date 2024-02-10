import 'package:dvij_flutter/events/event_category_class.dart';
import 'package:dvij_flutter/events/event_extensions.dart';
import 'package:flutter/material.dart';
import '../../elements/custom_snack_bar.dart';
import '../../elements/loading_screen.dart';
import '../../themes/app_colors.dart';
import '../event_category_elements/event_category_element_in_categories_screen.dart';
import 'event_category_add_or_edit_screen.dart';

class EventCategoriesListScreen extends StatefulWidget {
  const EventCategoriesListScreen({Key? key}) : super(key: key);

  @override
  EventCategoriesListScreenState createState() => EventCategoriesListScreenState();
}

// ---- Страница списка городов (Должна быть доступна только для админа)------

class EventCategoriesListScreenState extends State<EventCategoriesListScreen> {

  // Список городов
  List<EventCategory> _categories = [];

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

    if (EventCategory.currentEventCategoryList.isNotEmpty)
    {
      _categories = EventCategory.currentEventCategoryList;
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
          title: const Text('Список категорий мероприятий'),

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
                //EventCategory.sortEventCategoryByName(_categories, _isAscending);
                _categories.sortEventCategories(_isAscending);
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
                    builder: (context) => const EventCategoryAddOrEditScreen(),
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
            if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка категорий мероприятий')
            // --- ЕСЛИ ГОРОДОВ НЕТ -----
            else if (_categories.isEmpty) const Center(child: Text('Список категорий мероприятий пуст'))
            // --- ЕСЛИ ГОРОДА ЗАГРУЗИЛИСЬ
            else ListView.builder(
                // Открываем создатель списков
                  padding: const EdgeInsets.all(20.0),
                  itemCount: _categories.length,
                  // Шаблоны для элементов
                  itemBuilder: (context, index) {
                    return EventCategoryElementInCategoriesScreen(
                        eventCategory:  _categories[index],
                        index: index,
                        onTapMethod:  () async {

                          setState(() {
                            loading = true;
                          });

                          String result = await _categories[index].deleteEntityFromDb();
                          //String result = await EventCategory.deleteEventCategory(_categories[index].id);

                          if (result == 'success') {
                            setState(() {
                              _categories = EventCategory.currentEventCategoryList;
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

                    );
                  }
              )
          ],
        )
    );
  }
}
