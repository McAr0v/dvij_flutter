import 'package:dvij_flutter/cities/city_class.dart';
import 'package:dvij_flutter/places/place_category_class.dart';
import 'package:dvij_flutter/elements/text_and_icons_widgets/for_cards_small_widget_with_icon_and_text.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/places/place_class.dart';
import 'now_is_work_widget.dart';

class PlaceCardWidget extends StatelessWidget {
  final Place place;
  final Function()? onFavoriteIconPressed; // Добавьте функцию обратного вызова
  final Function()? onTap; // Добавьте функцию обратного вызова
  Color surfaceColor;

  PlaceCardWidget({super.key, required this.place, this.onFavoriteIconPressed, required this.onTap, this.surfaceColor = AppColors.greyOnBackground});

  @override
  Widget build(BuildContext context) {

    bool isOpen = false;

    if (place.nowIsOpen == 'true') isOpen = true;

    String placeCategory = PlaceCategory.getPlaceCategoryFromCategoriesList(place.category).name;
    String placeCity = City.getCityByIdFromList(place.city).name;

    return GestureDetector(
      onTap: onTap,
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
                      text: placeCategory,
                      iconColor: AppColors.white,
                      side: true,
                      backgroundColor: AppColors.greyBackground.withOpacity(0.8)
                  ),
                ),
              ],
            ),
            // Фон с информацией
            Container(
              color: surfaceColor, // Полупрозрачный черный цвет
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
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
                    '$placeCity, ${place.street}, ${place.house}',
                    style: Theme.of(context).textTheme.labelMedium,
                    softWrap: true,
                  ),
                  SizedBox(height: 10.0),

                  NowIsWorkWidget(isTrue: isOpen),

                  const SizedBox(height: 10.0),

                  /*Text(
                    place.desc,
                    style: Theme.of(context).textTheme.bodyMedium,

                  ),*/

                  /*Text.rich(
                    TextSpan(
                      text: place.desc.length > 100 ? '${place.desc.substring(0, 100)}...' : place.desc,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),*/

                  Text.rich(
                    TextSpan(
                      text: place.desc,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    maxLines: 4, // Установите желаемое количество строк
                    overflow: TextOverflow.ellipsis, // Определяет, что делать с текстом, который не помещается в виджет
                  ),


                  SizedBox(height: 10.0),

                  Row(
                    children: [
                      SmallWidgetForCardsWithIconAndText(
                        icon: Icons.event,
                        text: 'Мероприятий: ${place.eventsCount}',
                        side: true,
                        iconColor: AppColors.white,
                        backgroundColor: surfaceColor == AppColors.greyOnBackground ? AppColors.greyBackground : AppColors.greyOnBackground,
                      ),

                      SizedBox(width: 10.0),

                      SmallWidgetForCardsWithIconAndText(
                        icon: Icons.event,
                        text: 'Акций: ${place.promoCount}',
                        side: true,
                        iconColor: AppColors.white,
                        backgroundColor: surfaceColor == AppColors.greyOnBackground ? AppColors.greyBackground : AppColors.greyOnBackground,
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