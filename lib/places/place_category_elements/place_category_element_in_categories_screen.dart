import 'package:dvij_flutter/places/place_category_class.dart';
import 'package:flutter/material.dart';
import '../place_categories_screens/place_category_add_or_edit_screen.dart';

class PlaceCategoryElementInCategoriesScreen extends StatelessWidget {
  final PlaceCategory placeCategory;
  final VoidCallback onTapMethod;
  final int index;

  const PlaceCategoryElementInCategoriesScreen({
    Key? key,
    required this.placeCategory,
    required this.onTapMethod,
    required this.index
  })
      : super(key: key);

  // ----- Виджет элемента списка городов на экране редактирования городов -----

  @override
  Widget build(BuildContext context) {

    // ---- Все помещаем в колонку -----
    return Column(
      children: [

        // ----- Теперь в строки
        Row(
          children: [
            // Порядковый номер строки
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
              child: Text(
                '${index + 1}.',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            // Название города и ID
            // Expanded чтобы занимала все свободное пространство
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Название города -----
                  Text(
                    placeCategory.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  // ---- ID города -------
                  Text(
                    'ID: ${placeCategory.id}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),

            // Кнопки редактирования и удаления
            Row(
              children: [

                // ---- Редактирование ----
                IconButton(
                  icon: const Icon(Icons.edit),
                  // --- Уходим на экран редактирования -----
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaceCategoryEditScreen(placeCategory: placeCategory),
                      ),
                    );
                  },
                ),

                // ---- Удаление ------

                IconButton(
                  icon: const Icon(Icons.delete),

                  // ---- Запускаем функцию удаления города ----

                  onPressed: onTapMethod,
                ),
              ],
            ),
          ],
        ),

        // ---- Расстояние между элементами -----
        const SizedBox(height: 15.0),
      ],
    );
  }
}