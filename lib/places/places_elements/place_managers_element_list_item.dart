import 'package:dvij_flutter/classes/user_class.dart';
import 'package:flutter/material.dart';
import '../../places/place_role_class.dart';

class PlaceManagersElementListItem extends StatelessWidget {
  final UserCustom user;
  final VoidCallback onTapMethod;
  final bool showButton;

  const PlaceManagersElementListItem({
    Key? key,
    required this.user,
    required this.showButton,
    this.onTapMethod = _defaultOnTap,
  })
      : super(key: key);

  // Метод, который будет использоваться по умолчанию, если не передан onTapMethod
  static void _defaultOnTap() {

  }
  // ----- Виджет элемента списка городов на экране редактирования городов -----

  @override
  Widget build(BuildContext context) {

    // ---- Все помещаем в колонку -----
    return Column(
      children: [
        Row(
          children: [
            // Аватарка
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey, // Цвет фона, который будет виден во время загрузки
              child: ClipOval(
                child: FadeInImage(
                  placeholder: const AssetImage('assets/u_user.png'),
                  image: NetworkImage(user.avatar),
                  fit: BoxFit.cover,
                  width: 60,
                  height: 60,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Image.asset('assets/error_image.png'); // Изображение ошибки, если загрузка не удалась
                  },
                ),
              ),
            ),

            const SizedBox(width: 15.0),

            // Имя и Email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.name} ${user.lastname}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                  ),

                  const SizedBox(height: 5.0),

                  Text(
                    user.roleInPlace != null ? PlaceRole.getPlaceRoleName(user.roleInPlace!) : 'Роль не выбрана',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  const SizedBox(height: 5.0),

                  Text(
                    user.roleInPlace != null ? PlaceRole.getPlaceRoleDesc(user.roleInPlace!) : '',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 15.0),

            // ---- Редактирование ----

            if (showButton && user.roleInPlace != '-NngrYovmKAw_cp0pYfJ') IconButton(
              icon: const Icon(Icons.edit),
              // --- Уходим на экран редактирования -----
              onPressed: onTapMethod,
            ),
          ],
        ),
        const SizedBox(height: 20,)
      ],
    );
  }
}