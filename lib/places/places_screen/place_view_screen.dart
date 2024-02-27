import 'dart:core';
import 'package:dvij_flutter/dates/date_mixin.dart';
import 'package:dvij_flutter/events/event_class.dart';
import 'package:dvij_flutter/events/events_elements/event_card_small_widget.dart';
import 'package:dvij_flutter/events/events_list_class.dart';
import 'package:dvij_flutter/places/place_admins_screens/place_admins_screen.dart';
import 'package:dvij_flutter/places/place_list_class.dart';
import 'package:dvij_flutter/places/places_elements/add_managers_widget.dart';
import 'package:dvij_flutter/widgets_global/schedule_widgets/schedule_regular_widget.dart';
import 'package:dvij_flutter/widgets_global/text_widgets/headline_and_desc.dart';
import 'package:dvij_flutter/widgets_global/social_widgets/social_buttons_widget.dart';
import 'package:dvij_flutter/promos/promos_list_class.dart';
import 'package:dvij_flutter/users/place_user_class.dart';
import 'package:dvij_flutter/users/place_users_roles.dart';
import 'package:dvij_flutter/widgets_global/images/image_with_placeholder.dart';
import 'package:dvij_flutter/widgets_global/text_widgets/text_size_enum.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../dates/date_type_enum.dart';
import '../../elements/shedule_elements/schedule_regular_and_irregular_widget.dart';
import '../../promos/promos_elements/promo_card_widget.dart';
import '../../promos/promotions/promo_view_page.dart';
import '../place_class.dart';
import '../../classes/user_class.dart';
import '../../elements/exit_dialog/exit_dialog.dart';
import '../../elements/snack_bar.dart';
import '../../widgets_global/text_widgets/for_cards_small_widget_with_icon_and_text.dart';
import '../../elements/loading_screen.dart';
import '../../events/events_elements/event_card_widget.dart';
import '../../events/events_screens/event_view_screen.dart';
import '../../widgets_global/text_widgets/now_is_work_widget.dart';
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

  Place place = Place.emptyPlace;

  EventsList eventsInThatPlace = EventsList();
  PromoList promosInThatPlace = PromoList();

  DateTime currentDate = DateTime.now();

  // --- Переключатель показа экрана загрузки -----

  bool loading = true;
  bool deleting = false;
  bool inFav = false;
  int favCounter = 0;

  // Активный переключатель - мероприятия или акции
  bool events = true;

  @override
  void initState() {
    super.initState();
    fetchAndSetData();
  }

  Future<void> fetchAndSetData() async {

    if (PlaceListManager.currentFeedPlacesList.placeList.isNotEmpty){
      place = place.getEntityFromFeedList(widget.placeId);
    } else {
      place = await place.getEntityByIdFromDb(widget.placeId);

    }

    //place = place.getEntityFromFeedList(widget.placeId);

    favCounter = place.addedToFavouritesCount!;

    admins = await currentPlaceUser.getAdminsInfoFromDb(place.admins!);

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
    if (place.eventsList != null && place.eventsList!.isNotEmpty){
      eventsInThatPlace = await eventsInThatPlace.getEntitiesFromStringList(place.eventsList!);

    }
    if (place.promosList != null && place.promosList!.isNotEmpty){
      promosInThatPlace = await promosInThatPlace.getEntitiesFromStringList(place.promosList!);
    }

    inFav = place.inFav!;
    favCounter = place.addedToFavouritesCount!;

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
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              // Возвращаем данные о состоянии избранного на экран ленты
              // На случай, если мы добавляли/убирали из избранного
              List<dynamic> result = [inFav, favCounter];
              Navigator.of(context).pop(result);
            },
          ),
          actions: [
            if (currentPlaceUser.placeUserRole.controlLevel >= 90) IconButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateOrEditPlaceScreen(placeInfo: place))
                  );
                },
                icon: const Icon(Icons.edit)
            ),

            if (currentPlaceUser.placeUserRole.controlLevel == 100) IconButton(
                onPressed: () async {
                  bool? confirmed = await exitDialog(context, "Ты правда хочешь удалить заведение? Ты не сможешь восстановить данные" , 'Да', 'Нет', 'Удаление заведения');

                  if (confirmed != null && confirmed){

                    setState(() {
                      deleting = true;
                    });

                    //String delete = await Place.deletePlace(widget.placeId, users, place.creatorId);
                    String delete = await place.deleteFromDb();

                    if (delete == 'success'){

                      place.deleteEntityFromCurrentEntityLists();

                      //Place.deletePlaceFormCurrentPlaceLists(widget.placeId);

                      showSnackBar(context, 'Место успешно удалено', Colors.green, 2);
                      navigateToPlaces();

                      setState(() {
                        deleting = false;
                      });
                    } else {
                      showSnackBar(context, 'Место не было удалено по ошибке: $delete', AppColors.attentionRed, 2);
                      setState(() {
                        deleting = false;
                      });
                    }

                  }

                },
                icon: const Icon(Icons.delete_forever, color: AppColors.attentionRed,)
            ),

          ],
        ),

        body: Stack(
          children: [
            if (loading) LoadingScreen(),
            if (deleting) const LoadingScreen(loadingText: 'Подожди, идет удаление заведения',),
            if (place.name != '') CustomScrollView(
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ImageWithPlaceHolderWidget(imagePath: place.imageUrl),

                          // Виджет ИЗБРАННОЕ

                          Positioned(
                            top: 10.0,
                            right: 10.0,
                            child: IconAndTextInTransparentSurfaceWidget(
                              icon: Icons.bookmark,
                              text: '$favCounter',
                              iconColor: inFav ? AppColors.brandColor : AppColors.white,
                              side: false,
                              backgroundColor: AppColors.greyBackground.withOpacity(0.8),
                              onPressed: () async {
                                addOrDeleteFromFav();
                              },
                            ),
                          ),

                          // Виджет КАТЕГОРИЯ

                          Positioned(
                            top: 10.0,
                            left: 10.0,
                            child: IconAndTextInTransparentSurfaceWidget(
                                text: place.category.name,
                                iconColor: AppColors.white,
                                side: true,
                                backgroundColor: AppColors.greyBackground.withOpacity(0.8)
                            ),
                          ),

                          Positioned(
                            bottom: 20.0,
                            left: 20.0,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  HeadlineAndDesc(
                                    headline: place.name,
                                    description: '${place.city.name}, ${place.street}, ${place.house}',
                                    textSize: TextSizeEnum.headlineLarge,
                                    descSize: TextSizeEnum.bodySmall,
                                    descColor: AppColors.white,
                                    padding: 5,
                                  ),

                                  const SizedBox(height: 5,),

                                  TextOnBoolResultWidget(isTrue: place.nowIsOpen!, trueText: 'Сейчас открыто', falseText: 'Сейчас закрыто'),

                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            if (currentPlaceUser.placeUserRole.controlLevel >= 90) AddManagersWidget(
                                headline: 'Менеджеры (${place.admins!.length + 1})',
                                desc: 'Ты можешь добавить менеджеров к этому заведению, чтобы они управляли им вместе с тобой. У каждого менеджера свой уровень доступа',
                              onTapMethod: (){
                                navigateToManagersList();
                              },
                            ),

                            if (currentPlaceUser.placeUserRole.controlLevel >= 90) const SizedBox(height: 16.0),

                            SocialButtonsWidget(telegramUsername: place.telegram, instagramUsername: place.instagram, whatsappUsername: place.whatsapp, phoneNumber: place.phone,),

                            const SizedBox(height: 16.0),

                            if (place.desc != '') HeadlineAndDesc(headline: place.desc, description: 'Описание места', padding: 5, textSize: TextSizeEnum.bodyMedium,),

                            const SizedBox(height: 16.0),

                            ScheduleRegularWidget(
                                headline: 'Режим работы',
                                desc: 'Посмотри, когда ${place.name} открыто и готово к приему гостей)',
                                regularDate: place.openingHours,
                              isPlace: true
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                _buildHorizontalBlock(title: 'Мероприятия в "${place.name}"', eventsList: eventsInThatPlace),

                _buildHorizontalBlock(title: 'Заголовок', eventsList: eventsInThatPlace),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      if (place.createDate != DateTime(2100)) Padding(
                          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(DateMixin.getHumanDateFromDateTime(place.createDate), style: Theme.of(context).textTheme.bodySmall,),
                            Text('Создано в движе', style: Theme.of(context).textTheme.labelSmall!.copyWith(color: AppColors.greyText),),
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

  SliverToBoxAdapter _buildHorizontalBlock({required String title, required EventsList eventsList}) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 5,),
                Text(
                  'Любишь это место? Проведи здесь весело время вместе с ближайшими мероприятиями!',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.greyText),
                )
              ],
            ),
          ),
          SizedBox(
            height: 450,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: eventsList.eventsList.length,
              itemBuilder: (context, index) {
                return EventSmallCardWidget(
                  event: eventsList.eventsList[index],
                  onTap: () async {

                    // TODO - переделать на мероприятия
                    final results = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventViewScreen(eventId: eventsList.eventsList[index].id),
                      ),
                    );

                    if (results != null) {
                      setState(() {
                        eventsList.eventsList[index].inFav = results[0];
                        eventsList.eventsList[index].addedToFavouritesCount = results[1];
                      });
                    }
                  },

                  // --- Функция на нажатие на карточке кнопки ИЗБРАННОЕ ---
                  onFavoriteIconPressed: () async {

                    // TODO Сделать проверку на подтвержденный Email
                    // ---- Если не зарегистрирован или не вошел ----
                    if (UserCustom.currentUser?.uid == '' || UserCustom.currentUser?.uid == null)
                    {
                      showSnackBar(context, 'Чтобы добавлять в избранное, нужно зарегистрироваться!', AppColors.attentionRed, 2);
                    }

                    // --- Если пользователь залогинен -----
                    else {

                      // --- Если уже в избранном ----
                      if (eventsList.eventsList[index].inFav == true)
                      {
                        // --- Удаляем из избранных ---
                        String resDel = await eventsList.eventsList[index].deleteFromFav();
                        // ---- Инициализируем счетчик -----
                        int favCounter = eventsList.eventsList[index].addedToFavouritesCount!;

                        if (resDel == 'success'){
                          // Если удаление успешное, обновляем 2 списка - текущий на экране, и общий загруженный из БД
                          setState(() {
                            // Обновляем текущий список
                            eventsList.eventsList[index].inFav = false;
                            favCounter --;
                            eventsList.eventsList[index].addedToFavouritesCount = favCounter;
                            // Обновляем общий список из БД
                            eventsList.eventsList[index].updateCurrentListFavInformation();
                            //EventCustom.updateCurrentEventListFavInformation(eventsList[indexWithAddCountCorrection].id, favCounter, false);

                          });
                          showSnackBar(context, 'Удалено из избранных', AppColors.attentionRed, 1);
                        } else {
                          // Если удаление из избранных не прошло, показываем сообщение
                          showSnackBar(context, resDel, AppColors.attentionRed, 1);
                        }
                      }
                      else {
                        // --- Если заведение не в избранном ----

                        // -- Добавляем в избранное ----
                        String res = await eventsList.eventsList[index].addToFav();

                        // ---- Инициализируем счетчик добавивших в избранное
                        int favCounter = eventsList.eventsList[index].addedToFavouritesCount!;

                        if (res == 'success') {
                          // --- Если добавилось успешно, так же обновляем текущий список и список из БД
                          setState(() {
                            // Обновляем текущий список
                            eventsList.eventsList[index].inFav = true;
                            favCounter ++;
                            eventsList.eventsList[index].addedToFavouritesCount = favCounter;
                            // Обновляем список из БД
                            eventsList.eventsList[index].updateCurrentListFavInformation();
                            //EventCustom.updateCurrentEventListFavInformation(eventsList[indexWithAddCountCorrection].id, favCounter, true);
                          });

                          showSnackBar(context, 'Добавлено в избранные', Colors.green, 1);

                        } else {
                          // Если добавление прошло неудачно, отображаем всплывающее окно
                          showSnackBar(context , res, AppColors.attentionRed, 1);
                        }
                      }
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void navigateToPlaces() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/Places',
          (route) => false,
    );
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
        PlaceList placeList = PlaceList();
        place = result;
        placeList.updateCurrentListAdminsInformation(place.id, place.admins!);
      });
      fetchAndSetData();
    }
  }

  Future<void> addOrDeleteFromFav() async {
    // TODO Сделать проверку на подтвержденный Email
    if (UserCustom.currentUser?.uid == '' || UserCustom.currentUser?.uid == null)
    {

      showSnackBar(context, 'Чтобы добавлять в избранное, нужно зарегистрироваться!', AppColors.attentionRed, 2);

    }

    else {

      if (inFav)
      {

        //String resDel = await Place.deletePlaceFromFav(place.id);
        String resDel = await place.deleteFromFav();

        if (resDel == 'success'){
          setState(() {
            inFav = false;
            favCounter --;
            place.inFav = inFav;
            place.addedToFavouritesCount = favCounter;

            place.updateCurrentListFavInformation();

            //Place.updateCurrentPlaceListFavInformation(place.id, favCounter.toString(), inFav);
          });

          showSnackBar(context, 'Удалено из избранных', AppColors.attentionRed, 1);
        } else {

          showSnackBar(context, resDel, AppColors.attentionRed, 1);
        }



      }
      else {
        //String res = await Place.addPlaceToFav(place.id);
        String res = await place.addToFav();
        if (res == 'success') {

          setState(() {
            inFav = true;
            favCounter ++;
            place.inFav = inFav;
            place.addedToFavouritesCount = favCounter;
            place.updateCurrentListFavInformation();
            //Place.updateCurrentPlaceListFavInformation(place.id, favCounter.toString(), inFav);
          });

          showSnackBar(context, 'Добавлено в избранные', Colors.green, 1);

        } else {

          showSnackBar(context, res, AppColors.attentionRed, 1);

        }

      }

    }
  }

}