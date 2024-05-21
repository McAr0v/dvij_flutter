import 'package:dvij_flutter/places/place_class.dart';
import 'package:dvij_flutter/current_user/user_class.dart';
import 'package:dvij_flutter/elements/social_elements/social_buttons_mini_widget.dart';
import 'package:dvij_flutter/widgets_global/social_widgets/social_buttons_widget.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../cities/city_class.dart';

class UserElementWidget extends StatelessWidget {
  final UserCustom user;

  const UserElementWidget({
    Key? key,
    required this.user,
  })
      : super(key: key);

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
                    'Организатор мероприятия',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20,),

        SocialButtonsMiniWidget(telegramUsername: user.telegram, instagramUsername: user.instagram, whatsappUsername: user.whatsapp, phoneNumber: user.phone,),

      ],
    );
  }
}