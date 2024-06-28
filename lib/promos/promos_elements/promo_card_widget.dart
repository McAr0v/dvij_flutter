import 'package:dvij_flutter/dates/time_mixin.dart';
import 'package:dvij_flutter/dates/date_type_enum.dart';
import 'package:dvij_flutter/widgets_global/text_widgets/for_cards_small_widget_with_icon_and_text.dart';
import 'package:dvij_flutter/widgets_global/text_widgets/icon_and_text_widget.dart';
import 'package:dvij_flutter/promos/promo_class.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../dates/date_mixin.dart';
import '../../widgets_global/text_widgets/text_size_enum.dart';

class PromoCardWidget extends StatelessWidget {
  final PromoCustom promo;
  final Function()? onFavoriteIconPressed; // Добавьте функцию обратного вызова
  final Function()? onTap; // Добавьте функцию обратного вызова

  const PromoCardWidget({super.key, required this.promo, this.onFavoriteIconPressed, required this.onTap});

  @override
  Widget build(BuildContext context) {

    DateTime timeNow = DateTime.now();
    int currentWeekDayNumber = timeNow.weekday;

    List<int> irregularTodayIndexes = promo.irregularDays.getIrregularTodayIndexes();

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
                  child: IconAndTextInTransparentSurfaceWidget(
                    icon: Icons.bookmark,
                    text: '${promo.favUsersIds}',
                    iconColor: promo.inFav! ? AppColors.brandColor : AppColors.white,
                    side: false,
                    backgroundColor: AppColors.greyBackground.withOpacity(0.8),
                    onPressed: onFavoriteIconPressed,
                  ),
                ),

                Positioned(
                  top: 10.0,
                  left: 10.0,
                  child: IconAndTextInTransparentSurfaceWidget(
                    //icon: Icons.visibility,
                      text: promo.category.name,
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
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
                    '${promo.city.name}, ${promo.street}, ${promo.house}',
                    style: Theme.of(context).textTheme.labelMedium,
                    softWrap: true,
                  ),

                  const SizedBox(height: 10.0),

                  Row(
                    children: [
                      if (promo.today!) Text(
                        'Сегодня',
                        style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.green),
                      ),

                      if (promo.today!) const SizedBox(width: 15,),

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

                  const SizedBox(height: 20.0),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                      if (promo.dateType == DateTypeEnum.once)  Row(
                        children: [
                          IconAndTextWidget(
                            icon: FontAwesomeIcons.calendar,
                            text: DateMixin.getHumanDateFromDateTime(promo.onceDay.startDate, needYear: false),
                            textSize: TextSizeEnum.bodySmall,
                            padding: 10,
                          ),

                          const SizedBox(width: 20,),

                          IconAndTextWidget(
                            icon: FontAwesomeIcons.clock,
                            text: TimeMixin.getTimeRange(promo.onceDay.startDate, promo.onceDay.endDate),
                            textSize: TextSizeEnum.bodySmall,
                            padding: 10,
                          ),
                        ],
                      ),

                      if (promo.dateType == DateTypeEnum.long) Row(
                        children: [
                          IconAndTextWidget(
                            icon: FontAwesomeIcons.calendar,
                            text: '${DateMixin.getHumanDateFromDateTime(promo.longDays.startStartDate, needYear: false)} - ${DateMixin.getHumanDateFromDateTime(promo.longDays.endStartDate, needYear: false)}',
                            textSize: TextSizeEnum.labelMedium,
                            padding: 10,
                          ),

                          const SizedBox(width: 20,),

                          IconAndTextWidget(
                            icon: FontAwesomeIcons.clock,
                            text: TimeMixin.getTimeRange(promo.longDays.startStartDate, promo.longDays.endEndDate),
                            textSize: TextSizeEnum.labelMedium,
                            padding: 10,
                          ),
                        ],
                      ),

                      if (promo.dateType == DateTypeEnum.regular) Row(
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
                                  Text(
                                    'Проводится по расписанию каждую неделю',
                                    style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                                    softWrap: true,
                                  ),

                                  if(
                                  promo.regularDays.getDayFromIndex(currentWeekDayNumber-1).startTime.toString() != 'Не выбрано'
                                      && promo.regularDays.getDayFromIndex(currentWeekDayNumber-1).endTime.toString() != 'Не выбрано'
                                  ) Text(
                                    '${DateMixin.getHumanWeekday(currentWeekDayNumber, false)}: '
                                        'c ${promo.regularDays.getDayFromIndex(currentWeekDayNumber-1).startTime.toString()} '
                                        'до ${promo.regularDays.getDayFromIndex(currentWeekDayNumber-1).endTime.toString()}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                    softWrap: true,
                                  ),

                                  if(
                                  promo.regularDays.getDayFromIndex(currentWeekDayNumber-1).startTime.toString() == 'Не выбрано'
                                      && promo.regularDays.getDayFromIndex(currentWeekDayNumber-1).endTime.toString() == 'Не выбрано'
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

                      if (promo.dateType == DateTypeEnum.irregular) Row(
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
                                  Text(
                                    'Проводится по расписанию в разные дни',
                                    style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                                    softWrap: true,
                                  ),

                                  if (irregularTodayIndexes.isNotEmpty) const SizedBox(height: 5,),

                                  if (irregularTodayIndexes.isEmpty) Text(
                                    'Сегодня мероприятие не проводится. Смотри другие даты в полном расписании в карточке',
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
                                              TimeMixin.getTimeRange(
                                                  promo.irregularDays.dates[indexInIndexesList].startDate,
                                                  promo.irregularDays.dates[indexInIndexesList].endDate
                                              ),
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

                  const SizedBox(height: 10,),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}