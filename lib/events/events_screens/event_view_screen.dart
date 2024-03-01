import 'package:dvij_flutter/events/event_class.dart';
import 'package:dvij_flutter/events/events_list_manager.dart';
import 'package:dvij_flutter/widgets_global/schedule_widgets/schedule_widget.dart';
import 'package:dvij_flutter/widgets_global/text_widgets/headline_and_desc.dart';
import 'package:dvij_flutter/widgets_global/social_widgets/social_buttons_widget.dart';
import 'package:dvij_flutter/elements/user_element_widget.dart';
import 'package:dvij_flutter/places/place_list_manager.dart';
import 'package:dvij_flutter/users/place_user_class.dart';
import 'package:dvij_flutter/users/place_users_roles.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../places/places_elements/place_widget_in_view_screen_in_event_and_promo.dart';
import '../../places/places_screen/place_view_screen.dart';
import '../../places/place_class.dart';
import '../../classes/priceTypeOptions.dart';
import '../../classes/user_class.dart';
import '../../elements/exit_dialog/exit_dialog.dart';
import '../../widgets_global/images/image_for_view_screen.dart';
import '../../widgets_global/text_widgets/expandable_text.dart';
import '../../elements/loading_screen.dart';
import '../../elements/snack_bar.dart';
import 'create_or_edit_event_screen.dart';

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

    // Подгружаем данные заведения
    if (EventListsManager.currentFeedEventsList.eventsList.isNotEmpty){
      event = event.getEntityFromFeedList(widget.eventId);
    } else {
      event = await event.getEntityByIdFromDb(widget.eventId);
    }

    price = PriceTypeEnumClass.getFormattedPriceString(event.priceType, event.price);

    if (event.placeId != '') {

      if (PlaceListManager.currentFeedPlacesList.placeList.isNotEmpty){
        place = place.getEntityFromFeedList(event.placeId);
      } else {
        place = await place.getEntityByIdFromDb(event.placeId);

      }
    }

    // Заполняем текущего пользователя в PlaceUser данными из профиля
    if (UserCustom.currentUser != null){
      currentPlaceUser = currentPlaceUser.generatePlaceUserFromUserCustom(UserCustom.currentUser!);
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

    inFav = event.inFav;
    favCounter = event.addedToFavouritesCount;

    // ---- Убираем экран загрузки -----
    setState(() {
      loading = false;
    });
  }

  // ---- Функция перехода в профиль ----
  void navigateToEvents() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/Events',
          (route) => false,
    );
  }

  void _showSnackBar(String text, Color color, int time){
    showSnackBar(context, text, color, time);
  }

  Future<void> deleteEvent() async {

    bool? confirmed = await exitDialog(context, "Ты правда хочешь удалить мероприятие? Ты не сможешь восстановить данные" , 'Да', 'Нет', 'Удаление мероприятия');

    if (confirmed != null && confirmed){
      setState(() {
        deleting = true;
      });

      String delete = await event.deleteFromDb();

      if (delete == 'success'){

        event.deleteEntityFromCurrentEntityLists();

        _showSnackBar('Мероприятие успешно удалено', Colors.green, 2);
        navigateToEvents();

        setState(() {
          deleting = false;
        });
      } else {
        _showSnackBar('Мероприятие не было удалено по ошибке: $delete', AppColors.attentionRed, 2);
        setState(() {
          deleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text(event.headline != '' ? event.headline : 'Загрузка...'),
          leading: IconButton(
            icon: const Icon(FontAwesomeIcons.chevronLeft, size: 18,),
            onPressed: () {
              // Возвращаем данные о состоянии избранного на экран ленты
              // На случай, если мы добавляли/убирали из избранного
              List<dynamic> result = [inFav, favCounter];
              Navigator.of(context).pop(result);
            },
          ),
          actions: [

            // ---- Кнопка редактирования ---

            if (currentPlaceUser.placeUserRole.controlLevel >= 90) IconButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateOrEditEventScreen(eventInfo: event,))
                  );
                },
                icon: const Icon(Icons.edit)
            ),

            // ---- Кнопка удаления ---

            if (currentPlaceUser.placeUserRole.controlLevel == 100) IconButton(
                onPressed: () async {
                  deleteEvent();
                },
                icon: const Icon(Icons.delete_forever, color: AppColors.attentionRed,)
            ),

          ],
        ),
        body: Stack (
          children: [
            // ---- Экран загрузки ----
            if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка данных',)
            else if (deleting) const LoadingScreen(loadingText: 'Подожди, удаляем мероприятие',)
            else if (!loading && !deleting) CustomScrollView(
                slivers: <Widget> [
                  SliverList(delegate: SliverChildListDelegate(
                      [
                        ImageForViewScreen(
                            imagePath: event.imageUrl,
                            favCounter: favCounter,
                            inFav: inFav,
                            onTap: () async {
                              addOrDeleteFromFav();
                            },
                            categoryName: event.category.name,
                            headline: event.headline,
                            desc: place.id != '' ? '${place.name}, ${place.city.name}, ${place.street}, ${place.house}' :  '${event.city.name}, ${event.street}, ${event.house}',
                            openOrToday: event.today,
                            trueText: 'Сегодня',
                            falseText: ''
                        ),

                        // ВИДЖЕТЫ ПОД КАРТИНКОЙ

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              if (event.desc != '') ExpandableText(text: event.desc),

                              const SizedBox(height: 20.0),

                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.greyOnBackground,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(event.priceType == PriceTypeOption.free ? 'Подтвердить участие' : 'Заказать билеты', style: Theme.of(context).textTheme.titleMedium,),
                                          Text('По контактам ниже вы можете связаться с организатором', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.greyText),),
                                          const SizedBox(height: 15.0),
                                          HeadlineAndDesc(headline: price, description: 'Стоимость билетов'),

                                        ],
                                      ),
                                    ),

                                    SocialButtonsWidget(telegramUsername: event.telegram, instagramUsername: event.instagram, whatsappUsername: event.whatsapp, phoneNumber: event.phone,),
                                    const SizedBox(height: 20.0),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16.0),

                              // ВИДЖЕТ РАСПИСАНИЯ
                              ScheduleWidget(event: event),

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
                                    child: Padding (
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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

                                          const SizedBox(height: 20,),

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
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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

                            ],
                          ),
                        )



                      ]
                    )
                  )
                ],
              )
          ],
        )
    );
  }

  Future<void> addOrDeleteFromFav() async {
    if (UserCustom.currentUser?.uid == '' || UserCustom.currentUser?.uid == null)
    {
      _showSnackBar('Чтобы добавлять в избранное, нужно зарегистрироваться!', AppColors.attentionRed, 2);
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
          });

          _showSnackBar('Удалено из избранных', AppColors.attentionRed, 1);

        } else {
          _showSnackBar(resDel, AppColors.attentionRed, 1);
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
          });

          _showSnackBar('Добавлено в избранные', Colors.green, 1);

        } else {
          _showSnackBar(res, AppColors.attentionRed, 1);
        }
      }
    }
  }
}