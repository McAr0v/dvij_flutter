import 'package:dvij_flutter/promos/promos_list_class.dart';
import 'package:dvij_flutter/promos/promos_list_manager.dart';
import 'package:dvij_flutter/promos/promo_class.dart';
import 'package:dvij_flutter/promos/promotions/create_or_edit_promo_screen.dart';
import 'package:dvij_flutter/users/place_users_roles.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../places/place_list_manager.dart';
import '../../places/place_class.dart';
import '../../current_user/user_class.dart';
import '../../elements/exit_dialog/exit_dialog.dart';
import '../../widgets_global/images/image_in_view_screen_widget.dart';
import '../../widgets_global/place_or_location_widgets/place_or_location_widget.dart';
import '../../widgets_global/schedule_widgets/schedule_widget.dart';
import '../../widgets_global/social_widgets/callback_widget.dart';
import '../../widgets_global/text_widgets/expandable_text.dart';
import '../../elements/loading_screen.dart';
import '../../elements/snack_bar.dart';
import '../../users/place_user_class.dart';
import '../../widgets_global/users_widgets/creator_widget.dart';


// --- ЭКРАН ЗАЛОГИНЕВШЕГОСЯ ПОЛЬЗОВАТЕЛЯ -----

class PromoViewScreen extends StatefulWidget {
  final String promoId;
  const PromoViewScreen({Key? key, required this.promoId}) : super(key: key);

  @override
  PromoViewScreenState createState() => PromoViewScreenState();
}

class PromoViewScreenState extends State<PromoViewScreen> {

  // ---- Инициализируем пустые переменные ----

  UserCustom creator = UserCustom.empty();

  Place place = Place.empty();
  PlaceUser currentPlaceUser = PlaceUser();
  PlaceUserRole currentUserPlaceRole = PlaceUserRole();

  PromoCustom promo = PromoCustom.emptyPromo;

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
    setState(() {
      loading = true;
    });

    if (PromoListsManager.currentFeedPromosList.promosList.isNotEmpty){
      promo = promo.getEntityFromFeedList(widget.promoId);
    }

    if (promo.id.isEmpty) {
      promo = await promo.getEntityByIdFromDb(widget.promoId);
    }

    if (promo.placeId != '') {

      if (PlaceListManager.currentFeedPlacesList.placeList.isNotEmpty){
        place = place.getEntityFromFeedList(promo.placeId);
      }

      if (place.id.isEmpty) {
        place = await place.getEntityByIdFromDb(promo.placeId);
      }

    }

    if (UserCustom.currentUser != null){
      currentPlaceUser = currentPlaceUser.generatePlaceUserFromUserCustom(UserCustom.currentUser!);
    }

    // Выдаем права на редактирование акции
    // Если наш пользователь создатель
    if (UserCustom.currentUser != null && UserCustom.currentUser!.uid == promo.creatorId){

      // Отдаем права создателя
      currentUserPlaceRole = currentUserPlaceRole.getPlaceUserRole(PlaceUserRoleEnum.creator);
      currentPlaceUser.placeUserRole = currentUserPlaceRole;
      // Ставим нас как создателя
      creator = UserCustom.currentUser!;

    } else if (UserCustom.currentUser != null && UserCustom.currentUser!.uid != promo.creatorId){

      // Если создатель не я
      // Читаем нашу роль

      currentPlaceUser.placeUserRole = UserCustom.currentUser!.getPlaceRoleFromMyPlaces(promo.placeId);

      // Грузим создателя из БД
      creator = await creator.getUserByEmailOrId(uid: promo.creatorId);

    } else {
      creator = await creator.getUserByEmailOrId(uid: promo.creatorId);
    }

