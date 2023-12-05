import 'package:flutter/material.dart';
import '../../cities/city_class.dart';
import '../../screens/cities_screens/city_add_or_edit_screen.dart';

class CityElementInCitiesScreen extends StatelessWidget {
  final City city;
  final VoidCallback onTapMethod;
  final int index;

  const CityElementInCitiesScreen({
    Key? key,
    required this.city,
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
                    city.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  // ---- ID города -------
                  Text(
                    'ID: ${city.id}',
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
                  icon: Icon(Icons.edit),
                  // --- Уходим на экран редактирования -----
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CityEditScreen(city: city),
                      ),
                    );
                  },
                ),

                // ---- Удаление ------

                IconButton(
                  icon: Icon(Icons.delete),

                  // ---- Запускаем функцию удаления города ----

                  onPressed: onTapMethod,
                ),
              ],
            ),
          ],
        ),

        // ---- Расстояние между элементами -----
        SizedBox(height: 15.0),
      ],
    );
  }
}