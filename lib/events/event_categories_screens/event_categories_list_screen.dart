import 'package:dvij_flutter/elements/snack_bar.dart';
import 'package:dvij_flutter/events/event_category_class.dart';
import 'package:dvij_flutter/events/event_extensions.dart';
import 'package:flutter/material.dart';
import '../../elements/loading_screen.dart';
import '../../themes/app_colors.dart';
import '../event_category_elements/event_category_element_in_categories_screen.dart';
import 'event_category_add_or_edit_screen.dart';

class EventCategoriesListScreen extends StatefulWidget {
  const EventCategoriesListScreen({Key? key}) : super(key: key);

  @override
  EventCategoriesListScreenState createState() => EventCategoriesListScreenState();
}

class EventCategoriesListScreenState extends State<EventCategoriesListScreen> {

  List<EventCategory> _categories = [];

  bool _isAscending = true;

  bool loading = true;

  @override
  void initState() {
    super.initState();

    loading = true;
    if (EventCategory.currentEventCategoryList.isNotEmpty)
    {
      _categories = EventCategory.currentEventCategoryList;
    }
    loading = false;

  }

  void _showSnackBar(String message, Color color, int showTime) {
    showSnackBar(context, message, color, showTime);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Список категорий мероприятий'),

          actions: [

            // ---- ИКОНКА СОРТИРОВКИ -----

            IconButton(
              icon: Icon(
                Icons.sort,
                color: _isAscending ? AppColors.white : AppColors.brandColor,
              ),
              onPressed: () {
                setState(() {
                  _isAscending = !_isAscending;
                });
                _categories.sortEventCategories(_isAscending);
              },
            ),

            // --- ИКОНКА ДОБАВЛЕНИЯ ---

            IconButton(
              icon: const Icon(Icons.add),
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

        // ----- ЭКРАН ------

        body: Stack (
          children: [
            if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка категорий мероприятий')
            else if (_categories.isEmpty) const Center(child: Text('Список категорий мероприятий пуст'))
            else ListView.builder(
                  padding: const EdgeInsets.all(20.0),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    // ----- ШАБЛОН ЭЛЕМЕНТА ----
                    return EventCategoryElementInCategoriesScreen(
                        eventCategory:  _categories[index],
                        index: index,
                        onTapMethod:  () async {

                          setState(() {
                            loading = true;
                          });

                          String result = await _categories[index].deleteEntityFromDb();

                          if (result == 'success') {
                            setState(() {
                              _categories = EventCategory.currentEventCategoryList;
                            });
                            //_getCitiesFromDatabase();
                            _showSnackBar('Категория успешно удалена', Colors.green, 3);
                          } else {
                            _showSnackBar('Произошла ошибка удаления категории(', AppColors.attentionRed, 3);
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
