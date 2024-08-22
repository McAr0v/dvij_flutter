import 'dart:core';
import 'package:dvij_flutter/dates/date_mixin.dart';
import 'package:dvij_flutter/events/event_class.dart';
import 'package:dvij_flutter/promos/promo_class.dart';
import 'package:dvij_flutter/widgets_global/cards_widgets/card_widget_for_event_promo_places.dart';
import 'package:dvij_flutter/events/events_list_class.dart';
import 'package:dvij_flutter/places/place_admins_screens/place_admins_screen.dart';
import 'package:dvij_flutter/places/place_list_class.dart';
import 'package:dvij_flutter/places/places_elements/add_managers_widget.dart';
import 'package:dvij_flutter/widgets_global/images/image_in_view_screen_widget.dart';
import 'package:dvij_flutter/widgets_global/schedule_widgets/schedule_regular_widget.dart';
import 'package:dvij_flutter/widgets_global/text_widgets/expandable_text.dart';
import 'package:dvij_flutter/promos/promos_list_class.dart';
import 'package:dvij_flutter/users/place_user_class.dart';
import 'package:dvij_flutter/users/place_users_roles.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../promos/promotions/promo_view_page.dart';
import '../../widgets_global/social_widgets/callback_widget.dart';
import '../place_class.dart';
import '../../current_user/user_class.dart';
import '../../elements/exit_dialog/exit_dialog.dart';
import '../../elements/snack_bar.dart';
import '../../elements/loading_screen.dart';
import '../../events/events_screens/event_view_screen.dart';
import '../place_list_manager.dart';
import 'create_or_edit_place_screen.dart';

class PlaceViewScreen extends StatefulWidget {
  final String placeId;
  const PlaceViewScreen({Key? key, required this.placeId}) : super(key: key);

  @override
  PlaceViewScreenState createState() => PlaceViewScreenState();
}

class PlaceViewScreenState extends State<PlaceViewScreen> {

  List<PlaceUser> admins = [];
  PlaceUser currentPlaceUser = PlaceUser();

  Place place = Place.empty();

  EventsList eventsInThatPlace = EventsList();
  PromoList promosInThatPlace = PromoList();

  bool loading = true;
  bool deleting = false;

  @override
  void initState() {
    super.initState();
    fetchAndSetData();
  }

