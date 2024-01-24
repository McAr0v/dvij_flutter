import 'package:dvij_flutter/classes/city_class.dart';
import 'package:dvij_flutter/classes/event_category_class.dart';
import 'package:dvij_flutter/classes/event_class.dart';
import 'package:dvij_flutter/classes/place_category_class.dart';
import 'package:dvij_flutter/elements/buttons/custom_only_text_button.dart';
import 'package:dvij_flutter/elements/events_elements/today_widget.dart';
import 'package:dvij_flutter/elements/for_cards_small_widget_with_icon_and_text.dart';
import 'package:dvij_flutter/methods/date_functions.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/classes/place_class.dart';

import '../../screens/places/place_view_screen.dart';
import '../places_elements/now_is_work_widget.dart';

class EventCardWidget extends StatelessWidget {
  final EventCustom event;
  final Function()? onFavoriteIconPressed; // Добавьте функцию обратного вызова
  final Function()? onTap; // Добавьте функцию обратного вызова

  const EventCardWidget({super.key, required this.event, this.onFavoriteIconPressed, required this.onTap});

  @override
  Widget build(BuildContext context) {

    bool today = false;

    int currentDayOfWeek = DateTime.now().weekday;

    if (event.today == 'true') today = true;

    String eventCategory = EventCategory.getEventCategoryFromCategoriesList(event.category).name;
    String eventCity = City.getCityByIdFromList(event.city).name;

    // Здесь хранятся выбранные даты нерегулярных дней
    List<DateTime> chosenIrregularDays = [];
    // Это список для временного хранения дат в стринге из БД при парсинге
    List<String> tempIrregularDaysString = [];
    // Выбранные даты начала
    List<String> chosenIrregularStartTime = [];
    // Выбранные даты завершения
    List<String> chosenIrregularEndTime = [];

    if (event.irregularDays != ''){
      parseInputString(event.irregularDays, tempIrregularDaysString, chosenIrregularStartTime, chosenIrregularEndTime);

      for (String date in tempIrregularDaysString){
        // Преобразуем даты из String в DateTime и кидаем в нужный список
        chosenIrregularDays.add(getDateFromString(date));
      }
    }


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
                      image: NetworkImage(event.imageUrl), // Используйте ссылку на изображение из вашего Place
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
                    text: '${event.addedToFavouritesCount}',
                    iconColor: event.inFav == 'true' ? AppColors.brandColor : AppColors.white,
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
                      text: eventCategory,
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
                    event.headline,
                    style: Theme.of(context).textTheme.titleMedium,
                    softWrap: true,
                  ),
                  //SizedBox(height: 8.0),

                  // TODO Сделать отображение заведения если проходит в нем

                  Text(
                    '$eventCity, ${event.street}, ${event.house}',
                    style: Theme.of(context).textTheme.labelMedium,
                    softWrap: true,
                  ),
                  SizedBox(height: 10.0),

                  Text('Открыто Сегодня - ${event.today}'),

                  Text(extractDateOrTimeFromJson(event.onceDay, 'date')),
                  Text('StartTime = ${extractDateOrTimeFromJson(event.onceDay, 'startTime')}'),
                  Text('FinishTime = ${extractDateOrTimeFromJson(event.onceDay, 'endTime')}'),

                  if (event.longDays != '') Text(extractDateOrTimeFromJson(event.longDays, 'startDate')),
                  if (event.longDays != '') Text(extractDateOrTimeFromJson(event.longDays, 'endDate')),

                  if (event.regularDays != '') Text('RegularsDays'),

                  if (event.regularDays != '') Text(extractDateOrTimeFromJson(event.regularDays, 'startTime$currentDayOfWeek')),
                  if (event.regularDays != '') Text(extractDateOrTimeFromJson(event.regularDays, 'endTime$currentDayOfWeek')),
                  if (event.regularDays != '') Text('День недели - $currentDayOfWeek'),

                  if (event.irregularDays != '') Column(
                    children: List.generate(chosenIrregularDays.length, (index) {
                      return Column(
                          children: [
                            Text('Дата$index - ${chosenIrregularDays[index].year}.${chosenIrregularDays[index].month}.${chosenIrregularDays[index].day}'),
                            Text('Время$index - ${chosenIrregularStartTime[index]}--${chosenIrregularEndTime[index]}'),
                          ]
                        );
                      }
                    ),
                  ),

                  Text('${event.eventType}'),

                  if (today) TodayWidget(isTrue: today),

                  NowIsWorkWidget(isTrue: today),

                  const SizedBox(height: 10.0),

                  Text.rich(
                    TextSpan(
                      text: event.desc,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    maxLines: 4, // Установите желаемое количество строк
                    overflow: TextOverflow.ellipsis, // Определяет, что делать с текстом, который не помещается в виджет
                  ),


                  /*SizedBox(height: 10.0),

                  Row(
                    children: [
                      SmallWidgetForCardsWithIconAndText(
                        icon: Icons.event,
                        text: 'Мероприятий: ${event.eventsCount}',
                        side: true,
                        iconColor: AppColors.white,
                        backgroundColor: AppColors.greyBackground,
                      ),

                      SizedBox(width: 10.0),

                      SmallWidgetForCardsWithIconAndText(
                        icon: Icons.event,
                        text: 'Акций: ${event.promoCount}',
                        side: true,
                        iconColor: AppColors.white,
                        backgroundColor: AppColors.greyBackground,
                      )
                    ],
                  ),*/

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

  void parseInputString(
      String inputString, List<String> datesList, List<String> startTimeList, List<String> endTimeList) {
    RegExp dateRegExp = RegExp(r'"date": "([^"]+)"');
    RegExp startTimeRegExp = RegExp(r'"startTime": "([^"]+)"');
    RegExp endTimeRegExp = RegExp(r'"endTime": "([^"]+)"');

    List<Match> matches = dateRegExp.allMatches(inputString).toList();
    for (Match match in matches) {
      datesList.add(match.group(1)!);
    }

    matches = startTimeRegExp.allMatches(inputString).toList();
    for (Match match in matches) {
      startTimeList.add(match.group(1)!);
    }

    matches = endTimeRegExp.allMatches(inputString).toList();
    for (Match match in matches) {
      endTimeList.add(match.group(1)!);
    }
  }

}