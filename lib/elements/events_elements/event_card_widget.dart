import 'package:dvij_flutter/classes/city_class.dart';
import 'package:dvij_flutter/classes/event_category_class.dart';
import 'package:dvij_flutter/classes/event_class.dart';
import 'package:dvij_flutter/classes/event_type_enum.dart';
import 'package:dvij_flutter/classes/place_category_class.dart';
import 'package:dvij_flutter/elements/buttons/custom_only_text_button.dart';
import 'package:dvij_flutter/elements/events_elements/today_widget.dart';
import 'package:dvij_flutter/elements/text_and_icons_widgets/for_cards_small_widget_with_icon_and_text.dart';
import 'package:dvij_flutter/elements/text_and_icons_widgets/headline_and_desc.dart';
import 'package:dvij_flutter/elements/text_and_icons_widgets/icon_and_text_widget.dart';
import 'package:dvij_flutter/methods/date_functions.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/classes/place_class.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../methods/price_methods.dart';
import '../../screens/places/place_view_screen.dart';
import '../places_elements/now_is_work_widget.dart';

class EventCardWidget extends StatelessWidget {
  final EventCustom event;
  final Function()? onFavoriteIconPressed; // Добавьте функцию обратного вызова
  final Function()? onTap; // Добавьте функцию обратного вызова

  const EventCardWidget({super.key, required this.event, this.onFavoriteIconPressed, required this.onTap});

  @override
  Widget build(BuildContext context) {

    String eventCategory = EventCategory.getEventCategoryFromCategoriesList(event.category).name;
    String eventCity = City.getCityByIdFromList(event.city).name;

    EventTypeEnum eventType = EventCustom.getEventTypeEnum(event.eventType);

    String startDate = '';
    String endDate = '';
    String startTime = '';
    String endTime = '';

    if (eventType == EventTypeEnum.once && event.onceDay != ''){
      startDate = extractDateOrTimeFromJson(event.onceDay, 'date');
      startTime = extractDateOrTimeFromJson(event.onceDay, 'startTime');
      endTime = extractDateOrTimeFromJson(event.onceDay, 'endTime');
    }
    if (eventType == EventTypeEnum.long && event.longDays != ''){
      startDate = extractDateOrTimeFromJson(event.longDays, 'startDate');
      endDate = extractDateOrTimeFromJson(event.longDays, 'endDate');
      startTime = extractDateOrTimeFromJson(event.longDays, 'startTime');
      endTime = extractDateOrTimeFromJson(event.longDays, 'endTime');
    }

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
                mainAxisAlignment: MainAxisAlignment.start,
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

                  const SizedBox(height: 10.0),

                  Row(
                    children: [
                      if (event.today == 'true') Text(
                        'Сегодня',
                        style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.green),
                      ),

                      if (event.today == 'true') const SizedBox(width: 15,),

                      if (event.placeId != '') Text(
                        'В заведении',
                        style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.green),
                      ),

                    ],
                  ),

                  const SizedBox(height: 10.0),

                  Text.rich(
                    TextSpan(
                      text: event.desc,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    maxLines: 4, // Установите желаемое количество строк
                    overflow: TextOverflow.ellipsis, // Определяет, что делать с текстом, который не помещается в виджет
                  ),

                  SizedBox(height: 20.0),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                      if (eventType == EventTypeEnum.once)  Row(
                        children: [
                          IconAndTextWidget(
                            icon: FontAwesomeIcons.calendar,
                            text: getHumanDate(startDate, '-', needYear: false),
                            textSize: 'label',
                            padding: 10,
                          ),

                          const SizedBox(width: 20,),

                          IconAndTextWidget(
                            icon: FontAwesomeIcons.clock,
                            text: 'c $startTime до $endTime',
                            textSize: 'label',
                            padding: 10,
                          ),
                        ],
                      ),

                      if (eventType == EventTypeEnum.long) Row(
                        children: [
                          IconAndTextWidget(
                              icon: FontAwesomeIcons.calendar,
                              text: '${getHumanDate(startDate, '-', needYear: false)} - ${getHumanDate(endDate, '-', needYear: false)}',
                              textSize: 'label',
                              padding: 10,
                          ),

                          const SizedBox(width: 20,),

                          IconAndTextWidget(
                            icon: FontAwesomeIcons.clock,
                            text: 'c $startTime до $endTime',
                            textSize: 'label',
                            padding: 10,
                          ),
                        ],
                      ),



                      SizedBox(height: 20,),

                      IconAndTextWidget(
                        icon: FontAwesomeIcons.dollarSign,
                        text: PriceMethods.getFormattedPriceString(event.priceType, event.price),
                        textSize: 'label',
                        padding: 10,
                      ),

                    ],
                  ),

                  SizedBox(height: 10,),

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