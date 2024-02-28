import 'package:dvij_flutter/cities/city_class.dart';
import 'package:dvij_flutter/classes/priceTypeOptions.dart';
import 'package:dvij_flutter/dates/irregular_date_class.dart';
import 'package:dvij_flutter/dates/long_date_class.dart';
import 'package:dvij_flutter/dates/once_date_class.dart';
import 'package:dvij_flutter/dates/regular_date_class.dart';
import 'package:dvij_flutter/dates/time_mixin.dart';
import 'package:dvij_flutter/events/event_class.dart';
import 'package:dvij_flutter/dates/date_type_enum.dart';
import 'package:dvij_flutter/promos/promo_class.dart';
import 'package:dvij_flutter/widgets_global/text_widgets/for_cards_small_widget_with_icon_and_text.dart';
import 'package:dvij_flutter/widgets_global/text_widgets/icon_and_text_widget.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../dates/date_mixin.dart';
import '../../places/place_class.dart';
import '../text_widgets/now_is_work_widget.dart';
import '../text_widgets/text_size_enum.dart';

class CardWidgetForEventAndPromo extends StatelessWidget {
  final EventCustom? event;
  final PromoCustom? promo;
  final Place? place;
  final Function() onFavoriteIconPressed; // Добавьте функцию обратного вызова
  final Function() onTap; // Добавьте функцию обратного вызова
  final double? height;

  const CardWidgetForEventAndPromo(
      {
        super.key,
        this.event,
        this.promo,
        this.place,
        required this.onFavoriteIconPressed,
        required this.onTap,
        this.height
      }
      );

