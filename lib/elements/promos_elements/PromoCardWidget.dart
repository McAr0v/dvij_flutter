import 'package:dvij_flutter/classes/city_class.dart';
import 'package:dvij_flutter/classes/event_category_class.dart';
import 'package:dvij_flutter/classes/event_class.dart';
import 'package:dvij_flutter/classes/date_type_enum.dart';
import 'package:dvij_flutter/classes/place_category_class.dart';
import 'package:dvij_flutter/classes/promo_category_class.dart';
import 'package:dvij_flutter/classes/promo_class.dart';
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

import '../../methods/days_functions.dart';
import '../../methods/price_methods.dart';
import '../../screens/places/place_view_screen.dart';
import '../places_elements/now_is_work_widget.dart';

class PromoCardWidget extends StatelessWidget {
  final PromoCustom promo;
  final Function()? onFavoriteIconPressed; // Добавьте функцию обратного вызова
  final Function()? onTap; // Добавьте функцию обратного вызова

  const PromoCardWidget({super.key, required this.promo, this.onFavoriteIconPressed, required this.onTap});

  @override
  Widget build(BuildContext context) {

    String promoCategory = PromoCategory.getPromoCategoryFromCategoriesList(promo.category).name;
    String promoCity = City.getCityByIdFromList(promo.city).name;

    DateTypeEnum promoType = PromoCustom.getPromoTypeEnum(promo.promoType);

    String startDate = '';
    String endDate = '';
    String startTime = '';
    String endTime = '';

    List<String> regularStartTimes = fillTimeListWithDefaultValues('Не выбрано', 7);
    List<String> regularFinishTimes = fillTimeListWithDefaultValues('Не выбрано', 7);

    DateTime timeNow = DateTime.now();
    int currentWeekDayNumber = timeNow.weekday;

    if (promoType == DateTypeEnum.once && promo.onceDay != ''){
      startDate = extractDateOrTimeFromJson(promo.onceDay, 'date');
      startTime = extractDateOrTimeFromJson(promo.onceDay, 'startTime');
      endTime = extractDateOrTimeFromJson(promo.onceDay, 'endTime');
    }
    if (promoType == DateTypeEnum.long && promo.longDays != ''){
      startDate = extractDateOrTimeFromJson(promo.longDays, 'startDate');
      endDate = extractDateOrTimeFromJson(promo.longDays, 'endDate');
      startTime = extractDateOrTimeFromJson(promo.longDays, 'startTime');
      endTime = extractDateOrTimeFromJson(promo.longDays, 'endTime');
    }

    if (promoType == DateTypeEnum.regular && promo.regularDays != ''){
      for (int i = 0; i<regularStartTimes.length; i++){

        regularStartTimes[i] = extractDateOrTimeFromJson(promo.regularDays, 'startTime${i+1}');
        regularFinishTimes[i] = extractDateOrTimeFromJson(promo.regularDays, 'endTime${i+1}');

      }
    }

    // Здесь хранятся выбранные даты нерегулярных дней
    List<DateTime> chosenIrregularDays = [];
    // Это список для временного хранения дат в стринге из БД при парсинге
    List<String> tempIrregularDaysString = [];
    // Выбранные даты начала
    List<String> chosenIrregularStartTime = [];
    // Выбранные даты завершения
    List<String> chosenIrregularEndTime = [];

    List<int> irregularTodayIndexes = [];

    if (promo.irregularDays != ''){
      parseInputString(promo.irregularDays, tempIrregularDaysString, chosenIrregularStartTime, chosenIrregularEndTime);

      for (String date in tempIrregularDaysString){
        // Преобразуем даты из String в DateTime и кидаем в нужный список
        chosenIrregularDays.add(getDateFromString(date));
      }

      for (int i = 0; i<chosenIrregularDays.length; i++){

        if (chosenIrregularDays[i].day == timeNow.day && chosenIrregularDays[i].month == timeNow.month){
          irregularTodayIndexes.add(i);
        }
      }
    }




    return GestureDetector(
      onTap: onTap,
      child: Card(

        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.only(bottom: 20),
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
                      image: NetworkImage(promo.imageUrl), // Используйте ссылку на изображение из вашего Place
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
                    text: '${promo.addedToFavouritesCount}',
                    iconColor: promo.inFav == 'true' ? AppColors.brandColor : AppColors.white,
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
                      text: promoCategory,
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
                    promo.headline,
                    style: Theme.of(context).textTheme.titleMedium,
                    softWrap: true,
                  ),
                  //SizedBox(height: 8.0),

                  // TODO Сделать отображение заведения если проходит в нем

                  Text(
                    '$promoCity, ${promo.street}, ${promo.house}',
                    style: Theme.of(context).textTheme.labelMedium,
                    softWrap: true,
                  ),

                  const SizedBox(height: 10.0),

                  Row(
                    children: [
                      if (promo.today == 'true') Text(
                        'Сегодня',
                        style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.green),
                      ),

                      if (promo.today == 'true') const SizedBox(width: 15,),

                      if (promo.placeId != '') Text(
                        'В заведении',
                        style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.green),
                      ),

                    ],
                  ),

