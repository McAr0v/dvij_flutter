import 'package:dvij_flutter/classes/event_class.dart';
import 'package:dvij_flutter/elements/events_elements/today_widget.dart';
import 'package:dvij_flutter/elements/text_and_icons_widgets/headline_and_desc.dart';
import 'package:dvij_flutter/elements/places_elements/now_is_work_widget.dart';
import 'package:dvij_flutter/elements/places_elements/place_widget_in_view_screen_in_event_and_promo.dart';
import 'package:dvij_flutter/elements/places_elements/place_work_time_element.dart';
import 'package:dvij_flutter/elements/shedule_elements/shedule_once_and_long_widget.dart';
import 'package:dvij_flutter/elements/social_elements/social_buttons_widget.dart';
import 'package:dvij_flutter/elements/user_element_widget.dart';
import 'package:dvij_flutter/go_to_url/openUrlPage.dart';
import 'package:dvij_flutter/methods/date_functions.dart';
import 'package:dvij_flutter/methods/price_methods.dart';
import 'package:dvij_flutter/screens/events/create_or_edit_event_screen.dart';
import 'package:dvij_flutter/screens/places/create_or_edit_place_screen.dart';
import 'package:dvij_flutter/screens/places/place_view_screen.dart';
import 'package:dvij_flutter/screens/profile/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:dvij_flutter/elements/custom_snack_bar.dart';
import 'package:dvij_flutter/elements/pop_up_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../classes/city_class.dart';
import '../../classes/event_category_class.dart';
import '../../classes/event_type_enum.dart';
import '../../classes/gender_class.dart';
import '../../classes/place_category_class.dart';
import '../../classes/place_class.dart';
import '../../classes/place_role_class.dart';
import '../../classes/priceTypeOptions.dart';
import '../../classes/role_in_app.dart';
import '../../classes/user_class.dart';
import '../../elements/exit_dialog/exit_dialog.dart';
import '../../elements/text_and_icons_widgets/for_cards_small_widget_with_icon_and_text.dart';
import '../../elements/loading_screen.dart';
import '../../elements/places_elements/place_card_widget.dart';
import '../../elements/places_elements/place_managers_element_list_item.dart';
import '../../elements/shedule_elements/schedule_once_and_long_widget_two.dart';
import '../../elements/shedule_elements/schedule_regular_and_irregular_widget.dart';
import '../../elements/snack_bar.dart';
import '../../methods/days_functions.dart';
import '../place_admins_screens/place_manager_add_screen.dart';


// --- ЭКРАН ЗАЛОГИНЕВШЕГОСЯ ПОЛЬЗОВАТЕЛЯ -----

class EventViewScreen extends StatefulWidget {
  final String eventId;
  const EventViewScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  _EventViewScreenState createState() => _EventViewScreenState();
}

class _EventViewScreenState extends State<EventViewScreen> {

  // ---- Инициализируем пустые переменные ----

  //UserCustom userInfo = UserCustom.empty('', '');

  // -- Список админов заведения
  //List<UserCustom> placeAdminsList = [];

  bool today = false;

  UserCustom creator = UserCustom.empty('', '');
  PlaceRole currentUserPlaceRole = PlaceRole(name: '', id: '', desc: '', controlLevel: '');

  EventCustom event = EventCustom.empty();
  String city = '';
  String category = '';

  EventTypeEnum eventTypeEnum = EventTypeEnum.once;
  PriceTypeOption priceType = PriceTypeOption.free;

  DateTime currentDate = DateTime.now();

  Place place = Place.emptyPlace;

  String price = '';

  // --- Переключатель показа экрана загрузки -----

  bool loading = true;
  bool deleting = false;
  String inFav = 'false';
  int favCounter = 0;

  String onceDay = '';
  String onceDayStartTime = '';
  String onceDayFinishTime = '';

  String longStartDay = '';
  String longEndDay = '';
  String longDayStartTime = '';
  String longDayFinishTime = '';

  List<String> regularStartTimes = fillTimeListWithDefaultValues('Не выбрано', 7);
  List<String> regularFinishTimes = fillTimeListWithDefaultValues('Не выбрано', 7);

  List<String> tempIrregularDaysString = [];
  // Выбранные даты начала
  List<String> chosenIrregularStartTime = [];
  // Выбранные даты завершения
  List<String> chosenIrregularEndTime = [];

  // ---- Инициализация экрана -----
  @override
  void initState() {
    super.initState();
    // --- Получаем и устанавливаем данные ---
    fetchAndSetData();

  }

  // --- Функция получения и ввода данных ---

