import 'package:dvij_flutter/events/event_class.dart';
import 'package:dvij_flutter/events/events_list_class.dart';
import 'package:dvij_flutter/promos/promo_class.dart';
import 'package:dvij_flutter/elements/text_and_icons_widgets/headline_and_desc.dart';
import 'package:dvij_flutter/elements/social_elements/social_buttons_widget.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import '../../cities/city_class.dart';
import '../../promos/promos_elements/promo_card_widget.dart';
import '../../promos/promotions/promo_view_page.dart';
import '../place_category_class.dart';
import '../place_class.dart';
import '../place_role_class.dart';
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

  UserCustom userInfo = UserCustom.empty('', '');

  ////////
  List<UserCustom> users = [];
  List<PlaceRole> _roles = [];
  UserCustom creator = UserCustom.empty('', '');
  PlaceRole creatorPlaceRole = PlaceRole(name: '', id: '', desc: '', controlLevel: '');
  PlaceRole currentUserPlaceRole = PlaceRole(name: '', id: '', desc: '', controlLevel: '');

  Place place = Place.empty();
  String city = '';
  PlaceCategory category = PlaceCategory.empty;

  EventsList eventsInThatPlace = EventsList();
  List<PromoCustom> promosInThatPlace = [];

  DateTime currentDate = DateTime.now();
  bool isOpen = false;

  // --- Переключатель показа экрана загрузки -----

  bool loading = true;
  bool deleting = false;
  String inFav = 'false';
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
      ///////
      if (PlaceRole.currentPlaceRoleList.isNotEmpty)
      {
        _roles = PlaceRole.currentPlaceRoleList;
      }

      //place = await Place.getPlaceById(widget.placeId);

      place = await Place.getPlaceFromList(widget.placeId);

      if (place.name != ''){

        if (UserCustom.currentUser != null){
          userInfo = UserCustom.currentUser!;
          currentUserPlaceRole = await UserCustom.getPlaceRoleInUserById(widget.placeId, userInfo.uid);

          creator = (await UserCustom.readUserData(place.creatorId))!;
          //users.add(creator);
          creatorPlaceRole = PlaceRole.getPlaceRoleFromListById('-NngrYovmKAw_cp0pYfJ');

          creator.roleInPlace = creatorPlaceRole.id;

          if (creator.uid == userInfo.uid) {
            currentUserPlaceRole = creatorPlaceRole;
          }

          if (int.parse(currentUserPlaceRole.controlLevel) >= 90){
            users = await UserCustom.getPlaceAdminsUsers(widget.placeId);
          }

        }
        else {
          userInfo = UserCustom.empty('', '');
        }
      }

      city = City.getCityByIdFromList(place.city).name;
      category = category.getEntityByIdFromList(place.category);
      inFav = place.inFav!;
      favCounter = int.parse(place.addedToFavouritesCount!);
      isOpen = nowIsOpenPlace(place);

      if (place.eventsList != null && place.eventsList != ''){

        //eventsInThatPlace = await EventCustom.getEventsList(place.eventsList!);
        eventsInThatPlace = await eventsInThatPlace.getEntitiesFromStringList(place.eventsList!);

      }

      if (place.promosList != null && place.promosList != ''){

        promosInThatPlace = await PromoCustom.getPromosList(place.promosList!);

      }


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

  void navigateToAddManager() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlaceManagerAddScreen(placeId: widget.placeId, isEdit: false, placeCreator: place.creatorId))
    );

    // Проверяем результат и вызываем функцию fetchAndSetData
    if (result != null) {
      fetchAndSetData();
    }

  }

  void navigateToEditManager(UserCustom user) async {
    final result = await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceManagerAddScreen(
          placeId: widget.placeId,
          isEdit: true,
          placeRole: PlaceRole.getPlaceRoleFromListById(user.roleInPlace!),
          user: user,
          placeCreator: place.creatorId,
        ),
      ),
    );

    // Проверяем результат и вызываем функцию fetchAndSetData
    if (result != null) {
      fetchAndSetData();
    }

  }



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

                                String resDel = await Place.deletePlaceFromFav(place.id);

                                if (resDel == 'success'){
                                  setState(() {
                                    inFav = 'false';
                                    favCounter --;
                                    Place.updateCurrentPlaceListFavInformation(place.id, favCounter.toString(), inFav);
                                  });

                                  showSnackBar(context, 'Удалено из избранных', AppColors.attentionRed, 1);
                                } else {

                                  showSnackBar(context, resDel, AppColors.attentionRed, 1);
                                }



                              }
                              else {
                                String res = await Place.addPlaceToFav(place.id);
                                if (res == 'success') {

                                  setState(() {
                                    inFav = 'true';
                                    favCounter ++;
                                    Place.updateCurrentPlaceListFavInformation(place.id, favCounter.toString(), inFav);
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
                                  '$city, ${place.street}, ${place.house}',
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
                                  MaterialPageRoute(builder: (context) => CreateOrEditPlaceScreen(placeInfo: place))
                              );
                            },
                            // Действие при нажатии на кнопку редактирования
                          ),
                        ],
                      ),



                      // ---- Остальные данные пользователя ----



                      const SizedBox(height: 5.0),

                      NowIsWorkWidget(isTrue: isOpen),

                      const SizedBox(height: 16.0),

                      SocialButtonsWidget(telegramUsername: place.telegram, instagramUsername: place.instagram, whatsappUsername: place.whatsapp, phoneNumber: place.phone,),

                      const SizedBox(height: 16.0),

                      if (place.desc != '') HeadlineAndDesc(headline: place.desc, description: 'Описание места'),

                      const SizedBox(height: 16.0),

                      PlaceWorkTimeCard(
                          place: place,
                      ),

                      const SizedBox(height: 16.0),

                      if (place.createDate != '') HeadlineAndDesc(headline: place.createDate, description: 'Создано в движе', ),

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
                        decoration: BoxDecoration(
                          color: AppColors.greyOnBackground
                        ),
                        child: Padding(
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

                      if (!events && promosInThatPlace.isEmpty) Container(
                        decoration: BoxDecoration(
                            color: AppColors.greyOnBackground
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                                'Это заведение пока не проводит никаких акций'
                            ),
                          ),
                        ),
                      ),

                      if (!events && promosInThatPlace.isNotEmpty) Column(
                        children: List.generate(promosInThatPlace.length, (index) {
                          return Column( // сюда можно вставить шаблон элемента
                              children: [

                                PromoCardWidget(
                                    promo: promosInThatPlace[index],
                                  onTap:  () async {

                                    final results = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PromoViewScreen(promoId: promosInThatPlace[index].id),
                                      ),
                                    );

                                    if (results != null) {
                                      setState(() {
                                        promosInThatPlace[index].inFav = results[0].toString();
                                        promosInThatPlace[index].addedToFavouritesCount = results[1].toString();
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
                                      if (promosInThatPlace[index].inFav == 'true')
                                      {
                                        // --- Удаляем из избранных ---
                                        String resDel = await PromoCustom.deletePromoFromFav(promosInThatPlace[index].id);
                                        // ---- Инициализируем счетчик -----
                                        int favCounter = int.parse(promosInThatPlace[index].addedToFavouritesCount!);

                                        if (resDel == 'success'){
                                          // Если удаление успешное, обновляем 2 списка - текущий на экране, и общий загруженный из БД
                                          setState(() {
                                            // Обновляем текущий список
                                            promosInThatPlace[index].inFav = 'false';
                                            favCounter --;
                                            promosInThatPlace[index].addedToFavouritesCount = favCounter.toString();
                                            // Обновляем общий список из БД
                                            PromoCustom.updateCurrentPromoListFavInformation(promosInThatPlace[index].id, favCounter.toString(), 'false');

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
                                        String res = await PromoCustom.addPromoToFav(promosInThatPlace[index].id);

                                        // ---- Инициализируем счетчик добавивших в избранное
                                        int favCounter = int.parse(promosInThatPlace[index].addedToFavouritesCount!);

                                        if (res == 'success') {
                                          // --- Если добавилось успешно, так же обновляем текущий список и список из БД
                                          setState(() {
                                            // Обновляем текущий список
                                            promosInThatPlace[index].inFav = 'true';
                                            favCounter ++;
                                            promosInThatPlace[index].addedToFavouritesCount = favCounter.toString();
                                            // Обновляем список из БД
                                            PromoCustom.updateCurrentPromoListFavInformation(promosInThatPlace[index].id, favCounter.toString(), 'true');

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

                      if (currentUserPlaceRole.controlLevel != '' && int.parse(currentUserPlaceRole.controlLevel) >= 90) Container(
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
                                    navigateToAddManager();
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

                            if (users.isNotEmpty) Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: users.map((user) {
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
                      ),
                      const SizedBox(height: 30.0),

                      if (
                      currentUserPlaceRole.controlLevel != ''
                          && int.parse(currentUserPlaceRole.controlLevel) == 100
                      ) CustomButton(
                          buttonText: 'Удалить заведение',
                          onTapMethod: () async {
                            bool? confirmed = await exitDialog(context, "Ты правда хочешь удалить заведение? Ты не сможешь восстановить данные" , 'Да', 'Нет', 'Удаление заведения');

                            if (confirmed != null && confirmed){

                              setState(() {
                                deleting = true;
                              });

                              String delete = await Place.deletePlace(widget.placeId, users, place.creatorId);

                              if (delete == 'success'){

                                Place.deletePlaceFormCurrentPlaceLists(widget.placeId);

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