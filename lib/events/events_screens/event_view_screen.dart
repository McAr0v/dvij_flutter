import 'package:dvij_flutter/events/event_class.dart';
import 'package:dvij_flutter/events/events_list_manager.dart';
import 'package:dvij_flutter/widgets_global/images/image_in_view_screen_widget.dart';
import 'package:dvij_flutter/widgets_global/place_or_location_widgets/place_or_location_widget.dart';
import 'package:dvij_flutter/widgets_global/schedule_widgets/schedule_widget.dart';
import 'package:dvij_flutter/widgets_global/social_widgets/callback_widget.dart';
import 'package:dvij_flutter/places/place_list_manager.dart';
import 'package:dvij_flutter/users/place_user_class.dart';
import 'package:dvij_flutter/users/place_users_roles.dart';
import 'package:dvij_flutter/widgets_global/users_widgets/creator_widget.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../places/place_class.dart';
import '../../classes/priceTypeOptions.dart';
import '../../current_user/user_class.dart';
import '../../elements/exit_dialog/exit_dialog.dart';
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

  UserCustom creator = UserCustom.empty();
  PlaceUserRole currentUserPlaceRole = PlaceUserRole();

  EventCustom event = EventCustom.emptyEvent;

  Place place = Place.emptyPlace;
  PlaceUser currentPlaceUser = PlaceUser();

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

    // Подгружаем мероприятие
    if (EventListsManager.currentFeedEventsList.eventsList.isNotEmpty){
      event = event.getEntityFromFeedList(widget.eventId);
    } else {
      event = await event.getEntityByIdFromDb(widget.eventId);
    }

    // Подгружаем данные заведения
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

    } else if (UserCustom.currentUser != null && UserCustom.currentUser!.uid != event.creatorId && UserCustom.currentUser!.myPlaces.isNotEmpty){

      // Если создатель не я
      // Читаем нашу роль

      currentPlaceUser.placeUserRole = UserCustom.currentUser!.getPlaceRoleFromMyPlaces(event.placeId);

      // Грузим создателя из БД
      creator = await creator.getUserByEmailOrId(uid: event.creatorId);

    } else {
      creator = await creator.getUserByEmailOrId(uid: event.creatorId);
    }

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
              List<dynamic> result = [true];
              Navigator.of(context).pop(result);
            },
          ),
          actions: [

            // ---- Кнопка редактирования ---

            if (currentPlaceUser.placeUserRole.controlLevel >= 90) IconButton(
                onPressed: () async {
                  // TODO сделать возвращение с экрана редактирования с ожиданием результата
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
            else CustomScrollView(
                slivers: <Widget> [
                  SliverList(delegate: SliverChildListDelegate(
                      [

                        ImageInViewScreenWidget(
                            imagePath: event.imageUrl,
                            favCounter: event.favUsersIds.length,
                            inFav: event.inFav,
                            onTap: () async {
                              await addOrDeleteFromFav();
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

                              // ВИДЖЕТ ЦЕНЫ И ОБРАТНОЙ СВЯЗИ

                              CallbackWidget(
                                priceType: event.priceType,
                                telegram: event.telegram,
                                whatsapp: event.whatsapp,
                                phone: event.phone,
                                instagram: event.instagram,
                                price: PriceTypeEnumClass.getFormattedPriceString(event.priceType, event.price),
                              ),

                              const SizedBox(height: 16.0),

                              // ВИДЖЕТ РАСПИСАНИЯ

                              ScheduleWidget(event: event),

                              const SizedBox(height: 16.0),

                              PlaceOrLocationWidget(
                                  city: event.city,
                                  desc: event.placeId != '' ? 'Ты можешь перейти в заведение и ознакомиться с ним подробнее' : 'Адрес, где будет проводится мероприятие',
                                  headline: event.placeId != '' ? 'Место проведения: ${place.name}' : 'Место проведения',
                                  house: event.house,
                                  street: event.street,
                                place: place,
                              ),

                              if (creator.uid != '') const SizedBox(height: 16.0),

                              if (creator.uid != '') CreatorWidget(headline: 'Создатель мероприятия', desc: 'Ты можешь написать создателю и задать вопросы', user: creator),

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

      if (event.inFav)
      {
        String resDel = await event.deleteFromFav();

        if (resDel == 'success'){

          _showSnackBar('Удалено из избранных', AppColors.attentionRed, 1);

        } else {
          _showSnackBar(resDel, AppColors.attentionRed, 1);
        }
      }
      else {
        String res = await event.addToFav();

        if (res == 'success') {

          _showSnackBar('Добавлено в избранные', Colors.green, 1);

        } else {
          _showSnackBar(res, AppColors.attentionRed, 1);
        }
      }

      EventCustom tempEvent = await event.getEntityByIdFromDb(event.id);

      setState(() {
        event = tempEvent;
      });

    }
  }
}