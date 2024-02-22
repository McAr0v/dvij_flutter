import 'package:dvij_flutter/dates/date_mixin.dart';
import 'package:dvij_flutter/events/event_class.dart';
import 'package:dvij_flutter/elements/text_and_icons_widgets/headline_and_desc.dart';
import 'package:dvij_flutter/elements/shedule_elements/shedule_once_and_long_widget.dart';
import 'package:dvij_flutter/elements/social_elements/social_buttons_widget.dart';
import 'package:dvij_flutter/elements/user_element_widget.dart';
import 'package:dvij_flutter/places/place_list_manager.dart';
import 'package:dvij_flutter/users/place_user_class.dart';
import 'package:dvij_flutter/users/place_users_roles.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import '../../places/places_elements/place_widget_in_view_screen_in_event_and_promo.dart';
import '../../places/places_screen/place_view_screen.dart';
import '../../dates/date_type_enum.dart';
import '../../places/place_class.dart';
import '../../classes/priceTypeOptions.dart';
import '../../classes/user_class.dart';
import '../../elements/exit_dialog/exit_dialog.dart';
import '../../elements/text_and_icons_widgets/for_cards_small_widget_with_icon_and_text.dart';
import '../../elements/loading_screen.dart';
import '../../elements/shedule_elements/schedule_regular_and_irregular_widget.dart';
import '../../elements/snack_bar.dart';
import '../events_elements/today_widget.dart';
import 'create_or_edit_event_screen.dart';


// --- ЭКРАН ЗАЛОГИНЕВШЕГОСЯ ПОЛЬЗОВАТЕЛЯ -----

class EventViewScreen extends StatefulWidget {
  final String eventId;
  const EventViewScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  EventViewScreenState createState() => EventViewScreenState();
}

class EventViewScreenState extends State<EventViewScreen> {

  // ---- Инициализируем пустые переменные ----

  bool today = false;

  UserCustom creator = UserCustom.empty('', '');
  PlaceUserRole currentUserPlaceRole = PlaceUserRole();

  EventCustom event = EventCustom.emptyEvent;

  DateTime currentDate = DateTime.now();

  Place place = Place.emptyPlace;
  PlaceUser currentPlaceUser = PlaceUser();

  String price = '';
  int favCounter = 0;
  bool inFav = false;

  // --- Переключатель показа экрана загрузки -----

  bool loading = true;
  bool deleting = false;

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

      event = event.getEntityFromFeedList(widget.eventId);

      price = PriceTypeEnumClass.getFormattedPriceString(event.priceType, event.price);

      if (UserCustom.currentUser != null){
        currentPlaceUser = currentPlaceUser.generatePlaceUserFromUserCustom(UserCustom.currentUser!);
      }

      if (event.placeId != '') {

        if (PlaceListManager.currentFeedPlacesList.placeList.isNotEmpty){
          place = place.getEntityFromFeedList(event.placeId);
        } else {
          place = await place.getEntityByIdFromDb(event.placeId);
        }
      }

      // Выдаем права на редактирование мероприятия
      // Если наш пользователь создатель
      if (UserCustom.currentUser != null && UserCustom.currentUser!.uid == event.creatorId){

        // Отдаем права создателя
        currentUserPlaceRole = currentUserPlaceRole.getPlaceUserRole(PlaceUserRoleEnum.creator);
        currentPlaceUser.placeUserRole = currentUserPlaceRole;
        // Ставим нас как создателя
        creator = UserCustom.currentUser!;

      } else if (UserCustom.currentUser != null && UserCustom.currentUser!.uid != event.creatorId){

        // Если создатель не я
        // Читаем нашу роль
        currentUserPlaceRole = currentUserPlaceRole.searchPlaceUserRoleInAdminsList(place.admins!, currentPlaceUser);
        currentPlaceUser.placeUserRole = currentUserPlaceRole;
        // Грузим создателя из БД
        creator = await UserCustom.getUserById(event.creatorId);

      } else {
        creator = await UserCustom.getUserById(event.creatorId);
      }

