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

class CardWidgetForEventPromoPlaces extends StatefulWidget {
  final EventCustom? event;
  final PromoCustom? promo;
  final Place? place;
  final Function() onFavoriteIconPressed; // Добавьте функцию обратного вызова
  final Function() onTap; // Добавьте функцию обратного вызова
  final double? height;
  final double? width;

  const CardWidgetForEventPromoPlaces(
      {
        super.key,
        this.event,
        this.promo,
        this.place,
        required this.onFavoriteIconPressed,
        required this.onTap,
        this.height,
        this.width,
      }
      );
  @override
  CardWidgetForEventPromoPlacesState createState() => CardWidgetForEventPromoPlacesState();
}

class CardWidgetForEventPromoPlacesState extends State<CardWidgetForEventPromoPlaces> {

  int currentWeekDayNumber = DateTime.now().weekday;
  String categoryName = '';
  DateTypeEnum dateType = DateTypeEnum.once;
  String imageUrl = '';
  int favCount = 0;
  String headline = '';
  bool inFav = false;
  bool today = false;

  City city = City.empty();
  String street = '';
  String house = '';
  OnceDate onceDate = OnceDate();
  LongDate longDate = LongDate();
  RegularDate regularDate = RegularDate();
  IrregularDate irregularDate = IrregularDate();

  bool _isLoading = false;

  void _handlePressed() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onFavoriteIconPressed();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.event != null) {
      fillVariables(widget.event);
    } else if (widget.promo != null) {
      fillVariables(widget.promo);
    } else {
      fillVariables(widget.place);
    }

    List<int> irregularTodayIndexes = irregularDate.getIrregularTodayIndexes();

    return Padding(
      padding: const EdgeInsets.only(right: 5, bottom: 10, top: 10),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Card(
          margin: const EdgeInsets.only(left: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // настройте необходимый радиус скругления углов
          ),
          child: Container(
            height: widget.height ?? 400,
            width: widget.width ?? 330,
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
                if (!_isLoading) Positioned(
                  top: 10.0,
                  right: 10.0,
                  child: IconAndTextInTransparentSurfaceWidget(
                    icon: Icons.bookmark,
                    text: '$favCount',
                    iconColor: inFav ? AppColors.brandColor : AppColors.white,
                    side: false,
                    backgroundColor: AppColors.greyBackground.withOpacity(0.8),
                    onPressed: _handlePressed,
                  ),
                ),

                if (_isLoading) Positioned(
                  top: 10.0,
                  right: 10.0,
                  child: IconAndTextInTransparentSurfaceWidget(
                    icon: FontAwesomeIcons.circle,
                    text: 'в процессе...',
                    iconColor: AppColors.brandColor,
                    side: false,
                    backgroundColor: AppColors.greyBackground.withOpacity(0.8),
                    onPressed: (){},
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

                      if (today || widget.place != null) TextOnBoolResultWidget(
                        isTrue: today,
                        trueText: widget.place != null ? 'Сейчас открыто' : 'Сегодня',
                        falseText: widget.place != null ? 'Сейчас закрыто' : '123',
                        textSizeEnum: TextSizeEnum.bodySmall,
                      ),
                      if (today || widget.place != null) const SizedBox(height: 5),

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

                      if (dateType == DateTypeEnum.once && widget.place == null)  Row(

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
                      if (dateType == DateTypeEnum.long && widget.place == null) Row(
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

                      if (dateType == DateTypeEnum.irregular && widget.place == null) Row(
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
                      if (widget.event != null) const SizedBox(height: 15),
                      if (widget.event != null)IconAndTextWidget(
                        icon: FontAwesomeIcons.circleDollarToSlot,
                        text: PriceTypeEnumClass.getFormattedPriceString(widget.event!.priceType, widget.event!.price),
                        textSize: TextSizeEnum.labelSmall,
                        padding: 10,
                      ),
                      if (widget.place != null) const SizedBox(height: 20),
                      if (widget.place != null) Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconAndTextWidget(icon: FontAwesomeIcons.champagneGlasses, text: 'Мероприятий: ${widget.place!.eventsList.length}', textSize: TextSizeEnum.labelMedium, padding: 15, iconSize: 16,),
                          const SizedBox(width: 30,),
                          IconAndTextWidget(icon: FontAwesomeIcons.fire, text: 'Акций: ${widget.place!.promosList.length}', textSize: TextSizeEnum.labelMedium, padding: 10, iconSize: 16,),
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

  void fillVariables(dynamic item) {
    if (item is EventCustom) {
      city = item.city;
      street = item.street;
      house = item.house;
      onceDate = item.onceDay;
      longDate = item.longDays;
      regularDate = item.regularDays;
      today = item.today;
      inFav = item.inFav;
      headline = item.headline;
      favCount = item.favUsersIds.length;
      imageUrl = item.imageUrl;
      dateType = item.dateType;
      categoryName = item.category.name;
      irregularDate = item.irregularDays;
    } else if (item is PromoCustom) {
      city = item.city;
      street = item.street;
      house = item.house;
      onceDate = item.onceDay;
      longDate = item.longDays;
      regularDate = item.regularDays;
      today = item.today;
      inFav = item.inFav;
      headline = item.headline;
      favCount = item.favUsersIds.length;
      imageUrl = item.imageUrl;
      dateType = item.dateType;
      categoryName = item.category.name;
      irregularDate = item.irregularDays;
    } else if (item is Place) {
      city = item.city;
      street = item.street;
      house = item.house;
      regularDate = item.openingHours;
      today = item.nowIsOpen!;
      inFav = item.inFav!;
      headline = item.name;
      favCount = item.favUsersIds.length;
      imageUrl = item.imageUrl;
      dateType = DateTypeEnum.regular;
      categoryName = item.category.name;
    }
  }

}