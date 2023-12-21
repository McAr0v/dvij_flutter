import 'package:dvij_flutter/classes/role_in_app.dart';
import 'package:dvij_flutter/screens/genders_screens/gender_add_or_edit_screen.dart';
import 'package:dvij_flutter/screens/profile/edit_profile_screen.dart';
import 'package:dvij_flutter/screens/role_in_app_screens/role_in_app_add_or_edit_screen.dart';
import 'package:dvij_flutter/screens/users_list_screens/users_change_role_admin_screen.dart';
import 'package:flutter/material.dart';
import '../../classes/gender_class.dart';
import '../../classes/user_class.dart';
import '../../themes/app_colors.dart';

class UserElementInUsersListScreen extends StatelessWidget {
  final UserCustom user;
  final VoidCallback onTapMethod;
  final int index;
  final String roleName;

  const UserElementInUsersListScreen({
    Key? key,
    required this.user,
    required this.onTapMethod,
    required this.index,
    required this.roleName,
  })
      : super(key: key);

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
                  if (user.name != '') Text(
                    '${user.name} ${user.lastname}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  if (user.name == '') Text(
                    'Имя не указано',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  if (roleName != '') Text(
                    'role: $roleName',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (roleName == '')Text(
                    'role: Не указана роль',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  const SizedBox(height: 10,),

                  Text(
                    'email: ${user.email}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),

                  // ---- ID города -------
                  Text(
                    'ID: ${user.uid}',
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
                  onPressed: () async {

                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UsersChangeRoleAdminScreen(userInfo: user))
                    );



                    /*
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(userInfo: UserCustom(uid: user.uid, email: user.email, role: user.role, name: user.name, lastname: user.lastname, phone: user.phone, whatsapp: user.whatsapp, telegram: user.telegram, instagram: user.instagram, city: user.city, birthDate: user.birthDate, gender: user.gender, avatar: user.avatar)),
                      ),
                    );*/
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
        //const SizedBox(height: 15.0),

        const Divider(
          color: AppColors.greyText,
          height: 20, // Высота линии
          thickness: 2, // Толщина линии
        ),

      ],
    );
  }

}