    // ---- Убираем экран загрузки -----
    setState(() {
      loading = false;
    });
  }

  // ---- Функция перехода в профиль ----
  void _navigateToPromosAfterDelete() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/Promotions',
          (route) => false,
    );
  }

  void _navigateToPromos() {
    // Возвращаем данные о состоянии избранного на экран ленты
    // На случай, если мы добавляли/убирали из избранного
    List<dynamic> result = [true];
    Navigator.of(context).pop(result);
  }

  void _showSnackBar(String text, Color color, int time){
    showSnackBar(context, text, color, time);
  }

  Future<void> deletePromo() async {


    bool? confirmed = await exitDialog(context, "Ты правда хочешь удалить мероприятие? Ты не сможешь восстановить данные" , 'Да', 'Нет', 'Удаление мероприятия');

    if (confirmed != null && confirmed){
      setState(() {
        deleting = true;
      });

      String delete = await promo.deleteFromDb();

      if (delete == 'success'){

        promo.deleteEntityFromCurrentEntityLists();

        _showSnackBar('Мероприятие успешно удалено', Colors.green, 2);

        _navigateToPromosAfterDelete();

        setState(() {
          deleting = false;
        });
      } else {
        _showSnackBar('Акция не была удалена по ошибке: $delete', AppColors.attentionRed, 2);
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
          title: Text(promo.headline.isNotEmpty ? promo.headline : 'Загрузка...'),
          leading: IconButton(
            icon: const Icon(FontAwesomeIcons.chevronLeft, size: 18,),
            onPressed: () {
              _navigateToPromos();
            },
          ),
          actions: [

            // ---- Кнопка редактирования ---

            if (currentPlaceUser.placeUserRole.controlLevel >= 90) IconButton(
                onPressed: () async {

                  await goToPromoEditScreen();

                },
                icon: const Icon(Icons.edit)
            ),

            // ---- Кнопка удаления ---

            if (currentPlaceUser.placeUserRole.controlLevel == 100) IconButton(
                onPressed: () async {
                  deletePromo();
                },
                icon: const Icon(Icons.delete_forever, color: AppColors.attentionRed,)
            ),

          ],
        ),
        body: PopScope(
          // POP SCOPE для обработки кнопки назад
          canPop: false,
          onPopInvoked: (bool didPop) async{
            if (didPop){
              return;
            }
            _navigateToPromos();


          },
          child: Stack (
            children: [
              // ---- Экран загрузки ----
              if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка данных',)
              else if (deleting) const LoadingScreen(loadingText: 'Подожди, удаляем мероприятие',)
              else CustomScrollView(
                  slivers: <Widget> [
                    SliverList(delegate: SliverChildListDelegate(
                        [

                          ImageInViewScreenWidget(
                              imagePath: promo.imageUrl,
                              favCounter: promo.favUsersIds.length,
                              inFav: promo.inFav,
                              onTap: () async {
                                await addOrDeleteFromFav();
                              },
                              categoryName: promo.category.name,
                              headline: promo.headline,
                              desc: place.id != '' ? '${place.name}, ${place.city.name}, ${place.street}, ${place.house}' :  '${promo.city.name}, ${promo.street}, ${promo.house}',
                              openOrToday: promo.today,
                              trueText: 'Сегодня',
                              falseText: ''
                          ),

                          // ВИДЖЕТЫ ПОД КАРТИНКОЙ

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                if (promo.desc != '') ExpandableText(text: promo.desc),

                                const SizedBox(height: 20.0),

                                // ВИДЖЕТ ЦЕНЫ И ОБРАТНОЙ СВЯЗИ

                                CallbackWidget(
                                  telegram: promo.telegram,
                                  whatsapp: promo.whatsapp,
                                  phone: promo.phone,
                                  instagram: promo.instagram,
                                ),

                                const SizedBox(height: 16.0),

                                // ВИДЖЕТ РАСПИСАНИЯ

                                ScheduleWidget(promo: promo),

                                const SizedBox(height: 16.0),

                                PlaceOrLocationWidget(
                                  city: promo.city,
                                  desc: promo.placeId != '' ? 'Ты можешь перейти в заведение и ознакомиться с ним подробнее' : 'Адрес, где будет проводится мероприятие',
                                  headline: promo.placeId != '' ? 'Место проведения: ${place.name}' : 'Место проведения',
                                  house: promo.house,
                                  street: promo.street,
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
          ),
        )
    );
  }

  Future<void> goToPromoEditScreen() async {

    // Переходим на страницу редактирования

    final results = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateOrEditPromoScreen(promoInfo: promo,),
      ),
    );

    // Если есть результат с той страницы

    if (results != null) {

      setState(() {
        loading = true;
      });

      PromoList promosList = PromoList();

      // Подгружаем мероприятие из общего списка
      PromoCustom promoCustom = promosList.getEntityFromFeedListById(promo.id);

      // Заменяем мероприятие на обновленное
      setState(() {
        promo = promoCustom;
        loading = false;
      });
    }
  }

  Future<void> addOrDeleteFromFav() async {
    if (UserCustom.currentUser?.uid == '' || UserCustom.currentUser?.uid == null)
    {
      _showSnackBar('Чтобы добавлять в избранное, нужно зарегистрироваться!', AppColors.attentionRed, 2);
    }
    else {

      if (promo.inFav)
      {
        String resDel = await promo.deleteFromFav();

        if (resDel == 'success'){

          _showSnackBar('Удалено из избранных', AppColors.attentionRed, 1);

        } else {
          _showSnackBar(resDel, AppColors.attentionRed, 1);
        }
      }
      else {
        String res = await promo.addToFav();

        if (res == 'success') {

          _showSnackBar('Добавлено в избранные', Colors.green, 1);

        } else {
          _showSnackBar(res, AppColors.attentionRed, 1);
        }
      }

      PromoCustom tempPromo = await promo.getEntityByIdFromDb(promo.id);

      setState(() {
        promo = tempPromo;
      });

    }
  }
}