  @override
  Widget build(BuildContext context) {

    int currentWeekDayNumber = DateTime.now().weekday;
    String categoryName = '';
    DateTypeEnum dateType = DateTypeEnum.once;
    String imageUrl = '';
    int favCount = 0;
    String headline = '';
    bool inFav = false;
    bool today = false;

    City city = City.emptyCity;
    String street = '';
    String house = '';
    OnceDate onceDate = OnceDate();
    LongDate longDate = LongDate();
    RegularDate regularDate = RegularDate();
    IrregularDate irregularDate = IrregularDate();

    if (event != null) {
      city = event!.city;
      street = event!.street;
      house = event!.house;
      onceDate = event!.onceDay;
      longDate = event!.longDays;
      regularDate = event!.regularDays;

      today = event!.today;
      inFav = event!.inFav;
      headline = event!.headline;
      favCount = event!.addedToFavouritesCount;
      imageUrl = event!.imageUrl;
      dateType = event!.dateType;
      categoryName = event!.category.name;
      irregularDate = event!.irregularDays;
    } else if (promo != null) {
      city = promo!.city;
      street = promo!.street;
      house = promo!.house;
      onceDate = promo!.onceDay;
      longDate = promo!.longDays;
      regularDate = promo!.regularDays;

      today = promo!.today;
      inFav = promo!.inFav;
      headline = promo!.headline;
      favCount = promo!.addedToFavouritesCount;
      imageUrl = promo!.imageUrl;
      dateType = promo!.dateType;
      categoryName = promo!.category.name;
      irregularDate = promo!.irregularDays;
    } else {
      city = place!.city;
      street = place!.street;
      house = place!.house;
      regularDate = place!.openingHours;

      today = place!.nowIsOpen!;
      inFav = place!.inFav!;
      headline = place!.name;
      favCount = place!.addedToFavouritesCount!;
      imageUrl = place!.imageUrl;
      dateType = DateTypeEnum.regular;
      categoryName = place!.category.name;
    }

    List<int> irregularTodayIndexes = irregularDate.getIrregularTodayIndexes();

    return Padding(
      padding: const EdgeInsets.only(right: 5, bottom: 10, top: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          margin: const EdgeInsets.only(left: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // настройте необходимый радиус скругления углов
          ),
          child: Container(
            height: height ?? 400,
            width: 330,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), // настройте радиус скругления углов для контейнера
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // Полупрозрачный фон
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4), // Начальный цвет (черный с прозрачностью)
                        Colors.black.withOpacity(0.9), // Начальный цвет (черный с прозрачностью)
                      ],
                    ), // Здесь можно настроить уровень прозрачности и цвет фона
                    borderRadius: BorderRadius.circular(15), // настройте радиус скругления углов для фона
                  ),
                ),
                Positioned(
                  top: 10.0,
                  right: 10.0,
                  child: IconAndTextInTransparentSurfaceWidget(
                    icon: Icons.bookmark,
                    text: '$favCount',
                    iconColor: inFav ? AppColors.brandColor : AppColors.white,
                    side: false,
                    backgroundColor: AppColors.greyBackground.withOpacity(0.8),
                    onPressed: onFavoriteIconPressed,
                  ),
                ),

                Positioned(
                  top: 10.0,
                  left: 10.0,
                  child: IconAndTextInTransparentSurfaceWidget(
                      text: categoryName,
                      iconColor: AppColors.white,
                      side: true,
                      backgroundColor: AppColors.greyBackground.withOpacity(0.8)
                  ),
                ),
                // Дочерний элемент
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      if (today || place != null) TextOnBoolResultWidget(
                        isTrue: today,
                        trueText: place != null ? 'Сейчас открыто' : 'Сегодня',
                        falseText: place != null ? 'Сейчас закрыто' : '123',
                        textSizeEnum: TextSizeEnum.bodySmall,
                      ),
                      if (today || place != null) const SizedBox(height: 5),

                      Text.rich(
                        TextSpan(
                          text: headline,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        maxLines: 2, // Установите желаемое количество строк
                        overflow: TextOverflow.ellipsis, // Определяет, что делать с текстом, который не помещается в виджет
                      ),

                      const SizedBox(height: 3,),
                      Text('${city.name}, $street $house', style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText), softWrap: true,),
                      const SizedBox(height: 15,),

                      if (dateType == DateTypeEnum.once && place == null)  Row(

                        children: [
                          IconAndTextWidget(
                            icon: FontAwesomeIcons.calendar,
                            text: DateMixin.getHumanDateFromDateTime(onceDate.startDate, needYear: false),
                            textSize: TextSizeEnum.labelSmall,
                            padding: 10,
                          ),

                          const SizedBox(width: 20,),

                          IconAndTextWidget(
                            icon: FontAwesomeIcons.clock,
                            text: TimeMixin.getTimeRange(onceDate.startDate, onceDate.endDate),
                            textSize: TextSizeEnum.labelSmall,
                            padding: 10,
                          ),
                        ],
                      ),
                      if (dateType == DateTypeEnum.long && place == null) Row(
                        children: [
                          IconAndTextWidget(
                            icon: FontAwesomeIcons.calendar,
                            text: '${DateMixin.getHumanDateFromDateTime(longDate.startStartDate, needYear: false)} - ${DateMixin.getHumanDateFromDateTime(longDate.endStartDate, needYear: false)}',
                            textSize: TextSizeEnum.labelSmall,
                            padding: 10,
                          ),

                          const SizedBox(width: 20,),

                          IconAndTextWidget(
                            icon: FontAwesomeIcons.clock,
                            text: TimeMixin.getTimeRange(longDate.startStartDate, longDate.endEndDate),
                            textSize: TextSizeEnum.labelSmall,
                            padding: 10,
                          ),
                        ],
                      ),
                      if (dateType == DateTypeEnum.regular) Row(
                        children: [
                          const Icon(
                            FontAwesomeIcons.clock,
                            size: 20,
                            color: AppColors.white,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if(
                                  regularDate.getDayFromIndex(currentWeekDayNumber-1).startTime.toString() != 'Не выбрано'
                                      && regularDate.getDayFromIndex(currentWeekDayNumber-1).endTime.toString() != 'Не выбрано'
                                  ) Text(
                                    '${DateMixin.getHumanWeekday(currentWeekDayNumber, false)}: '
                                        'c ${regularDate.getDayFromIndex(currentWeekDayNumber-1).startTime.toString()} '
                                        'до ${regularDate.getDayFromIndex(currentWeekDayNumber-1).endTime.toString()}',
                                    style: Theme.of(context).textTheme.labelSmall,
                                    softWrap: true,
                                  ),

                                  if(
                                  regularDate.getDayFromIndex(currentWeekDayNumber-1).startTime.toString() == 'Не выбрано'
                                      && regularDate.getDayFromIndex(currentWeekDayNumber-1).endTime.toString() == 'Не выбрано'
                                  ) Text(
                                    'Сегодня не проводится. Смотри расписание на другие дни',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.attentionRed),
                                    softWrap: true,
                                  ),

                                ],
                              )
                          )
                        ],
                      ),

                      if (dateType == DateTypeEnum.irregular && place == null) Row(
                        children: [
                          const Icon(
                            FontAwesomeIcons.clock,
                            size: 20,
                            color: AppColors.white,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /*Text(
                                    'Проводится по расписанию в разные дни',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.greyText),
                                    softWrap: true,
                                  ),*/

                                  if (irregularTodayIndexes.isNotEmpty) const SizedBox(height: 5,),

                                  if (irregularTodayIndexes.isEmpty) Text(
                                    'Сегодня мероприятие не проводится. Смотри другие даты в полном расписании в карточке',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.attentionRed),
                                    softWrap: true,
                                  ),

                                  if (irregularTodayIndexes.isNotEmpty) Text(
                                    'Расписание на сегодня регулар:',
                                    style: Theme.of(context).textTheme.labelSmall,
                                    softWrap: true,
                                  ),

                                  if (irregularTodayIndexes.isNotEmpty) Column(
                                    children: List.generate(irregularTodayIndexes.length, (indexInIndexesList) {
                                      int indexInIrregularDate = irregularTodayIndexes[indexInIndexesList];
                                      return Column( // сюда можно вставить шаблон элемента
                                          children: [

                                            Text(
                                              TimeMixin.getTimeRange(
                                                  irregularDate.dates[indexInIrregularDate].startDate,
                                                  irregularDate.dates[indexInIrregularDate].endDate
                                              ),
                                              style: Theme.of(context).textTheme.labelSmall,
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
                      if (event != null) const SizedBox(height: 15),
                      if (event != null)IconAndTextWidget(
                        icon: FontAwesomeIcons.circleDollarToSlot,
                        text: PriceTypeEnumClass.getFormattedPriceString(event!.priceType, event!.price),
                        textSize: TextSizeEnum.labelSmall,
                        padding: 10,
                      ),
                      if (place != null) const SizedBox(height: 20),
                      if (place != null) Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconAndTextWidget(icon: FontAwesomeIcons.champagneGlasses, text: 'Мероприятий: ${place!.eventsCount}', textSize: TextSizeEnum.labelMedium, padding: 15, iconSize: 16,),
                          const SizedBox(width: 30,),
                          IconAndTextWidget(icon: FontAwesomeIcons.fire, text: 'Акций: ${place!.promoCount}', textSize: TextSizeEnum.labelMedium, padding: 10, iconSize: 16,),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}