      inFav = event.inFav!;
      favCounter = event.addedToFavouritesCount!;

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
                            iconColor: inFav ? AppColors.brandColor : AppColors.white,
                            side: false,
                            backgroundColor: AppColors.greyBackground.withOpacity(0.8),
                            onPressed: () async {

                              // TODO Сделать проверку на подтвержденный Email
                              if (UserCustom.currentUser?.uid == '' || UserCustom.currentUser?.uid == null)
                              {

                                showSnackBar(context, 'Чтобы добавлять в избранное, нужно зарегистрироваться!', AppColors.attentionRed, 2);

                              }

                              else {

                                if (inFav)
                                {

                                  String resDel = await event.deleteFromFav();

                                  if (resDel == 'success'){
                                    setState(() {
                                      inFav = false;
                                      favCounter --;
                                      event.inFav = inFav;
                                      event.addedToFavouritesCount = favCounter;
                                      event.updateCurrentListFavInformation();
                                      //EventCustom.updateCurrentEventListFavInformation(event.id, favCounter, inFav);
                                    });

                                    showSnackBar(context, 'Удалено из избранных', AppColors.attentionRed, 1);

                                  } else {

                                    showSnackBar(context, resDel, AppColors.attentionRed, 1);
                                  }



                                }
                                else {
                                  String res = await event.addToFav();

                                  if (res == 'success') {

                                    setState(() {
                                      inFav = true;
                                      favCounter ++;
                                      event.inFav = inFav;
                                      event.addedToFavouritesCount = favCounter;
                                      event.updateCurrentListFavInformation();
                                      //EventCustom.updateCurrentEventListFavInformation(event.id, favCounter, inFav);
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
                              text: event.category.name,
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
                                      '${place.name}, ${place.city.name}, ${place.street}, ${place.house}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    if (place.id == '') Text(
                                      '${event.city.name}, ${event.street}, ${event.house}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    )
                                  ],
                                )
                            ),

                            const SizedBox(width: 16.0),

                            // TODO - сделать скрытие кнопки редактирования места если нет доступа к редактированию
                            // --- Кнопка редактирования ----
                            if (currentUserPlaceRole.controlLevel >= 90) IconButton(
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
                        if (event.today!) const SizedBox(height: 5.0),

                        // ПЕРЕДЕЛАТЬ ПОД СЕГОДНЯ
                        if (event.today!) TodayWidget(isTrue: event.today!),

                        const SizedBox(height: 16.0),

                        Container(
                          margin: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            color: AppColors.greyOnBackground,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding (
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            child: HeadlineAndDesc(headline: price, description: 'Стоимость билетов'),
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
                                    Text(event.priceType == PriceTypeOption.free ? 'Подтвердить участие' : 'Заказать билеты', style: Theme.of(context).textTheme.titleMedium,),
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

                        if (event.dateType == DateTypeEnum.once) ScheduleOnceAndLongWidget(
                          dateHeadline: 'Дата проведения',
                          dateDesc: 'Мероприятие проводится один раз',
                          dateTypeEnum: event.dateType,
                          onceDate: event.onceDay
                        ),

                        if (event.dateType == DateTypeEnum.long) ScheduleOnceAndLongWidget(
                          dateHeadline: 'Расписание',
                          dateDesc: 'Мероприятие проводится каждый день в течении указанного периода',
                          dateTypeEnum: event.dateType,
                          longDates: event.longDays,
                        ),



                        if (event.dateType == DateTypeEnum.regular) ScheduleRegularAndIrregularWidget(
                            dateTypeEnum: event.dateType,
                            regularTimes: event.regularDays,
                          headline: 'Расписание',
                          desc: 'Мероприятие проводится каждую неделю в определенные дни',
                        ),

                        if (event.dateType == DateTypeEnum.irregular) ScheduleRegularAndIrregularWidget(
                          dateTypeEnum: event.dateType,
                          irregularDays: event.irregularDays,
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
                                        headline: '${event.city.name}, ${event.street} ${event.house} ',
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


                        if (event.createDate != DateTime(2100) && currentUserPlaceRole.controlLevel >= 90) const SizedBox(height: 30.0),

                        if (event.createDate != DateTime(2100) && currentUserPlaceRole.controlLevel >= 90) HeadlineAndDesc(headline: DateMixin.getHumanDateFromDateTime(event.createDate), description: 'Создано в движе', ),

                        const SizedBox(height: 30.0),

                        if (
                        currentUserPlaceRole.controlLevel >= 90
                        ) CustomButton(
                          buttonText: 'Удалить мероприятие',
                          onTapMethod: () async {
                            bool? confirmed = await exitDialog(context, "Ты правда хочешь удалить мероприятие? Ты не сможешь восстановить данные" , 'Да', 'Нет', 'Удаление мероприятия');

                            if (confirmed != null && confirmed){

                              setState(() {
                                deleting = true;
                              });

                              String delete = await event.deleteFromDb();

                              if (delete == 'success'){

                                event.deleteEntityFromCurrentEntityLists();
                                //EventCustom.deleteEventFromCurrentEventLists(widget.eventId);
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