  Future<void> fetchAndSetData() async {

    setState(() {
      loading = true;
    });

    // Подгружаем данные заведения
    if (PlaceListManager.currentFeedPlacesList.placeList.isNotEmpty){
      place = place.getEntityFromFeedList(widget.placeId);
    }

    // Если вдруг мероприятия не оказалось в списке, подгружаем из БД
    if (place.id == '') {
      place = await place.getEntityByIdFromDb(widget.placeId);
    }

    // Подгружаем список администраторов
    admins = await currentPlaceUser.getAdminsFromDb(place.id);

    // Устанавливаем роль текущему пользователю
    if (UserCustom.currentUser != null){
      // Если пользователь - создатель
      if (place.creatorId == UserCustom.currentUser!.uid){
        // Выдаем права создателя
        PlaceUserRole role = PlaceUserRole();
        currentPlaceUser = currentPlaceUser.generatePlaceUserFromUserCustom(UserCustom.currentUser!);
        currentPlaceUser.placeUserRole = role.getPlaceUserRole(PlaceUserRoleEnum.creator);
      } else {
        // Если не создатель, то выдаем другие права
        currentPlaceUser = currentPlaceUser.getCurrentUserRoleInPlace(UserCustom.currentUser!, admins);
      }
    }

    // Подгружаем акции и мероприятия заведения
    if (place.eventsList.isNotEmpty){
      eventsInThatPlace = await eventsInThatPlace.getEntitiesFromStringList(place.eventsList);

    }
    if (place.promosList.isNotEmpty){
      promosInThatPlace = await promosInThatPlace.getEntitiesFromStringList(place.promosList);
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

        appBar: AppBar(
          title: Text(place.name != '' ? place.name : 'Загрузка...'),
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
                  await goToPlaceEditScreen();
                },
                icon: const Icon(Icons.edit)
            ),

            // ---- Кнопка удаления ---

            if (currentPlaceUser.placeUserRole.controlLevel == 100) IconButton(
                onPressed: () async {
                  deletePlace();
                },
                icon: const Icon(Icons.delete_forever, color: AppColors.attentionRed,)
            ),

          ],
        ),

        body: Stack(
          children: [
            if (loading) const LoadingScreen(),
            if (deleting) const LoadingScreen(loadingText: 'Подожди, идет удаление заведения'),
            if (!loading && !deleting) CustomScrollView(
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildListDelegate(
                    [

                      ImageInViewScreenWidget(
                          imagePath: place.imageUrl,
                          favCounter: place.favUsersIds.length,
                          inFav: place.inFav,
                          onTap: () async {
                            await addOrDeleteFromFav();
                          },
                          categoryName: place.category.name,
                          headline: place.name,
                          desc: '${place.city.name}, ${place.street}, ${place.house}',
                          openOrToday: place.nowIsOpen,
                          trueText: 'Сейчас открыто',
                          falseText: 'Сейчас закрыто'
                      ),

                      // ВИДЖЕТЫ ПОД КАРТИНКОЙ

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const SizedBox(height: 20.0),

                            // ВИДЖЕТ МЕНЕДЖЕРОВ

                            if (currentPlaceUser.placeUserRole.controlLevel >= 90) AddManagersWidget(
                                headline: 'Менеджеры (${admins.length})',
                                desc: 'Ты можешь добавить менеджеров к этому заведению, чтобы они управляли им вместе с тобой. У каждого менеджера свой уровень доступа',
                              onTapMethod: (){
                                navigateToManagersList();
                              },
                            ),

                            if (currentPlaceUser.placeUserRole.controlLevel >= 90) const SizedBox(height: 16.0),

                            // ВИДЖЕТ ТЕЛЕФОНА И СОЦ СЕТЕЙ

                            CallbackWidget(
                              telegram: place.telegram,
                              whatsapp: place.whatsapp,
                              phone: place.phone,
                              instagram: place.instagram,
                            ),

                            const SizedBox(height: 16.0),

                            // РАСКРЫВАЮЩЕЕСЯ ОПИСАНИЕ

                            if (place.desc.isNotEmpty) const SizedBox(height: 14.0),

                            if (place.desc.isNotEmpty) ExpandableText(text: place.desc),

                            if (place.desc.isNotEmpty) const SizedBox(height: 30.0),

                            // ВИДЖЕТ РЕЖИМА РАБОТЫ

                            ScheduleRegularWidget(
                                headline: 'Режим работы',
                                desc: 'Посмотри, когда ${place.name} открыто и готово к приему гостей)',
                                regularDate: place.openingHours,
                              isPlace: true
                            ),

                            const SizedBox(height: 10,)

                          ],
                        ),
                      )
                    ],
                  ),
                ),

                // КАРУСЕЛЬ МЕРОПРИЯТИЙ

                _eventsHorizontalScroll(title: 'Мероприятия в "${place.name}"', desc: 'Любишь это место? Проведи здесь весело время вместе с ближайшими мероприятиями!', eventsList: eventsInThatPlace),

                // КАРУСЕЛЬ АКЦИЙ

                _promosHorizontalScroll(title: 'Акции в "${place.name}"', desc: 'Вся доступная халява этого заведения)', promosList: promosInThatPlace),

                // ВИДЖЕТ ДАТЫ СОЗДАНИЯ

                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      if (place.createDate != DateTime(2100)) Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('В движе с', style: Theme.of(context).textTheme.labelSmall!.copyWith(color: AppColors.greyText),),
                            Text(DateMixin.getHumanDateFromDateTime(place.createDate), style: Theme.of(context).textTheme.bodySmall,),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        )
    );
  }

  // ВИДЖЕТ КАРУСЕЛИ МЕРОПРИЯТИЙ

  SliverToBoxAdapter _eventsHorizontalScroll({required String title, required String desc, required EventsList eventsList}) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.greyOnBackground
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  eventsList.eventsList.isEmpty ? 20 : 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    desc,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.greyText),
                  ),

                  if (eventsList.eventsList.isEmpty) const SizedBox(height: 20),

                  if (eventsList.eventsList.isEmpty) Text(
                    'Пока никаких мероприятий не запланировано(',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                ],
              ),
            ),

            if (eventsList.eventsList.length == 1) CardWidgetForEventPromoPlaces(
              width: 1000,
              event: eventsList.eventsList[0],
              onTap: () async {
                await _goToEventScreen(eventsList, 0);
              },
              onFavoriteIconPressed: () async {
                await _addOrDeleteEventFromFav(eventsList, 0);
              },
            ),

            if (eventsList.eventsList.length > 1) SizedBox(
              height: 450,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: eventsList.eventsList.length,
                itemBuilder: (context, index) {
                  return CardWidgetForEventPromoPlaces(
                    width: 330,
                    event: eventsList.eventsList[index],
                    onTap: () async {
                      await _goToEventScreen(eventsList, index);
                    },
                    onFavoriteIconPressed: () async {
                      await _addOrDeleteEventFromFav(eventsList, index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _goToEventScreen(EventsList eventsList, int index) async {
    final results = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventViewScreen(eventId: eventsList.eventsList[index].id),
      ),
    );

    if (results != null) {
      EventCustom tempEvent = EventCustom.emptyEvent;
      tempEvent = await tempEvent.getEntityByIdFromDb(eventsList.eventsList[index].id);
      setState(() {
        if (tempEvent.id == eventsList.eventsList[index].id){
          eventsList.eventsList[index] = tempEvent;
        }
      });

      Place tempPlace = Place.empty();
      tempPlace = await tempPlace.getEntityByIdFromDb(place.id);

      EventsList tempEventsList = EventsList();
      if (tempPlace.eventsList.isNotEmpty){
        tempEventsList = await tempEventsList.getEntitiesFromStringList(place.eventsList);
      }

      setState(() {
        place = tempPlace;
        eventsInThatPlace = tempEventsList;
      });

    }
  }

  Future<void> _addOrDeleteEventFromFav(EventsList eventsList, int index) async {
    // ---- Если не зарегистрирован или не вошел ----
    if (UserCustom.currentUser?.uid == '' || UserCustom.currentUser?.uid == null)
    {
      _showSnackBar('Чтобы добавлять в избранное, нужно зарегистрироваться!', AppColors.attentionRed, 2);
    }

    // --- Если пользователь залогинен -----
    else {

      // --- Если уже в избранном ----
      if (eventsList.eventsList[index].inFav == true)
      {

        // --- Удаляем из избранных ---
        String resDel = await eventsList.eventsList[index].deleteFromFav();

        if (resDel == 'success'){
          _showSnackBar('Удалено из избранных', AppColors.attentionRed, 1);
        } else {
          _showSnackBar(resDel, AppColors.attentionRed, 1);
        }
      }
      else {
        // --- Если мероприятие не в избранном ----

        // -- Добавляем в избранное ----
        String res = await eventsList.eventsList[index].addToFav();

        if (res == 'success') {

          _showSnackBar('Добавлено в избранные', Colors.green, 1);

        } else {
          _showSnackBar(res, AppColors.attentionRed, 1);
        }
      }
    }
  }

  // ВИДЖЕТ КАРУСЕЛИ АКЦИЙ

  SliverToBoxAdapter _promosHorizontalScroll({required String title, required String desc, required PromoList promosList}) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.greyOnBackground
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  promosList.promosList.isEmpty ? 20 : 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    desc,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.greyText),
                  ),

                  if (promosList.promosList.isEmpty) const SizedBox(height: 20),

                  if (promosList.promosList.isEmpty) Text(
                    'Акций на ближайшее будущее не планируется(',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                ],
              ),
            ),

            if (promosList.promosList.length == 1) const SizedBox(height: 10),

            if (promosList.promosList.length == 1) CardWidgetForEventPromoPlaces(
              width: 1000,
              promo: promosList.promosList[0],
              onTap: () async {
                await _goToPromoScreen(promosList, 0);
              },
              onFavoriteIconPressed: () async {
                await _addOrDeletePromoFromFav(promosList, 0);
              },
            ),

            if (promosList.promosList.length > 1) SizedBox(
              height: 450,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: promosList.promosList.length,
                itemBuilder: (context, index) {
                  return CardWidgetForEventPromoPlaces(
                    promo: promosList.promosList[index],
                    onTap: () async {
                      await _goToPromoScreen(promosList, index);
                    },
                    onFavoriteIconPressed: () async {
                      await _addOrDeletePromoFromFav(promosList, index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _goToPromoScreen(PromoList promosList, int index) async {
    // TODO сделать возврат с экрана акции с результатом
    final results = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PromoViewScreen(promoId: promosList.promosList[index].id),
      ),
    );

    if (results != null) {
      PromoCustom tempPromo = PromoCustom.emptyPromo;
      tempPromo = await tempPromo.getEntityByIdFromDb(promosList.promosList[index].id);
      setState(() {
        if (tempPromo.id == promosList.promosList[index].id){
          promosList.promosList[index] = tempPromo;
        }
      });

      Place tempPlace = Place.empty();
      tempPlace = await tempPlace.getEntityByIdFromDb(place.id);

      PromoList tempPromoList = PromoList();
      if (tempPlace.promosList.isNotEmpty){
        tempPromoList = await tempPromoList.getEntitiesFromStringList(place.promosList);
      }

      setState(() {
        place = tempPlace;
        promosInThatPlace = tempPromoList;
      });

    }
  }

  Future<void> _addOrDeletePromoFromFav(PromoList promosList, int index) async {
    // ---- Если не зарегистрирован или не вошел ----
    if (UserCustom.currentUser?.uid == '' || UserCustom.currentUser?.uid == null)
    {
      _showSnackBar('Чтобы добавлять в избранное, нужно зарегистрироваться!', AppColors.attentionRed, 2);
    }

    // --- Если пользователь залогинен -----
    else {

      // --- Если уже в избранном ----
      if (promosList.promosList[index].inFav == true)
      {

        // --- Удаляем из избранных ---
        String resDel = await promosList.promosList[index].deleteFromFav();

        if (resDel == 'success'){
          _showSnackBar('Удалено из избранных', AppColors.attentionRed, 1);
        } else {
          _showSnackBar(resDel, AppColors.attentionRed, 1);
        }
      }
      else {
        // --- Если акция не в избранном ----

        // -- Добавляем в избранное ----
        String res = await promosList.promosList[index].addToFav();

        if (res == 'success') {

          _showSnackBar('Добавлено в избранные', Colors.green, 1);

        } else {
          _showSnackBar(res, AppColors.attentionRed, 1);
        }
      }
    }
  }

  void navigateToPlaces() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/Places',
          (route) => false,
    );
  }

  void deletePlace() async {
    bool? confirmed = await exitDialog(
        context,
        "Ты правда хочешь удалить заведение? Ты не сможешь восстановить данные. "
            "Так же удалятся все менеджеры, мероприятия и акции, опубликованные от имени этого заведения",
        'Да',
        'Нет',
        'Удаление заведения'
    );

    if (confirmed != null && confirmed){

      setState(() {
        deleting = true;
      });

      String delete = await place.deleteFromDb();

      if (delete == 'success'){

        place.deleteEntityFromCurrentEntityLists();

        _showSnackBar('Место успешно удалено', Colors.green, 2);

        navigateToPlaces();

        setState(() {
          deleting = false;
        });
      } else {
        _showSnackBar('Место не было удалено по ошибке: $delete', AppColors.attentionRed, 2);

        setState(() {
          deleting = false;
        });
      }

    }
  }

  void navigateToManagersList() async {

    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlaceAdminsScreen(place: place))
    );

    // Проверяем, изменили ли заведение на экране списка менеджеров
    // Если да, то обновляем наше заведение во всех списках
    if (result != null) {
      setState(() {
        place = result;
      });
      fetchAndSetData();
    }
  }

  void _showSnackBar(String text, Color color, int time){
    showSnackBar(context, text, color, time);
  }

  Future<void> addOrDeleteFromFav() async {
    if (UserCustom.currentUser?.uid == '' || UserCustom.currentUser?.uid == null) {
      showSnackBar(context, 'Чтобы добавлять в избранное, нужно зарегистрироваться!', AppColors.attentionRed, 2);
    } else {
      if (place.inFav) {
        String resDel = await place.deleteFromFav();
        if (resDel == 'success'){

          _showSnackBar('Удалено из избранных', AppColors.attentionRed, 1);

        } else {
          _showSnackBar(resDel, AppColors.attentionRed, 1);
        }
      } else {
        String res = await place.addToFav();
        if (res == 'success') {

          _showSnackBar('Добавлено в избранные', Colors.green, 1);

        } else {
          _showSnackBar(res, AppColors.attentionRed, 1);
        }
      }

      Place tempPlace = await place.getEntityByIdFromDb(place.id);

      setState(() {
        place = tempPlace;
      });

    }
  }

  Future<void> goToPlaceEditScreen() async {
    final results = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateOrEditPlaceScreen(placeInfo: place),
      ),
    );

    if (results != null) {

      PlaceList placesList = PlaceList();

      Place tempPlace = placesList.getEntityFromFeedListById(place.id);

      if (tempPlace.id.isEmpty){
        tempPlace = await place.getEntityByIdFromDb(place.id);
      }

      setState(() {
        place = tempPlace;
      });

    }
  }
}