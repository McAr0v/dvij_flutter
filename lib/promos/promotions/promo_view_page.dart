import 'package:dvij_flutter/dates/date_mixin.dart';
import 'package:dvij_flutter/events/event_class.dart';
import 'package:dvij_flutter/elements/text_and_icons_widgets/headline_and_desc.dart';
import 'package:dvij_flutter/elements/shedule_elements/shedule_once_and_long_widget.dart';
import 'package:dvij_flutter/elements/social_elements/social_buttons_widget.dart';
import 'package:dvij_flutter/elements/user_element_widget.dart';
import 'package:dvij_flutter/promos/promo_class.dart';
import 'package:dvij_flutter/promos/promotions/create_or_edit_promo_screen.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import '../../cities/city_class.dart';
import '../../events/events_elements/today_widget.dart';
import '../../places/places_elements/place_widget_in_view_screen_in_event_and_promo.dart';
import '../../places/places_screen/place_view_screen.dart';
import '../../dates/date_type_enum.dart';
import '../../places/place_class.dart';
import '../../places/place_role_class.dart';
import '../../classes/priceTypeOptions.dart';
import '../../classes/user_class.dart';
import '../../elements/exit_dialog/exit_dialog.dart';
import '../../elements/text_and_icons_widgets/for_cards_small_widget_with_icon_and_text.dart';
import '../../elements/loading_screen.dart';
import '../../elements/shedule_elements/schedule_regular_and_irregular_widget.dart';
import '../../elements/snack_bar.dart';


// --- ЭКРАН ЗАЛОГИНЕВШЕГОСЯ ПОЛЬЗОВАТЕЛЯ -----

class PromoViewScreen extends StatefulWidget {
  final String promoId;
  const PromoViewScreen({Key? key, required this.promoId}) : super(key: key);

  @override
  PromoViewScreenState createState() => PromoViewScreenState();
}

class PromoViewScreenState extends State<PromoViewScreen> {

  // ---- Инициализируем пустые переменные ----

  bool today = false;

  UserCustom creator = UserCustom.empty('', '');
  PlaceRole currentUserPlaceRole = PlaceRole(name: '', id: '', desc: '', controlLevel: '');

  PromoCustom promo = PromoCustom.emptyPromo;

  DateTime currentDate = DateTime.now();

  Place place = Place.emptyPlace;

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

      promo = promo.getEntityFromFeedList(widget.promoId);

      if (promo.placeId != '') {

        // TODO Считать заведение со списка, если список заведений прогружен
        // Считываем информацию о заведении
        place = await place.getEntityByIdFromDb(promo.placeId);

      }

      // Выдаем права на редактирование мероприятия
      // Если наш пользователь создатель
      if (UserCustom.currentUser != null && UserCustom.currentUser!.uid == promo.creatorId){

        // Отдаем права создателя
        currentUserPlaceRole = PlaceRole.getPlaceRoleFromListById('-NngrYovmKAw_cp0pYfJ');

      } else if (UserCustom.currentUser != null && UserCustom.currentUser!.uid != promo.creatorId){
        if (promo.placeId != '') {
          // Если не создатель, то пытаемся понять, может он админ заведения
          currentUserPlaceRole = await UserCustom.getPlaceRoleInUserById(place.id, UserCustom.currentUser!.uid);
        }

      }

      // TODO - Сделать проверку - если создатель это текущий пользователь, то подгрузить его данные
      creator = await UserCustom.getUserById(promo.creatorId);
      inFav = promo.inFav!;
      favCounter = promo.addedToFavouritesCount!;

