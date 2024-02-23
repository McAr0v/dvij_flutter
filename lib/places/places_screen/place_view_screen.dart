import 'dart:core';
import 'package:dvij_flutter/dates/date_mixin.dart';
import 'package:dvij_flutter/events/events_list_class.dart';
import 'package:dvij_flutter/places/place_admins_screens/place_admins_screen.dart';
import 'package:dvij_flutter/places/place_list_class.dart';
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

    place = place.getEntityFromFeedList(widget.placeId);

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
        ),

        body: CustomScrollView(
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
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      children: [
                        Row(
                          children: [

                            // БЛОК Название/адрес

                            Expanded(
                              child: HeadlineAndDesc(
                                headline: place.name,
                                description: '${place.city.name}, ${place.street}, ${place.house}',
                                textSize: TextSizeEnum.headlineMedium,
                                descSize: TextSizeEnum.bodySmall,
                                descColor: AppColors.white,
                              ),
                            ),

                            const SizedBox(width: 16.0),

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
                            ),
                          ],
                        ),

                        // ---- Остальные данные пользователя ----

                        const SizedBox(height: 5.0),

                        TextOnBoolResultWidget(isTrue: place.nowIsOpen!, trueText: 'Сейчас открыто', falseText: 'Сейчас закрыто'),

                        const SizedBox(height: 16.0),

                        SocialButtonsWidget(telegramUsername: place.telegram, instagramUsername: place.instagram, whatsappUsername: place.whatsapp, phoneNumber: place.phone,),

                        const SizedBox(height: 16.0),

                        if (place.desc != '') HeadlineAndDesc(headline: place.desc, description: 'Описание места', padding: 5),

                        const SizedBox(height: 16.0),

                        ScheduleRegularAndIrregularWidget(
                          dateTypeEnum: DateTypeEnum.regular,
                          regularTimes: place.openingHours,
                          headline: 'Режим работы',
                          desc: 'Посмотри, когда ${place.name} открыто и готово к приему гостей)',
                          isPlace: true,
                        ),

                        const SizedBox(height: 16.0),

                        if (place.createDate != DateTime(2100)) HeadlineAndDesc(headline: DateMixin.getHumanDateFromDateTime(place.createDate), description: 'Создано в движе', ),

                        const SizedBox(height: 30.0),

                      ],
                    ),
                  )
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 200,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    Container(
                      width: 200.0,
                      color: Colors.red,
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      child: Center(child: Text('Horizontal Item 1')),
                    ),
                    Container(
                      width: 200.0,
                      color: Colors.blue,
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      child: Center(child: Text('Horizontal Item 2')),
                    ),
                    Container(
                      width: 200.0,
                      color: Colors.green,
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      child: Center(child: Text('Horizontal Item 3')),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  ListTile(title: Text('Item 1')),
                  ListTile(title: Text('Item 2')),
                  ListTile(title: Text('Item 3')),
                  ListTile(title: Text('Item 4')),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 200,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    Container(
                      width: 200.0,
                      color: Colors.red,
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      child: Center(child: Text('Horizontal Item 1')),
                    ),
                    Container(
                      width: 200.0,
                      color: Colors.blue,
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      child: Center(child: Text('Horizontal Item 2')),
                    ),
                    Container(
                      width: 200.0,
                      color: Colors.green,
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      child: Center(child: Text('Horizontal Item 3')),
                    ),
                  ],
                ),
              ),
            ),
            SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200.0,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  return Container(
                    alignment: Alignment.center,
                    color: Colors.teal[100 * (index % 9)],
                    child: Text('Grid Item $index'),
                  );
                },
                childCount: 20,
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