                  const SizedBox(height: 10.0),

                  Text.rich(
                    TextSpan(
                      text: promo.desc,
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

                      if (promoType == DateTypeEnum.once)  Row(
                        children: [
                          IconAndTextWidget(
                            icon: FontAwesomeIcons.calendar,
                            text: getHumanDate(startDate, '-', needYear: false),
                            textSize: 'bodySmall',
                            padding: 10,
                          ),

                          const SizedBox(width: 20,),

                          IconAndTextWidget(
                            icon: FontAwesomeIcons.clock,
                            text: 'c $startTime до $endTime',
                            textSize: 'bodySmall',
                            padding: 10,
                          ),
                        ],
                      ),

                      if (promoType == DateTypeEnum.long) Row(
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

                      if (promoType == DateTypeEnum.regular) Row(
                        children: [
                          const Icon(
                            FontAwesomeIcons.clock,
                            size: 20,
                            color: AppColors.white,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Проводится по расписанию каждую неделю',
                                    style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                                    softWrap: true,
                                  ),

                                  if(
                                  regularStartTimes[currentWeekDayNumber-1] != 'Не выбрано'
                                      && regularFinishTimes[currentWeekDayNumber-1] != 'Не выбрано'
                                  ) Text(
                                    '${getHumanWeekday(currentWeekDayNumber-1, false)}: c ${regularStartTimes[currentWeekDayNumber-1]} до ${regularFinishTimes[currentWeekDayNumber-1]}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                    softWrap: true,
                                  ),

                                  if(
                                  regularStartTimes[currentWeekDayNumber-1] == 'Не выбрано'
                                      || regularFinishTimes[currentWeekDayNumber-1] == 'Не выбрано'
                                  ) Text(
                                    'Сегодня не проводится. Смотри расписание на другие дни',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.attentionRed),
                                    softWrap: true,
                                  ),

                                ],
                              )
                          )
                        ],
                      ),

                      if (promoType == DateTypeEnum.irregular) Row(
                        children: [
                          const Icon(
                            FontAwesomeIcons.clock,
                            size: 20,
                            color: AppColors.white,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Проводится по расписанию в разные дни',
                                    style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                                    softWrap: true,
                                  ),

                                  if (irregularTodayIndexes.isNotEmpty) SizedBox(height: 5,),

                                  if (irregularTodayIndexes.isEmpty) Text(
                                    'Сегодня акция не проводится. Смотри другие даты в полном расписании в карточке',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.attentionRed),
                                    softWrap: true,
                                  ),

                                  if (irregularTodayIndexes.isNotEmpty) Text(
                                    'Расписание на сегодня:',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    softWrap: true,
                                  ),

                                  if (irregularTodayIndexes.isNotEmpty) Column(
                                    children: List.generate(irregularTodayIndexes.length, (indexInIndexesList) {
                                      return Column( // сюда можно вставить шаблон элемента
                                          children: [

                                            Text(
                                              'c ${chosenIrregularStartTime[irregularTodayIndexes[indexInIndexesList]]} до ${chosenIrregularEndTime[irregularTodayIndexes[indexInIndexesList]]}',
                                              style: Theme.of(context).textTheme.bodySmall,
                                              softWrap: true,
                                            ),

                                            //Text('Время$indexInIndexesList - ${chosenIrregularStartTime[indexInIndexesList]}--${chosenIrregularEndTime[indexInIndexesList]}'),
                                          ]
                                      );
                                    }
                                    ),
                                  ),

                                ],
                              )
                          )
                        ],
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