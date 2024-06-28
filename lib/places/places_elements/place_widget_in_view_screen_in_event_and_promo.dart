import 'package:dvij_flutter/places/place_class.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PlaceWidgetInViewScreenInEventAndPromoScreen extends StatelessWidget {
  final Place place;
  final VoidCallback onTapMethod;

  const PlaceWidgetInViewScreenInEventAndPromoScreen({
    Key? key,
    required this.place,
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
    return GestureDetector(
      onTap: onTapMethod,
      child: Column(
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
                    image: NetworkImage(place.imageUrl),
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
                      place.name,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                    ),

                    const SizedBox(height: 5.0),

                    Text(
                      '${place.city.name}, ул. ${place.street} - ${place.house}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                    const SizedBox(height: 5.0),



                    Text(
                      'Мероприятий - ${place.eventsList.length}, Акций - ${place.promosList.length}',
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                    ),

                  ],
                ),
              ),

              const SizedBox(width: 10.0),

              // ---- Редактирование ----

              IconButton(
                icon: const Icon(FontAwesomeIcons.chevronRight, size: 18,),
                // --- Уходим на экран редактирования -----
                onPressed: onTapMethod,
              ),

            ],
          ),
          //const SizedBox(height: 20,)
        ],
      ),
    );
  }
}