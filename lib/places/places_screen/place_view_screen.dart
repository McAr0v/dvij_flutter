import 'dart:core';
import 'package:dvij_flutter/dates/date_mixin.dart';
import 'package:dvij_flutter/widgets_global/cards_widgets/card_widget_for_event_and_promo.dart';
import 'package:dvij_flutter/events/events_list_class.dart';
import 'package:dvij_flutter/places/place_admins_screens/place_admins_screen.dart';
import 'package:dvij_flutter/places/place_list_class.dart';
import 'package:dvij_flutter/places/places_elements/add_managers_widget.dart';
import 'package:dvij_flutter/widgets_global/images/image_for_view_screen.dart';
import 'package:dvij_flutter/widgets_global/schedule_widgets/schedule_regular_widget.dart';
import 'package:dvij_flutter/widgets_global/text_widgets/expandable_text.dart';
import 'package:dvij_flutter/widgets_global/social_widgets/social_buttons_widget.dart';
import 'package:dvij_flutter/promos/promos_list_class.dart';
import 'package:dvij_flutter/users/place_user_class.dart';
import 'package:dvij_flutter/users/place_users_roles.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import '../../promos/promotions/promo_view_page.dart';
import '../place_class.dart';
import '../../classes/user_class.dart';
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

  Place place = Place.emptyPlace;

  EventsList eventsInThatPlace = EventsList();
  PromoList promosInThatPlace = PromoList();

  DateTime currentDate = DateTime.now();

  bool loading = true;
  bool deleting = false;
  bool inFav = false;
  int favCounter = 0;

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
    } else {
      place = await place.getEntityByIdFromDb(widget.placeId);

    }

    // Подгружаем список администраторов
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

            // ---- Кнопка редактирования ---

            if (currentPlaceUser.placeUserRole.controlLevel >= 90) IconButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateOrEditPlaceScreen(placeInfo: place))
                  );
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

                      ImageForViewScreen(
                          imagePath: place.imageUrl,
                          favCounter: favCounter,
                          inFav: inFav,
                          onTap: () async {
                            addOrDeleteFromFav();
                          },
                          categoryName: place.category.name,
                          headline: place.name,
                          desc: '${place.city.name}, ${place.street}, ${place.house}',
                          openOrToday: place.nowIsOpen!,
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
                                headline: 'Менеджеры (${place.admins!.length + 1})',
                                desc: 'Ты можешь добавить менеджеров к этому заведению, чтобы они управляли им вместе с тобой. У каждого менеджера свой уровень доступа',
                              onTapMethod: (){
                                navigateToManagersList();
                              },
                            ),

                            if (currentPlaceUser.placeUserRole.controlLevel >= 90) const SizedBox(height: 16.0),

                            // ВИДЖЕТ ТЕЛЕФОНА И СОЦ СЕТЕЙ

                            SocialButtonsWidget(telegramUsername: place.telegram, instagramUsername: place.instagram, whatsappUsername: place.whatsapp, phoneNumber: place.phone,),

                            const SizedBox(height: 16.0),

                            // РАСКРЫВАЮЩЕЕСЯ ОПИСАНИЕ

                            if (place.desc != '') ExpandableText(text: place.desc),

                            const SizedBox(height: 30.0),

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

                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      const SizedBox(height: 10,)
                    ],
                  ),
                ),

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
                return CardWidgetForEventAndPromo(
                  event: eventsList.eventsList[index],
                  onTap: () async {

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
                  onFavoriteIconPressed: () async {

                    if (UserCustom.currentUser?.uid == '' || UserCustom.currentUser?.uid == null)
                    {
                      _showSnackBar('Чтобы добавлять в избранное, нужно зарегистрироваться!', AppColors.attentionRed, 2);
                    } else {

                      // --- Если уже в избранном ----
                      if (eventsList.eventsList[index].inFav == true)
                      {
                        // --- Удаляем из избранных ---
                        String resDel = await eventsList.eventsList[index].deleteFromFav();
                        // ---- Инициализируем счетчик -----
                        int favCounter = eventsList.eventsList[index].addedToFavouritesCount;

                        if (resDel == 'success'){
                          // Если удаление успешное, обновляем 2 списка - текущий на экране, и общий загруженный из БД
                          setState(() {
                            // Обновляем текущий список
                            eventsList.eventsList[index].inFav = false;
                            favCounter --;
                            eventsList.eventsList[index].addedToFavouritesCount = favCounter;
                            // Обновляем общий список из БД
                            eventsList.eventsList[index].updateCurrentListFavInformation();
                          });
                          _showSnackBar('Удалено из избранных', AppColors.attentionRed, 1);
                        } else {
                          // Если удаление из избранных не прошло, показываем сообщение
                          _showSnackBar(resDel, AppColors.attentionRed, 1);
                        }
                      }
                      else {
                        // --- Если заведение не в избранном ----

                        // -- Добавляем в избранное ----
                        String res = await eventsList.eventsList[index].addToFav();

                        // ---- Инициализируем счетчик добавивших в избранное
                        int favCounter = eventsList.eventsList[index].addedToFavouritesCount;

                        if (res == 'success') {
                          // --- Если добавилось успешно, так же обновляем текущий список и список из БД
                          setState(() {
                            // Обновляем текущий список
                            eventsList.eventsList[index].inFav = true;
                            favCounter ++;
                            eventsList.eventsList[index].addedToFavouritesCount = favCounter;
                            // Обновляем список из БД
                            eventsList.eventsList[index].updateCurrentListFavInformation();
                          });

                          _showSnackBar('Добавлено в избранные', Colors.green, 1);

                        } else {
                          // Если добавление прошло неудачно, отображаем всплывающее окно
                          _showSnackBar(res, AppColors.attentionRed, 1);
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

  // ВИДЖЕТ КАРУСЕЛИ АКЦИЙ

  SliverToBoxAdapter _promosHorizontalScroll({required String title, required String desc, required PromoList promosList}) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
                )
              ],
            ),
          ),
          SizedBox(
            height: 450,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: promosList.promosList.length,
              itemBuilder: (context, index) {
                return CardWidgetForEventAndPromo(
                  promo: promosList.promosList[index],
                  onTap: () async {
                    final results = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PromoViewScreen(promoId: promosList.promosList[index].id),
                      ),
                    );

                    if (results != null) {
                      setState(() {
                        promosList.promosList[index].inFav = results[0];
                        promosList.promosList[index].addedToFavouritesCount = results[1];
                      });
                    }
                  },
                  onFavoriteIconPressed: () async {

                    if (UserCustom.currentUser?.uid == '' || UserCustom.currentUser?.uid == null)
                    {
                      showSnackBar(context, 'Чтобы добавлять в избранное, нужно зарегистрироваться!', AppColors.attentionRed, 2);
                    } else {

                      // --- Если уже в избранном ----
                      if (promosList.promosList[index].inFav == true)
                      {
                        // --- Удаляем из избранных ---
                        String resDel = await promosList.promosList[index].deleteFromFav();
                        // ---- Инициализируем счетчик -----
                        int favCounter = promosList.promosList[index].addedToFavouritesCount;

                        if (resDel == 'success'){
                          // Если удаление успешное, обновляем 2 списка - текущий на экране, и общий загруженный из БД
                          setState(() {
                            // Обновляем текущий список
                            promosList.promosList[index].inFav = false;
                            favCounter --;
                            promosList.promosList[index].addedToFavouritesCount = favCounter;
                            // Обновляем общий список из БД
                            promosList.promosList[index].updateCurrentListFavInformation();

                          });
                          _showSnackBar('Удалено из избранных', AppColors.attentionRed, 1);
                        } else {
                          // Если удаление из избранных не прошло, показываем сообщение
                          _showSnackBar(resDel, AppColors.attentionRed, 1);
                        }
                      }
                      else {

                        // -- Добавляем в избранное ----
                        String res = await promosList.promosList[index].addToFav();

                        // ---- Инициализируем счетчик добавивших в избранное
                        int favCounter = promosList.promosList[index].addedToFavouritesCount;

                        if (res == 'success') {
                          // --- Если добавилось успешно, так же обновляем текущий список и список из БД
                          setState(() {
                            // Обновляем текущий список
                            promosList.promosList[index].inFav = true;
                            favCounter ++;
                            promosList.promosList[index].addedToFavouritesCount = favCounter;
                            // Обновляем список из БД
                            promosList.promosList[index].updateCurrentListFavInformation();
                          });

                          _showSnackBar('Добавлено в избранные', Colors.green, 1);

                        } else {
                          // Если добавление прошло неудачно, отображаем всплывающее окно
                          _showSnackBar(res, AppColors.attentionRed, 1);
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

  void deletePlace() async {
    bool? confirmed = await exitDialog(context, "Ты правда хочешь удалить заведение? Ты не сможешь восстановить данные" , 'Да', 'Нет', 'Удаление заведения');

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
        PlaceList placeList = PlaceList();
        place = result;
        placeList.updateCurrentListAdminsInformation(place.id, place.admins!);
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
      if (inFav) {
        String resDel = await place.deleteFromFav();
        if (resDel == 'success'){
          setState(() {
            inFav = false;
            favCounter --;
            place.inFav = inFav;
            place.addedToFavouritesCount = favCounter;
            place.updateCurrentListFavInformation();
          });
          _showSnackBar('Удалено из избранных', AppColors.attentionRed, 1);
        } else {
          _showSnackBar(resDel, AppColors.attentionRed, 1);
        }
      } else {
        String res = await place.addToFav();
        if (res == 'success') {

          setState(() {
            inFav = true;
            favCounter ++;
            place.inFav = inFav;
            place.addedToFavouritesCount = favCounter;
            place.updateCurrentListFavInformation();
          });

          _showSnackBar('Добавлено в избранные', Colors.green, 1);

        } else {

          _showSnackBar(res, AppColors.attentionRed, 1);

        }
      }
    }
  }
}