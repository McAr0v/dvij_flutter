import 'package:dvij_flutter/elements/buttons/custom_only_text_button.dart';
import 'package:dvij_flutter/elements/for_cards_small_widget_with_icon_and_text.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/classes/place_class.dart';

import '../../screens/places/place_view_screen.dart'; // Убедитесь, что вы импортируете ваш класс Place

class PlaceCardWidget extends StatelessWidget {
  final Place place;
  final Function()? onFavoriteIconPressed; // Добавьте функцию обратного вызова

  const PlaceCardWidget({super.key, required this.place, this.onFavoriteIconPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to PlaceViewScreen when the card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceViewScreen(placeId: place.id),
          ),
        );
      },
      child: Card(

        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Изображение
            Stack(
              alignment: Alignment.topRight,
              children: [
                // Изображение
                Container(
                  height: MediaQuery.of(context).size.width * 0.7, // Ширина экрана
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(place.imageUrl), // Используйте ссылку на изображение из вашего Place
                      fit: BoxFit.cover,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                  ),
                ),
                // Значок избранных
                Positioned(
                  top: 10.0,
                  right: 10.0,
                  child: SmallWidgetForCardsWithIconAndText(
                    icon: Icons.bookmark,
                    text: '${place.addedToFavouritesCount}',
                    iconColor: place.inFav == 'true' ? AppColors.brandColor : AppColors.white,
                    side: false,
                    backgroundColor: AppColors.greyBackground.withOpacity(0.8),
                    onPressed: onFavoriteIconPressed,
                  ),
                ),

                Positioned(
                  top: 10.0,
                  left: 10.0,
                  child: SmallWidgetForCardsWithIconAndText(
                    //icon: Icons.visibility,
                      text: place.category,
                      iconColor: AppColors.white,
                      side: true,
                      backgroundColor: AppColors.greyBackground.withOpacity(0.8)
                  ),
                ),
              ],
            ),
            // Фон с информацией
            Container(
              color: AppColors.greyOnBackground, // Полупрозрачный черный цвет
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    place.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    softWrap: true,
                  ),
                  //SizedBox(height: 8.0),
                  Text(
                    '${place.city}, ${place.street}, ${place.house}',
                    style: Theme.of(context).textTheme.labelMedium,
                    softWrap: true,
                  ),
                  SizedBox(height: 10.0),

                  /*Text(
                    place.desc,
                    style: Theme.of(context).textTheme.bodyMedium,

                  ),*/

                  Text.rich(
                    TextSpan(
                      text: place.desc.length > 100 ? '${place.desc.substring(0, 100)}...' : place.desc,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),


                  SizedBox(height: 10.0),

                  Row(
                    children: [
                      SmallWidgetForCardsWithIconAndText(
                        icon: Icons.event,
                        text: 'Мероприятий: ${place.eventsCount}',
                        side: true,
                        iconColor: AppColors.white,
                        backgroundColor: AppColors.greyBackground,
                      ),

                      SizedBox(width: 10.0),

                      SmallWidgetForCardsWithIconAndText(
                        icon: Icons.event,
                        text: 'Акций: ${place.eventsCount}',
                        side: true,
                        iconColor: AppColors.white,
                        backgroundColor: AppColors.greyBackground,
                      )
                    ],
                  ),

                  SizedBox(height: 10.0),

                  // Дополнительные поля, например, мероприятия, избранное и т.д.
                  // Их можно заполнить данными из вашей базы данных
                  // ...

                  // Кнопки редактирования и удаления, если есть доступ к редактированию
                  /*if (place.canEdit == 'true')
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomOnlyTextButton(
                          buttonText: 'Редактировать',
                          textColor: Colors.green,
                        ),
                      ],
                    ),*/
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}