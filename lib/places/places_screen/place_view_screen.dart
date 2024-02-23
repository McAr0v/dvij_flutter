import 'dart:core';

import 'package:dvij_flutter/dates/date_mixin.dart';
import 'package:dvij_flutter/events/event_class.dart';
import 'package:dvij_flutter/events/events_list_class.dart';
import 'package:dvij_flutter/places/place_admins_screens/place_admins_screen.dart';
import 'package:dvij_flutter/places/place_list_class.dart';
import 'package:dvij_flutter/promos/promo_class.dart';
import 'package:dvij_flutter/elements/text_and_icons_widgets/headline_and_desc.dart';
import 'package:dvij_flutter/elements/social_elements/social_buttons_widget.dart';
import 'package:dvij_flutter/promos/promos_list_class.dart';
import 'package:dvij_flutter/users/place_user_class.dart';
import 'package:dvij_flutter/users/place_users_roles.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../cities/city_class.dart';
import '../../promos/promos_elements/promo_card_widget.dart';
import '../../promos/promotions/promo_view_page.dart';
import '../place_category_class.dart';
import '../place_class.dart';
import '../../classes/user_class.dart';
import '../../elements/exit_dialog/exit_dialog.dart';
import '../../elements/snack_bar.dart';
import '../../elements/text_and_icons_widgets/for_cards_small_widget_with_icon_and_text.dart';
import '../../elements/loading_screen.dart';
import '../../events/events_elements/event_card_widget.dart';
import '../../events/events_screens/event_view_screen.dart';
import '../../methods/days_functions.dart';
import '../place_admins_screens/place_manager_add_screen.dart';
import '../places_elements/now_is_work_widget.dart';
import '../places_elements/place_managers_element_list_item.dart';
import '../places_elements/place_work_time_element.dart';
import 'create_or_edit_place_screen.dart';


// --- ЭКРАН ЗАЛОГИНЕВШЕГОСЯ ПОЛЬЗОВАТЕЛЯ -----

class PlaceViewScreen extends StatefulWidget {
  final String placeId;
  const PlaceViewScreen({Key? key, required this.placeId}) : super(key: key);

  @override
  PlaceViewScreenState createState() => PlaceViewScreenState();
}

class PlaceViewScreenState extends State<PlaceViewScreen> {

  // ---- Инициализируем пустые переменные ----

  List<PlaceUser> admins = [];
  PlaceUser creator = PlaceUser();
  PlaceUser currentPlaceUser = PlaceUser();


  Place place = Place.emptyPlace;
  City city = City.emptyCity;
  PlaceCategory category = PlaceCategory.empty;

  EventsList eventsInThatPlace = EventsList();
  PromoList promosInThatPlace = PromoList();

  DateTime currentDate = DateTime.now();

  // --- Переключатель показа экрана загрузки -----

  bool loading = true;
  bool deleting = false;
  bool inFav = false;
  int favCounter = 0;

  bool events = true;

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
      place = place.getEntityFromFeedList(widget.placeId);

      favCounter = place.addedToFavouritesCount!;



      admins = await creator.getAdminsInfoFromDb(place.admins!);



      if (UserCustom.currentUser != null){

        if (place.creatorId == UserCustom.currentUser!.uid){
          PlaceUserRole role = PlaceUserRole();
          creator = creator.generatePlaceUserFromUserCustom(UserCustom.currentUser!);
          creator.placeUserRole = role.getPlaceUserRole(PlaceUserRoleEnum.creator);
          currentPlaceUser = creator;
        } else {
          currentPlaceUser = currentPlaceUser.getCurrentUserRoleInPlace(UserCustom.currentUser!, admins);
          creator = await creator.getPlaceUserFromDb(place.creatorId, PlaceUserRoleEnum.creator);
        }

      } else {
        creator = await creator.getPlaceUserFromDb(place.creatorId, PlaceUserRoleEnum.creator);
      }

      city = place.city;
      category = place.category;

      if (place.eventsList != null && place.eventsList!.isNotEmpty){

        eventsInThatPlace = await eventsInThatPlace.getEntitiesFromStringList(place.eventsList!);

      }

      if (place.promosList != null && place.promosList!.isNotEmpty){

        promosInThatPlace = await promosInThatPlace.getEntitiesFromStringList(place.promosList!);

      }

