import 'package:dvij_flutter/screens/genders_screens/gender_add_or_edit_screen.dart';
import 'package:flutter/material.dart';
import '../../classes/gender_class.dart';

class GenderElementInGendersScreen extends StatelessWidget {
  final Gender gender;
  final VoidCallback onTapMethod;
  final int index;

  const GenderElementInGendersScreen({
    Key? key,
    required this.gender,
    required this.onTapMethod,
    required this.index
  })
      : super(key: key);

  // ----- Виджет элемента списка гендеров на экране редактирования гендеров -----

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
            // Название гендера и ID
            // Expanded чтобы занимала все свободное пространство
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Название города -----
                  Text(
                    gender.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  // ---- ID города -------
                  Text(
                    'ID: ${gender.id}',
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
                        builder: (context) => GenderEditScreen(gender: gender),
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