  Future<void> fetchAndSetData() async {
    try {

      event = await EventCustom.getEventById(widget.eventId);

      eventTypeEnum = EventCustom.getEventTypeEnum(event.eventType);

      if (eventTypeEnum == EventTypeEnum.once && event.onceDay != ''){
        onceDay = extractDateOrTimeFromJson(event.onceDay, 'date');
        onceDayStartTime = extractDateOrTimeFromJson(event.onceDay, 'startTime');
        onceDayFinishTime = extractDateOrTimeFromJson(event.onceDay, 'endTime');
      }

      if (eventTypeEnum == EventTypeEnum.long && event.longDays != '') {
        longStartDay = extractDateOrTimeFromJson(event.longDays, 'startDate');
        longEndDay = extractDateOrTimeFromJson(event.longDays, 'endDate');
        longDayStartTime = extractDateOrTimeFromJson(event.longDays, 'startTime');
        longDayFinishTime = extractDateOrTimeFromJson(event.longDays, 'endTime');
      }

      if (eventTypeEnum == EventTypeEnum.regular && event.regularDays != ''){

        _fillRegularList();
      }

      if (eventTypeEnum == EventTypeEnum.irregular && event.irregularDays != ''){

        // TODO Вынести эту функцию в отдельный класс. Она скопирована из CreateOrEditEventScreen
        // Парсим даты и время в списки
        parseInputString(event.irregularDays, tempIrregularDaysString, chosenIrregularStartTime, chosenIrregularEndTime);

      }

      priceType = EventCustom.getPriceTypeEnum(event.priceType);

      price = PriceMethods.getFormattedPriceString(event.priceType, event.price);

      if (event.placeId != '') {
        // placeAdminsList = await UserCustom.getPlaceAdminsUsers(event.placeId);

        // Считываем информацию о заведении
        place = await Place.getPlaceById(event.placeId);


      }



      // Выдаем права на редактирование мероприятия
      // Если наш пользователь создатель
    if (UserCustom.currentUser != null && UserCustom.currentUser!.uid == event.creatorId){

      // Отдаем права создателя
      currentUserPlaceRole = PlaceRole.getPlaceRoleFromListById('-NngrYovmKAw_cp0pYfJ');

    } else if (UserCustom.currentUser != null && UserCustom.currentUser!.uid != event.creatorId){
      if (event.placeId != '') {
        // Если не создатель, то пытаемся понять, может он админ заведения
        currentUserPlaceRole = await UserCustom.getPlaceRoleInUserById(place.id, UserCustom.currentUser!.uid);
      }

    }

    creator = await UserCustom.getUserById(event.creatorId);

      city = City.getCityName(event.city);
      category = EventCategory.getEventCategoryName(event.category);
      inFav = event.inFav!;
      favCounter = int.parse(event.addedToFavouritesCount!);

      // ---- Убираем экран загрузки -----
      setState(() {
        loading = false;
      });
    } catch (e) {
      // TODO Сделать обработку ошибок, если не получилось считать данные
    }
  }