      inFav = place.inFav!;
      favCounter = place.addedToFavouritesCount!;


      // ---- Убираем экран загрузки -----
      setState(() {
        loading = false;
      });
    } catch (e) {
      // TODO Сделать обработку ошибок, если не получилось считать данные
    }
  }

  // ---- Функция перехода в профиль ----
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

    // Проверяем результат и вызываем функцию fetchAndSetData
    if (result != null) {
      setState(() {
        PlaceList placeList = PlaceList();
        place = result;
        placeList.updateCurrentListAdminsInformation(place.id, place.admins!);
      });
      fetchAndSetData();
    }

  }

  /*void navigateToEditManager(PlaceUser user) async {
    final result = await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceManagerAddScreen(
          placeId: widget.placeId,
          isEdit: true,
          user: user,
          placeCreatorUid: place.creatorId,
          admins: place.admins!,
        ),
      ),
    );

    // Проверяем результат и вызываем функцию fetchAndSetData
    if (result != null) {

      fetchAndSetData();
    }

  }*/



  // ---- Функция отображения всплывающих сообщений -----
  /*void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }*/

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text(place.name != '' ? place.name : 'Загрузка...'),
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
            else if (deleting) const LoadingScreen(loadingText: 'Подожди, удаляем заведение',)
            else ListView(

              children: [
                if (place.imageUrl != '') // Проверяем, есть ли ссылка на аватар
                // TODO - Сделать более проработанную проверку аватарки

                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      // Изображение
                      Container(
                        height: MediaQuery.of(context).size.width * 0.7, // Ширина экрана
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(place.imageUrl), // Используйте ссылку на изображение из вашего Place
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



                          },
                        ),
                      ),

                      Positioned(
                        top: 10.0,
                        left: 10.0,
                        child: SmallWidgetForCardsWithIconAndText(
                          //icon: Icons.visibility,
                            text: category.name,
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

                      if (place.name != '') Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    place.name,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  '${city.name}, ${place.street}, ${place.house}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                )
                              ],
                            )
                          ),
                          const SizedBox(width: 16.0),

                          // TODO - сделать скрытие кнопки редактирования места если нет доступа к редактированию
                          // --- Кнопка редактирования ----
                          if (currentPlaceUser.placeUserRole.controlLevel >= 90) IconButton(
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
                                  MaterialPageRoute(builder: (context) => CreateOrEditPlaceScreen(placeInfo: place))
                              );
                            },
                            // Действие при нажатии на кнопку редактирования
                          ),
                        ],
                      ),



                      // ---- Остальные данные пользователя ----



                      const SizedBox(height: 5.0),

                      NowIsWorkWidget(isTrue: place.nowIsOpen!),

                      const SizedBox(height: 16.0),

                      SocialButtonsWidget(telegramUsername: place.telegram, instagramUsername: place.instagram, whatsappUsername: place.whatsapp, phoneNumber: place.phone,),

                      const SizedBox(height: 16.0),

                      if (place.desc != '') HeadlineAndDesc(headline: place.desc, description: 'Описание места'),

                      const SizedBox(height: 16.0),

                      PlaceWorkTimeCard(
                          place: place,
                      ),

                      const SizedBox(height: 16.0),

                      if (place.createDate != DateTime(2100)) HeadlineAndDesc(headline: DateMixin.getHumanDateFromDateTime(place.createDate), description: 'Создано в движе', ),

                      // TODO - Сделать ограничение на редактирование
                      const SizedBox(height: 30.0),

                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              buttonText: 'Мероприятия',
                              onTapMethod: (){
                                setState(() {
                                  events = true;
                                });
                              },
                              state: events ? 'normal' : 'secondary',
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: CustomButton(
                              buttonText: 'Акции',
                              onTapMethod: (){
                                setState(() {
                                  events = false;
                                });
                              },
                              state: !events ? 'normal' : 'secondary',
                            ),
                          ),
                        ],
                      ),


                      if (events) const SizedBox(height: 30.0),

                      if (events) Text(
                          'Мероприятия ${place.name}:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),

                      if (events) const SizedBox(height: 16.0),

                      if (events && eventsInThatPlace.eventsList.isEmpty) Container(
                        decoration: const BoxDecoration(
                          color: AppColors.greyOnBackground
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'Это заведение пока не проводит никаких мероприятий'
                            ),
                          ),
                        ),
                      ),

                      if (events && eventsInThatPlace.eventsList.isNotEmpty) Column(
                        children: List.generate(eventsInThatPlace.eventsList.length, (index) {
                          return Column( // сюда можно вставить шаблон элемента
                              children: [

                                EventCardWidget(
                                    event: eventsInThatPlace.eventsList[index],
                                  onTap: () async {

                                    // TODO - переделать на мероприятия
                                    final results = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EventViewScreen(eventId: eventsInThatPlace.eventsList[index].id),
                                      ),
                                    );

                                    if (results != null) {
                                      setState(() {
                                        eventsInThatPlace.eventsList[index].inFav = results[0];
                                        eventsInThatPlace.eventsList[index].addedToFavouritesCount = results[1];
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
                                      if (eventsInThatPlace.eventsList[index].inFav!)
                                      {
                                        // --- Удаляем из избранных ---

                                        String resDel = await eventsInThatPlace.eventsList[index].deleteFromFav();
                                        // ---- Инициализируем счетчик -----
                                        int favCounter = eventsInThatPlace.eventsList[index].addedToFavouritesCount!;

                                        if (resDel == 'success'){
                                          // Если удаление успешное, обновляем 2 списка - текущий на экране, и общий загруженный из БД
                                          setState(() {
                                            // Обновляем текущий список
                                            eventsInThatPlace.eventsList[index].inFav = false;
                                            favCounter --;
                                            eventsInThatPlace.eventsList[index].addedToFavouritesCount = favCounter;
                                            // Обновляем общий список из БД
                                            eventsInThatPlace.eventsList[index].updateCurrentListFavInformation();
                                            //EventCustom.updateCurrentEventListFavInformation(eventsInThatPlace[index].id, favCounter, false);

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
                                        String res = await eventsInThatPlace.eventsList[index].addToFav();

                                        // ---- Инициализируем счетчик добавивших в избранное
                                        int favCounter = eventsInThatPlace.eventsList[index].addedToFavouritesCount!;

                                        if (res == 'success') {
                                          // --- Если добавилось успешно, так же обновляем текущий список и список из БД
                                          setState(() {
                                            // Обновляем текущий список
                                            eventsInThatPlace.eventsList[index].inFav = true;
                                            favCounter ++;
                                            eventsInThatPlace.eventsList[index].addedToFavouritesCount = favCounter;
                                            // Обновляем список из БД
                                            //EventCustom.updateCurrentEventListFavInformation(eventsInThatPlace[index].id, favCounter, true);
                                            eventsInThatPlace.eventsList[index].updateCurrentListFavInformation();
                                          });

                                          showSnackBar(context, 'Добавлено в избранные', Colors.green, 1);

                                        } else {
                                          // Если добавление прошло неудачно, отображаем всплывающее окно
                                          showSnackBar(context , res, AppColors.attentionRed, 1);
                                        }
                                      }
                                    }
                                  },
                                ),
                              ]
                          );
                        }
                        ),
                      ),



                      if (!events) const SizedBox(height: 30.0),

                      if (!events) Text(
                        'Акции ${place.name}:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),

                      if (!events) const SizedBox(height: 16.0),

                      if (!events && promosInThatPlace.promosList.isEmpty) Container(
                        decoration: const BoxDecoration(
                            color: AppColors.greyOnBackground
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                                'Это заведение пока не проводит никаких акций'
                            ),
                          ),
                        ),
                      ),

                      if (!events && promosInThatPlace.promosList.isNotEmpty) Column(
                        children: List.generate(promosInThatPlace.promosList.length, (index) {
                          return Column( // сюда можно вставить шаблон элемента
                              children: [

                                PromoCardWidget(
                                    promo: promosInThatPlace.promosList[index],
                                  onTap:  () async {

                                    final results = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PromoViewScreen(promoId: promosInThatPlace.promosList[index].id),
                                      ),
                                    );

                                    if (results != null) {
                                      setState(() {
                                        promosInThatPlace.promosList[index].inFav = results[0];
                                        promosInThatPlace.promosList[index].addedToFavouritesCount = results[1];
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
                                      if (promosInThatPlace.promosList[index].inFav!)
                                      {
                                        String resDel = await promosInThatPlace.promosList[index].deleteFromFav();
                                        // ---- Инициализируем счетчик -----
                                        int favCounter = promosInThatPlace.promosList[index].addedToFavouritesCount!;

                                        if (resDel == 'success'){
                                          // Если удаление успешное, обновляем 2 списка - текущий на экране, и общий загруженный из БД
                                          setState(() {
                                            // Обновляем текущий список
                                            promosInThatPlace.promosList[index].inFav = false;
                                            favCounter --;
                                            promosInThatPlace.promosList[index].addedToFavouritesCount = favCounter;
                                            // Обновляем общий список из БД
                                            //EventCustom.updateCurrentEventListFavInformation(eventsList[indexWithAddCountCorrection].id, favCounter, false);
                                            promosInThatPlace.promosList[index].updateCurrentListFavInformation();

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
                                        String res = await promosInThatPlace.promosList[index].addToFav();

                                        // ---- Инициализируем счетчик добавивших в избранное
                                        int favCounter = promosInThatPlace.promosList[index].addedToFavouritesCount!;

                                        if (res == 'success') {
                                          // --- Если добавилось успешно, так же обновляем текущий список и список из БД
                                          setState(() {
                                            // Обновляем текущий список
                                            promosInThatPlace.promosList[index].inFav = true;
                                            favCounter ++;
                                            promosInThatPlace.promosList[index].addedToFavouritesCount = favCounter;
                                            // Обновляем список из БД
                                            //EventCustom.updateCurrentEventListFavInformation(eventsList[indexWithAddCountCorrection].id, favCounter, true);
                                            promosInThatPlace.promosList[index].updateCurrentListFavInformation();

                                          });

                                          showSnackBar(context, 'Добавлено в избранные', Colors.green, 1);

                                        } else {
                                          // Если добавление прошло неудачно, отображаем всплывающее окно
                                          showSnackBar(context , res, AppColors.attentionRed, 1);
                                        }
                                      }
                                    }
                                  },
                                )

                              ]
                          );
                        }
                        ),
                      ),

                      const SizedBox(height: 30.0),
                      
                      if (currentPlaceUser.placeUserRole.controlLevel >= 90) GestureDetector(
                        onTap: navigateToManagersList,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            children: [
                              Expanded(child: Text('Управляющие заведением (${place.admins!.length + 1})', style: Theme.of(context).textTheme.titleMedium, softWrap: true,)),
                              const Icon(FontAwesomeIcons.chevronRight, color: AppColors.white, size: 20,)
                            ],
                          ),
                        ),
                      ),

                      /*if (currentPlaceUser.roleInPlace.controlLevel >= 90) Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0), // Отступы
                        decoration: BoxDecoration(
                          color: AppColors.greyOnBackground, // Цвет фона
                          borderRadius: BorderRadius.circular(10.0), // Скругление углов
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Управляющие местом:',
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                        Text(
                                          'Это пользователи, которые смогут управлять местом',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    )
                                ),
                                const SizedBox(width: 16.0),

                                // TODO - сделать скрытие кнопки редактирования места если нет доступа к редактированию
                                // --- Кнопка редактирования ----
                                IconButton(
                                  icon: Icon(
                                    Icons.add,
                                    color: Theme.of(context).colorScheme.background,
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Colors.green),
                                  ),
                                  onPressed: () async {
                                    navigateToManagersList();
                                  },
                                  // Действие при нажатии на кнопку редактирования
                                ),
                              ],
                            ),

                            const SizedBox(height: 20,),

                            if (creator.name != '') PlaceManagersElementListItem(
                              user: creator,
                              showButton: false,
                              onTapMethod: () async {

                              },
                            ),

                            if (admins.isNotEmpty) Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: admins.map((user) {
                                return Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: PlaceManagersElementListItem(
                                    user: user,
                                    showButton: true,
                                    onTapMethod: () async {
                                      navigateToEditManager(user);
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),*/
                      const SizedBox(height: 30.0),

                      if (
                      currentPlaceUser.placeUserRole.controlLevel == 100
                      ) CustomButton(
                          buttonText: 'Удалить заведение',
                          onTapMethod: () async {
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