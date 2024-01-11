import 'package:dvij_flutter/classes/place_category_class.dart';
import 'package:dvij_flutter/screens/place_categories_screens/place_category_add_or_edit_screen.dart';
import 'package:dvij_flutter/screens/place_roles_screens/place_roles_add_or_edit_screen.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';

import '../../classes/place_role_class.dart';

class PlaceRoleElementInRolesScreen extends StatelessWidget {
  final PlaceRole placeRole;
  final VoidCallback onTapMethod;
  final int index;

  const PlaceRoleElementInRolesScreen({
    Key? key,
    required this.placeRole,
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
                    placeRole.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  // ---- ID города -------
                  Text(
                    'ID: ${placeRole.id}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 5,),
                  Text(
                    'Уровень доступа: ${placeRole.controlLevel}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 5,),
                  Text(
                    'Описание: ${placeRole.desc}',
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
                        builder: (context) => PlaceRoleAddOrEditScreen(placeRole: placeRole),
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
        const SizedBox(height: 15,),
        const Divider(
          color: AppColors.greyText, // Цвет линии
          thickness: 1.0,     // Толщина линии
        ),
        // ---- Расстояние между элементами -----
        const SizedBox(height: 15.0),
      ],
    );
  }
}