      // ---- Убираем экран загрузки -----
      setState(() {
        loading = false;
      });
    } catch (e) {
      // TODO Сделать обработку ошибок, если не получилось считать данные
    }
  }

  // ---- Функция перехода в профиль ----
  void navigateToPromos() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/Promotions',
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text(promo.headline != '' ? promo.headline : 'Загрузка...'),
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
            else if (deleting) const LoadingScreen(loadingText: 'Подожди, удаляем акцию',)
            else ListView(

                children: [
                  if (promo.imageUrl != '') // Проверяем, есть ли ссылка на аватар
                  // TODO - Сделать более проработанную проверку аватарки

                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        // Изображение
                        Container(
                          height: MediaQuery.of(context).size.width * 0.7, // Ширина экрана
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(promo.imageUrl), // Используйте ссылку на изображение из вашего Place
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

                                  String resDel = await promo.deleteFromFav();

                                  if (resDel == 'success'){
                                    setState(() {
                                      inFav = false;
                                      favCounter --;
                                      promo.inFav = inFav;
                                      promo.addedToFavouritesCount = favCounter;
                                      promo.updateCurrentListFavInformation();
                                      //EventCustom.updateCurrentEventListFavInformation(event.id, favCounter, inFav);
                                    });

                                    showSnackBar(context, 'Удалено из избранных', AppColors.attentionRed, 1);

                                  } else {

                                    showSnackBar(context, resDel, AppColors.attentionRed, 1);
                                  }



                                }
                                else {
                                  String res = await promo.addToFav();

                                  if (res == 'success') {

                                    setState(() {
                                      inFav = true;
                                      favCounter ++;
                                      promo.inFav = inFav;
                                      promo.addedToFavouritesCount = favCounter;
                                      promo.updateCurrentListFavInformation();
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
                              text: promo.category.name,
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

                        if (promo.headline != '') Row(
                          children: [
                            Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      promo.headline,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    if (place.id != '') Text(
                                      '${place.name}, ${place.city.name}, ${place.street}, ${place.house}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    if (place.id == '') Text(
                                      '${promo.city.name}, ${promo.street}, ${promo.house}',
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
                                    MaterialPageRoute(builder: (context) => CreateOrEditPromoScreen(promoInfo: promo,))
                                );
                              },
                              // Действие при нажатии на кнопку редактирования
                            ),
                          ],
                        ),

                        // ---- Остальные данные пользователя ----

                        // TODO Проверить вывод времени в функции определения сегодня
                        if (promo.today!) const SizedBox(height: 5.0),

                        // ПЕРЕДЕЛАТЬ ПОД СЕГОДНЯ
                        if (promo.today!) TodayWidget(isTrue: promo.today!),

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
                                    Text('Контакты для справок', style: Theme.of(context).textTheme.titleMedium,),
                                    Text('По контактам ниже вы можете связаться с организатором', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.greyText),),


                                  ],
                                ),
                              ),

                              //const SizedBox(height: 16.0),

                              SocialButtonsWidget(telegramUsername: promo.telegram, instagramUsername: promo.instagram, whatsappUsername: promo.whatsapp, phoneNumber: promo.phone,),
                              const SizedBox(height: 20.0),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16.0),

                        if (promo.desc != '') HeadlineAndDesc(headline: promo.desc, description: 'Описание акции'),

                        const SizedBox(height: 16.0),

                        if (promo.dateType == DateTypeEnum.once) ScheduleOnceAndLongWidget(
                            dateHeadline: 'Дата проведения',
                            dateDesc: 'Акция проводится один раз',
                            dateTypeEnum: promo.dateType,
                            onceDate: promo.onceDay
                        ),

                        if (promo.dateType == DateTypeEnum.long) ScheduleOnceAndLongWidget(
                          dateHeadline: 'Расписание',
                          dateDesc: 'Акция проводится каждый день в течении указанного периода',
                          dateTypeEnum: promo.dateType,
                          longDates: promo.longDays,
                        ),



                        if (promo.dateType == DateTypeEnum.regular) ScheduleRegularAndIrregularWidget(
                          dateTypeEnum: promo.dateType,
                          regularTimes: promo.regularDays,
                          headline: 'Расписание',
                          desc: 'Акция проводится каждую неделю в определенные дни',
                        ),

                        if (promo.dateType == DateTypeEnum.irregular) ScheduleRegularAndIrregularWidget(
                          dateTypeEnum: promo.dateType,
                          irregularDays: promo.irregularDays,
                          headline: 'Расписание',
                          desc: 'Акция проводится в определенные дни',
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

                                    if (promo.street != '' && place.id == '') HeadlineAndDesc(
                                        headline: '${promo.city.name}, ${promo.street} ${promo.house} ',
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
                                  'Создатель акции',
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


                        if (promo.createDate != DateTime(2100) && int.parse(currentUserPlaceRole.controlLevel) >= 90) const SizedBox(height: 30.0),

                        if (promo.createDate != DateTime(2100) && int.parse(currentUserPlaceRole.controlLevel) >= 90) HeadlineAndDesc(headline: DateMixin.getHumanDateFromDateTime(promo.createDate), description: 'Создано в движе', ),

                        const SizedBox(height: 30.0),

                        if (
                        currentUserPlaceRole.controlLevel != ''
                            && int.parse(currentUserPlaceRole.controlLevel) >= 90
                        ) CustomButton(
                          buttonText: 'Удалить акцию',
                          onTapMethod: () async {
                            bool? confirmed = await exitDialog(context, "Ты правда хочешь удалить акцию? Ты не сможешь восстановить данные" , 'Да', 'Нет', 'Удаление акции');

                            if (confirmed != null && confirmed){

                              setState(() {
                                deleting = true;
                              });

                              String delete = await promo.deleteFromDb();

                              if (delete == 'success'){

                                promo.deleteEntityFromCurrentEntityLists();
                                //EventCustom.deleteEventFromCurrentEventLists(widget.eventId);
                                //Place.deletePlaceFormCurrentPlaceLists(widget.eventId);

                                showSnackBar(context, 'Акция успешно удалена', Colors.green, 2);
                                navigateToPromos();

                                setState(() {
                                  deleting = false;
                                });
                              } else {
                                showSnackBar(context, 'Акция не была удалена по ошибке: $delete', AppColors.attentionRed, 2);
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