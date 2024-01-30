import 'package:dvij_flutter/elements/text_and_icons_widgets/headline_and_desc.dart';
import 'package:dvij_flutter/elements/places_elements/now_is_work_widget.dart';
import 'package:dvij_flutter/elements/places_elements/place_work_time_element.dart';
import 'package:dvij_flutter/elements/social_elements/social_buttons_widget.dart';
import 'package:dvij_flutter/go_to_url/openUrlPage.dart';
import 'package:dvij_flutter/methods/date_functions.dart';
import 'package:dvij_flutter/screens/places/create_or_edit_place_screen.dart';
import 'package:dvij_flutter/screens/profile/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:dvij_flutter/elements/custom_snack_bar.dart';
import 'package:dvij_flutter/elements/pop_up_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../classes/city_class.dart';
import '../../classes/gender_class.dart';
import '../../classes/place_category_class.dart';
import '../../classes/place_class.dart';
import '../../classes/place_role_class.dart';
import '../../classes/role_in_app.dart';
import '../../classes/user_class.dart';
import '../../elements/exit_dialog/exit_dialog.dart';
import '../../elements/text_and_icons_widgets/for_cards_small_widget_with_icon_and_text.dart';
import '../../elements/loading_screen.dart';
import '../../elements/places_elements/place_managers_element_list_item.dart';
import '../../methods/days_functions.dart';
import '../place_admins_screens/place_manager_add_screen.dart';


// --- ЭКРАН ЗАЛОГИНЕВШЕГОСЯ ПОЛЬЗОВАТЕЛЯ -----

class PlaceViewScreen extends StatefulWidget {
  final String placeId;
  const PlaceViewScreen({Key? key, required this.placeId}) : super(key: key);

  @override
  _PlaceViewScreenState createState() => _PlaceViewScreenState();
}

class _PlaceViewScreenState extends State<PlaceViewScreen> {

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
  String category = '';

  DateTime currentDate = DateTime.now();
  bool isOpen = false;

  // --- Переключатель показа экрана загрузки -----

  bool loading = true;
  bool deleting = false;
  String inFav = 'false';
  int favCounter = 0;

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

      place = await Place.getPlaceById(widget.placeId);

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

      city = City.getCityName(place.city);
      category = PlaceCategory.getPlaceCategoryName(place.category);
      inFav = place.inFav!;
      favCounter = int.parse(place.addedToFavouritesCount!);
      isOpen = nowIsOpenPlace(place);


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
  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

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

                                showSnackBar('Чтобы добавлять в избранное, нужно зарегистрироваться!', AppColors.attentionRed, 2);

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

                                  showSnackBar('Удалено из избранных', AppColors.attentionRed, 1);
                                } else {

                                  showSnackBar(resDel, AppColors.attentionRed, 1);
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

                                  showSnackBar('Добавлено в избранные', Colors.green, 1);

                                } else {

                                  showSnackBar(res, AppColors.attentionRed, 1);

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
                            text: category,
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
                      const SizedBox(height: 16.0),

                      Text(
                          'Мероприятия ${place.name}:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),

                      const SizedBox(height: 30.0),

                      Text(
                        'Акции ${place.name}:',
                        style: Theme.of(context).textTheme.titleMedium,
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

                                showSnackBar('Место успешно удалено', Colors.green, 2);
                                navigateToPlaces();

                                setState(() {
                                  deleting = false;
                                });
                              } else {
                                showSnackBar('Место не было удалено по ошибке: $delete', AppColors.attentionRed, 2);
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