  // ---- Функция перехода в профиль ----
  void navigateToEvents() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/Events',
          (route) => false,
    );
  }

  void _fillRegularList (){


    for (int i = 0; i<regularStartTimes.length; i++){

      regularStartTimes[i] = extractDateOrTimeFromJson(event.regularDays, 'startTime${i+1}');
      regularFinishTimes[i] = extractDateOrTimeFromJson(event.regularDays, 'endTime${i+1}');

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text(event.headline != '' ? event.headline : 'Загрузка...'),
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              List<dynamic> result = [inFav, favCounter];
              Navigator.of(context).pop(result); // Это закроет текущий экран и вернется на предыдущий
            },
          ),
        ),
        body: Stack (
          children: [
            // ---- Экран загрузки ----
            if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка данных',)
            else if (deleting) const LoadingScreen(loadingText: 'Подожди, удаляем мероприятие',)
            else ListView(

                children: [
                  if (event.imageUrl != '') // Проверяем, есть ли ссылка на аватар
                  // TODO - Сделать более проработанную проверку аватарки

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
                            text: '$favCounter',
                            iconColor: inFav == 'true' ? AppColors.brandColor : AppColors.white,
                            side: false,
                            backgroundColor: AppColors.greyBackground.withOpacity(0.8),
                            onPressed: () async {

                              // TODO Сделать проверку на подтвержденный Email
                              if (UserCustom.currentUser?.uid == '' || UserCustom.currentUser?.uid == null)
                              {

                                showSnackBar(context, 'Чтобы добавлять в избранное, нужно зарегистрироваться!', AppColors.attentionRed, 2);

                              }

                              else {

                                if (inFav == 'true')
                                {

                                  String resDel = await EventCustom.deleteEventFromFav(event.id);

                                  if (resDel == 'success'){
                                    setState(() {
                                      inFav = 'false';
                                      favCounter --;
                                      EventCustom.updateCurrentEventListFavInformation(event.id, favCounter.toString(), inFav);
                                    });

                                    showSnackBar(context, 'Удалено из избранных', AppColors.attentionRed, 1);

                                  } else {

                                    showSnackBar(context, resDel, AppColors.attentionRed, 1);
                                  }



                                }
                                else {
                                  String res = await EventCustom.addEventToFav(event.id);
                                  if (res == 'success') {

                                    setState(() {
                                      inFav = 'true';
                                      favCounter ++;
                                      EventCustom.updateCurrentEventListFavInformation(event.id, favCounter.toString(), inFav);
                                    });

                                    showSnackBar(context, 'Добавлено в избранные', Colors.green, 1);

                                  } else {

                                    showSnackBar(context, res, AppColors.attentionRed, 1);

                                  }

                                }

                              }

                            },
                          ),
                        ),

                        Positioned(
                          top: 10.0,
                          left: 10.0,
                          child: SmallWidgetForCardsWithIconAndText(
                            //icon: Icons.visibility,
                              text: category,
                              iconColor: AppColors.white,
                              side: true,
                              backgroundColor: AppColors.greyBackground.withOpacity(0.8)
                          ),
                        ),
                      ],
                    ),

                  // --- Контент под аватаркой -----

                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // TODO - Такая проверка не пойдет. Иначе пользователь никак не сможет перейти на экран редактирования

                        if (event.headline != '') Row(
                          children: [
                            Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.headline,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    if (place.id != '') Text(
                                      '${place.name}, ${City.getCityName(place.city)}, ${place.street}, ${place.house}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    if (place.id == '') Text(
                                      '$city, ${event.street}, ${event.house}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    )
                                  ],
                                )
                            ),

                            const SizedBox(width: 16.0),

                            // TODO - сделать скрытие кнопки редактирования места если нет доступа к редактированию
                            // --- Кнопка редактирования ----
                            if (currentUserPlaceRole.controlLevel != '' && int.parse(currentUserPlaceRole.controlLevel) >= 90) IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Theme.of(context).colorScheme.background,
                              ),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(AppColors.brandColor),
                              ),
                              onPressed: () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => CreateOrEditEventScreen(eventInfo: event))
                                );
                              },
                              // Действие при нажатии на кнопку редактирования
                            ),
                          ],
                        ),

                        // ---- Остальные данные пользователя ----

                        // TODO Проверить вывод времени в функции определения сегодня
                        if (event.today != 'false') const SizedBox(height: 5.0),

                        // ПЕРЕДЕЛАТЬ ПОД СЕГОДНЯ
                        if (event.today != 'false') TodayWidget(isTrue: bool.parse(event.today!)),

                        const SizedBox(height: 16.0),

                        Container(
                          margin: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            color: AppColors.greyOnBackground,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding (
                            child: HeadlineAndDesc(headline: price, description: 'Стоимость билетов'),
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          ),
                        ),

                        const SizedBox(height: 16.0),

                        Container(
                          decoration: BoxDecoration(
                            //color: backgroundColor,
                            color: AppColors.greyOnBackground,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //const SizedBox(height: 16.0),
                              Padding(
                                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //const SizedBox(height: 20,),
                                    Text(priceType == PriceTypeOption.free ? 'Подтвердить участие' : 'Заказать билеты', style: Theme.of(context).textTheme.titleMedium,),
                                    Text('По контактам ниже вы можете связаться с организатором', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.greyText),),


                                  ],
                                ),
                              ),

                              //const SizedBox(height: 16.0),

                              SocialButtonsWidget(telegramUsername: event.telegram, instagramUsername: event.instagram, whatsappUsername: event.whatsapp, phoneNumber: event.phone,),
                              const SizedBox(height: 20.0),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16.0),

                        if (event.desc != '') HeadlineAndDesc(headline: event.desc, description: 'Описание мероприятия'),

                        const SizedBox(height: 16.0),

                        if (eventTypeEnum == EventTypeEnum.once) ScheduleOnceAndLongWidget(
                          dateHeadline: 'Дата проведения',
                          dateDesc: 'Мероприятие проводится один раз',
                          eventTypeEnum: eventTypeEnum,
                          startTime: onceDayStartTime,
                          endTime: onceDayFinishTime,
                          onceDate: onceDay,
                        ),

                        if (eventTypeEnum == EventTypeEnum.long) ScheduleOnceAndLongWidget(
                          dateHeadline: 'Расписание',
                          dateDesc: 'Мероприятие проводится каждый день в течении указанного периода',
                          eventTypeEnum: eventTypeEnum,
                          startTime: longDayStartTime,
                          endTime: longDayFinishTime,
                          longStartDate: longStartDay,
                          longEndDate: longEndDay,
                        ),



                        if (eventTypeEnum == EventTypeEnum.regular) ScheduleRegularAndIrregularWidget(
                            eventTypeEnum: eventTypeEnum,
                            regularStartTimes: regularStartTimes,
                            regularFinishTimes: regularFinishTimes,
                          headline: 'Расписание',
                          desc: 'Мероприятие проводится каждую неделю в определенные дни',
                        ),

                        if (eventTypeEnum == EventTypeEnum.irregular) ScheduleRegularAndIrregularWidget(
                          eventTypeEnum: eventTypeEnum,
                          irregularDays: tempIrregularDaysString,
                          irregularStartTime: chosenIrregularStartTime,
                          irregularEndTime: chosenIrregularEndTime,
                          headline: 'Расписание',
                          desc: 'Мероприятие проводится в определенные дни',
                        ),

                        const SizedBox(height: 16.0),

                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              margin: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                color: AppColors.greyOnBackground,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              //surfaceTintColor: Colors.transparent,
                              //color: AppColors.greyOnBackground,
                              child: Padding (
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                child: Column (
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row (
                                      children: [
                                        Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Место проведения: ${place.name}',
                                                  style: Theme.of(context).textTheme.titleMedium,
                                                ),
                                                Text(
                                                  place.id != '' ? 'Ты можешь перейти в заведение и ознакомиться с ним подробнее' : 'Адрес, где будет проводится мероприятие',
                                                  style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                                                ),
                                              ],
                                            )
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 20,),

                                    if (event.street != '' && place.id == '') HeadlineAndDesc(
                                        headline: '${City.getCityNameInCitiesList(event.city).name}, ${event.street} ${event.house} ',
                                        description: 'Место проведения'
                                    ),

                                    if (place.id != '')PlaceWidgetInViewScreenInEventAndPromoScreen(
                                      // TODO Сделать обновление иконки избранного и счетчика при возврате из экрана просмотра заведения
                                      place: place,
                                      onTapMethod: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PlaceViewScreen(placeId: place.id),
                                          ),
                                        );
                                      },
                                    ),


                                  ],
                                ),
                              ),
                            ),


                          ],
                        ),

                        const SizedBox(height: 16.0),

                        Card(
                          margin: EdgeInsets.zero,
                          surfaceTintColor: Colors.transparent,
                          color: AppColors.greyOnBackground,
                          child: Padding (
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            child: Column (
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Создатель мероприятия',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),

                                Text(
                                  'Ты можешь написать создателю и задать вопросы',
                                  style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                                ),

                                const SizedBox(height: 16.0),

                                if (creator.uid != '') UserElementWidget(user: creator),

                              ],
                            ),
                          ),
                        ),


                        if (event.createDate != '' && int.parse(currentUserPlaceRole.controlLevel) >= 90) const SizedBox(height: 30.0),

                        if (event.createDate != '' && int.parse(currentUserPlaceRole.controlLevel) >= 90) HeadlineAndDesc(headline: event.createDate, description: 'Создано в движе', ),

                        const SizedBox(height: 30.0),

                        if (
                        currentUserPlaceRole.controlLevel != ''
                            && int.parse(currentUserPlaceRole.controlLevel) >= 90
                        ) CustomButton(
                          buttonText: 'Удалить мероприятие',
                          onTapMethod: () async {
                            bool? confirmed = await exitDialog(context, "Ты правда хочешь удалить мероприятие? Ты не сможешь восстановить данные" , 'Да', 'Нет', 'Удаление мероприятия');

                            if (confirmed != null && confirmed){

                              setState(() {
                                deleting = true;
                              });

                              String delete = await EventCustom.deleteEvent(widget.eventId, event.creatorId, event.placeId);

                              if (delete == 'success'){

                                EventCustom.deleteEventFromCurrentEventLists(widget.eventId);
                                //Place.deletePlaceFormCurrentPlaceLists(widget.eventId);

                                showSnackBar(context, 'Мероприятие успешно удалено', Colors.green, 2);
                                navigateToEvents();

                                setState(() {
                                  deleting = false;
                                });
                              } else {
                                showSnackBar(context, 'Мероприятие не было удалено по ошибке: $delete', AppColors.attentionRed, 2);
                                setState(() {
                                  deleting = false;
                                });
                              }

                            }

                          },
                          state: 'error',
                        )
                      ],
                    ),
                  ),
                ],
              )
          ],
        )
    );
  }
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