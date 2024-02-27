import 'package:dvij_flutter/classes/priceTypeOptions.dart';
import 'package:dvij_flutter/dates/time_mixin.dart';
import 'package:dvij_flutter/events/event_class.dart';
import 'package:dvij_flutter/dates/date_type_enum.dart';
import 'package:dvij_flutter/events/events_elements/today_widget.dart';
import 'package:dvij_flutter/widgets_global/text_widgets/for_cards_small_widget_with_icon_and_text.dart';
import 'package:dvij_flutter/widgets_global/text_widgets/icon_and_text_widget.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../dates/date_mixin.dart';
import '../../widgets_global/text_widgets/text_size_enum.dart';

class EventSmallCardWidget extends StatelessWidget {
  final EventCustom event;
  final Function()? onFavoriteIconPressed; // Добавьте функцию обратного вызова
  final Function()? onTap; // Добавьте функцию обратного вызова

  const EventSmallCardWidget({super.key, required this.event, this.onFavoriteIconPressed, required this.onTap});

  @override
  Widget build(BuildContext context) {

    DateTime timeNow = DateTime.now();
    int currentWeekDayNumber = timeNow.weekday;

    List<int> irregularTodayIndexes = event.irregularDays.getIrregularTodayIndexes();

    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          margin: EdgeInsets.only(left: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // настройте необходимый радиус скругления углов
          ),
          child: Container(
            height: 200,
            width: 330,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), // настройте радиус скругления углов для контейнера
              image: DecorationImage(
                image: NetworkImage(event.imageUrl),
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
                        //Colors.transparent, // Здесь можете использовать любой другой цвет или полную прозрачность
                        //Colors.black.withOpacity(0.6), // Начальный цвет (черный с прозрачностью)
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
                    text: '${event.addedToFavouritesCount}',
                    iconColor: event.inFav ? AppColors.brandColor : AppColors.white,
                    side: false,
                    backgroundColor: AppColors.greyBackground.withOpacity(0.8),
                    onPressed: onFavoriteIconPressed,
                  ),
                ),

                Positioned(
                  top: 10.0,
                  left: 10.0,
                  child: IconAndTextInTransparentSurfaceWidget(
                      //icon: FontAwesomeIcons.hashtag,
                      text: event.category.name,
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

                      if (event.today) TodayWidget(isTrue: event.today),
                      if (event.today) SizedBox(height: 3),

                      Text.rich(
                        TextSpan(
                          text: event.headline,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        maxLines: 2, // Установите желаемое количество строк
                        overflow: TextOverflow.ellipsis, // Определяет, что делать с текстом, который не помещается в виджет
                      ),

                      SizedBox(height: 3,),
                      Text('${event.city.name}, ${event.street} ${event.house}', style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText), softWrap: true,),
                      SizedBox(height: 15,),

                      if (event.dateType == DateTypeEnum.once)  Row(

                        children: [
                          IconAndTextWidget(
                            icon: FontAwesomeIcons.calendar,
                            text: DateMixin.getHumanDateFromDateTime(event.onceDay.startDate, needYear: false),
                            textSize: TextSizeEnum.labelSmall,
                            padding: 10,
                          ),

                          const SizedBox(width: 20,),

                          IconAndTextWidget(
                            icon: FontAwesomeIcons.clock,
                            text: TimeMixin.getTimeRange(event.onceDay.startDate, event.onceDay.endDate),
                            textSize: TextSizeEnum.labelSmall,
                            padding: 10,
                          ),
                        ],
                      ),
                      if (event.dateType == DateTypeEnum.long) Row(
                        children: [
                          IconAndTextWidget(
                            icon: FontAwesomeIcons.calendar,
                            text: '${DateMixin.getHumanDateFromDateTime(event.longDays.startStartDate, needYear: false)} - ${DateMixin.getHumanDateFromDateTime(event.longDays.endStartDate, needYear: false)}',
                            textSize: TextSizeEnum.labelSmall,
                            padding: 10,
                          ),

                          const SizedBox(width: 20,),

                          IconAndTextWidget(
                            icon: FontAwesomeIcons.clock,
                            text: TimeMixin.getTimeRange(event.longDays.startStartDate, event.longDays.endEndDate),
                            textSize: TextSizeEnum.labelSmall,
                            padding: 10,
                          ),
                        ],
                      ),
                      if (event.dateType == DateTypeEnum.regular) Row(
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
                                    'Проводится по расписанию каждую неделю',
                                    style: Theme.of(context).textTheme.labelSmall,
                                    softWrap: true,
                                  ),*/

                                  if(
                                  event.regularDays.getDayFromIndex(currentWeekDayNumber-1).startTime.toString() != 'Не выбрано'
                                      && event.regularDays.getDayFromIndex(currentWeekDayNumber-1).endTime.toString() != 'Не выбрано'
                                  ) Text(
                                    '${DateMixin.getHumanWeekday(currentWeekDayNumber, false)}: '
                                        'c ${event.regularDays.getDayFromIndex(currentWeekDayNumber-1).startTime.toString()} '
                                        'до ${event.regularDays.getDayFromIndex(currentWeekDayNumber-1).endTime.toString()}',
                                    style: Theme.of(context).textTheme.labelSmall,
                                    softWrap: true,
                                  ),

                                  if(
                                  event.regularDays.getDayFromIndex(currentWeekDayNumber-1).startTime.toString() == 'Не выбрано'
                                      && event.regularDays.getDayFromIndex(currentWeekDayNumber-1).endTime.toString() == 'Не выбрано'
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

                      if (event.dateType == DateTypeEnum.irregular) Row(
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
                                    'Расписание на сегодня:',
                                    style: Theme.of(context).textTheme.labelSmall,
                                    softWrap: true,
                                  ),

                                  if (irregularTodayIndexes.isNotEmpty) Column(
                                    children: List.generate(irregularTodayIndexes.length, (indexInIndexesList) {
                                      return Column( // сюда можно вставить шаблон элемента
                                          children: [

                                            Text(
                                              TimeMixin.getTimeRange(
                                                  event.irregularDays.dates[indexInIndexesList].startDate,
                                                  event.irregularDays.dates[indexInIndexesList].endDate
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
                      const SizedBox(height: 15),
                      IconAndTextWidget(
                        icon: FontAwesomeIcons.circleDollarToSlot,
                        text: PriceTypeEnumClass.getFormattedPriceString(event.priceType, event.price),
                        textSize: TextSizeEnum.labelSmall,
                        padding: 10,
                      ),
                      /*SizedBox(height: 15,),
                      Text.rich(
                        TextSpan(
                          text: event.desc,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        maxLines: 2, // Установите желаемое количество строк
                        overflow: TextOverflow.ellipsis, // Определяет, что делать с текстом, который не помещается в виджет
                      ),*/

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