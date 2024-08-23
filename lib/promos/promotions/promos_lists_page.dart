import 'package:dvij_flutter/classes/entity_page_type_enum.dart';
import 'package:dvij_flutter/promos/promo_category_class.dart';
import 'package:dvij_flutter/promos/promo_class.dart';
import 'package:dvij_flutter/promos/promo_sorting_options.dart';
import 'package:dvij_flutter/promos/promos_list_class.dart';
import 'package:dvij_flutter/promos/promos_list_manager.dart';
import 'package:dvij_flutter/promos/promotions/create_or_edit_promo_screen.dart';
import 'package:dvij_flutter/promos/promotions/promo_view_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../ads/ad_user_class.dart';
import '../../cities/city_class.dart';
import '../../classes/pair.dart';
import '../../constants/constants.dart';
import '../../current_user/user_class.dart';
import '../../elements/loading_screen.dart';
import '../../elements/snack_bar.dart';
import '../../themes/app_colors.dart';
import '../../widgets_global/cards_widgets/card_widget_for_event_promo_places.dart';
import '../../widgets_global/filter_widgets/filter_widget.dart';
import '../../widgets_global/text_widgets/headline_and_desc.dart';
import '../promos_elements/promo_filter_page.dart';


class PromosListsPage extends StatefulWidget {
  final EntityPageTypeEnum pageTypeEnum;

  const PromosListsPage({required this.pageTypeEnum, Key? key}) : super(key: key);

  @override
  State<PromosListsPage> createState() => _PromosListsPageState();
}

class _PromosListsPageState extends State<PromosListsPage> {

  PromoList promosList = PromoList();
  late List<PromoCategory> promoCategoriesList;

  // --- Переменные фильтра по умолчанию ----

  PromoCategory promoCategoryFromFilter = PromoCategory(name: '', id: '');
  City cityFromFilter = City(name: '', id: '');

  bool today = false;
  bool onlyFromPlacePromos = false;

  DateTime selectedStartDatePeriod = DateTime(2100);
  DateTime selectedEndDatePeriod = DateTime(2100);

  // --- Счетчик выбранных значений фильтра ---

  int filterCount = 0;

  // --- Переменная сортировки по умолчанию ----

  PromoSortingOption _selectedSortingOption = PromoSortingOption.createDateAsc;

  // ---- Переменные состояния экрана ----

  bool loading = true;
  bool refresh = false;

  // TODO - Сделать загрузку рекламы из БД
  // --- Рекламные переменные -----

  // --- Список рекламы ---
  //List<String> adList = ['Реклама №1', 'Реклама №2', 'Реклама №3', 'Реклама №4', 'Реклама №5'];

  List<AdUser> adList = AdUser.currentAllAdsList;
  List<Pair> allElementsList = [];
  // ---- Список для хранения индексов элементов рекламы
  List<int> adIndexesList = [];
  // --- Шаг - сколько элементов списка будет между рекламными постами
  int adStep = 2;
  // --- Индекс первого рекламного элемента
  int firstIndexOfAd = 1;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {

    // --- Функция инициализации данных ----

    setState(() {
      loading = true;
    });

    // --- Подгружаем список категорий заведений -----

    promoCategoriesList = PromoCategory.currentPromoCategoryList;

    // --- Считываем индексы, где будет стоять реклама ----

    adIndexesList = AdUser.getAdIndexesList(adList, adStep, firstIndexOfAd);

    // ---- Подгружаем город в фильтр из данных пользователя ---

    if (UserCustom.currentUser != null && widget.pageTypeEnum == EntityPageTypeEnum.feed){
      setState(() {
        cityFromFilter = UserCustom.currentUser!.city;
      });
    }

    // ---- Получаем список мероприятий и рекламы

    await _getPromosList(pageTypeEnum: widget.pageTypeEnum);

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator (

          // ---- Виджет обновления списка при протягивании экрана вниз ----

          onRefresh: () async {
            await refreshList(pageTypeEnum: widget.pageTypeEnum);
          },
          child: Stack (
            children: [

              if ((UserCustom.currentUser?.uid == null || UserCustom.currentUser?.uid == '') && widget.pageTypeEnum == EntityPageTypeEnum.fav) Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Чтобы добавлять мероприятия в избранные, нужно зарегистрироваться',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  )
              )

              else if (
              (UserCustom.currentUser == null || UserCustom.currentUser!.uid == '' || !_auth.currentUser!.emailVerified)
                  && widget.pageTypeEnum == EntityPageTypeEnum.my
              ) Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Чтобы создавать мероприятия, нужно зарегистрироваться',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    )
                )

              // Экран загрузки

              else if (loading) const LoadingScreen(loadingText: AppConstants.eventsLoadingMessage)

                // Экран обновления

                else if (refresh) Center(
                    child: Text(
                      AppConstants.eventsRefreshMessage,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )

                  // Экран с фильтром и мероприятиями

                  else Column(
                      children: [

                        // ---- Виджет фильтра

                        FilterWidget(
                          onFilterTap: (){
                            _showFilterDialog();
                          },
                          filterCount: filterCount,
                          sortingValue: _selectedSortingOption,
                          onSortingValueChanged: (PromoSortingOption? newValue) {
                            setState(() {
                              _selectedSortingOption = newValue!;
                              promosList.sortEntitiesList(_selectedSortingOption);
                            });
                          },
                          sortingItems: PromoCustom.emptyPromo.getPromoSortingOptionsList(),
                        ),

                        // ---- Если список пустой -----

                        if (promosList.promosList.isEmpty) const Expanded(
                            child: Center(
                              child: Text(AppConstants.emptyMessage),
                            )
                        ),

                        // ---- Если список не пустой -----

                        if (promosList.promosList.isNotEmpty) Expanded(
                            child: ListView.builder(
                                padding: const EdgeInsets.all(10.0),
                                itemCount: allElementsList.length,
                                itemBuilder: (context, index) {

                                  // --- ЕСЛИ ЭТО РЕКЛАМА, ОТОБРАЖАЕМ ВИДЖЕТ РЕКЛАМЫ ----

                                  if (allElementsList[index].first == 'ad')  {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20,
                                          horizontal: 20
                                      ),
                                      child: HeadlineAndDesc(headline: adList[allElementsList[index].second].headline, description: 'реклама'),
                                    );
                                  }

                                  // ----- ЕСЛИ МЕРОПРИЯТИЕ, ТО КАРТОЧКУ МЕРОПРИЯТИЯ ----

                                  else {

                                    // Переменная индекса мероприятия в списке, до смешивания с сущностями рекламы
                                    int indexWithAddCountCorrection = allElementsList[index].second;

                                    // ---- Виджет карточки

                                    return CardWidgetForEventPromoPlaces(
                                      height: 450,
                                      promo: promosList.promosList[indexWithAddCountCorrection],
                                      onTap: () async {
                                        // --- Переход на страницу просмотра мероприятия
                                        await goToPromoViewScreen(indexWithAddCountCorrection);
                                      },
                                      // --- Функция на нажатие на карточке кнопки ИЗБРАННОЕ ---
                                      onFavoriteIconPressed: () async {
                                        await addOrDeleteInFav(indexWithAddCountCorrection);
                                      },
                                    );
                                  }
                                }
                            )
                        )
                      ],
                    ),
            ],
          ),
        ),
        floatingActionButton: widget.pageTypeEnum == EntityPageTypeEnum.my ? FloatingActionButton(
          onPressed: () {

            // Если пользователь зарегистрирован и подтвердил email

            if ((UserCustom.currentUser != null && UserCustom.currentUser!.uid != '' && _auth.currentUser!.emailVerified) && widget.pageTypeEnum == EntityPageTypeEnum.my ) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateOrEditPromoScreen(promoInfo: PromoCustom.emptyPromo)),
              );
            }

            // Если пользователь не подтвредил почту

            else if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {

              showSnackBar(context,'Чтобы создать мероприятие, нужно подтвердить почту', AppColors.attentionRed, 2);

            }

            // Если пользователь совсем не проходил никакую регистрацию

            else {

              showSnackBar(context,'Чтобы создать мероприятие, нужно зарегистрироваться', AppColors.attentionRed, 2);

            }

          },
          backgroundColor: AppColors.brandColor,
          child: const Icon(Icons.add), // Цвет кнопки
        ) : null

    );
  }

  Future<void> _getPromosList({required EntityPageTypeEnum pageTypeEnum, bool refresh = false}) async {

    // ---- Обновляем счетчик выбранных настроек ----
    setState(() {
      _setFiltersCount(promoCategoryFromFilter, cityFromFilter, today, onlyFromPlacePromos, selectedStartDatePeriod, selectedEndDatePeriod);
    });

    // ----- РАБОТАЕМ СО СПИСКОМ МЕРОПРИЯТИЙ -----

    if (pageTypeEnum == EntityPageTypeEnum.feed){
      if (PromoListsManager.currentFeedPromosList.promosList.isEmpty){
        // ---- Если список пуст ----
        // ---- Считываем с БД заведения -----

        promosList = await promosList.getListFromDb();

      } else {
        // --- Если список не пустой ----
        // --- Подгружаем готовый список ----

        promosList.promosList = PromoListsManager.currentFeedPromosList.promosList;

      }
    } else {
      if (UserCustom.currentUser?.uid != null && UserCustom.currentUser?.uid != ''){
        if (pageTypeEnum == EntityPageTypeEnum.my){
          promosList = await promosList.getMyListFromDb(UserCustom.currentUser!.uid, refresh: refresh);
        } else if (pageTypeEnum == EntityPageTypeEnum.fav){
          promosList = await promosList.getFavListFromDb(UserCustom.currentUser!.uid, refresh: refresh);
        }

      }
    }

    // Фильтруем список и внедряем в него рекламу
    _filterListAndIncludeAd();

  }

  Future<void> refreshList({required EntityPageTypeEnum pageTypeEnum}) async {
    setState(() {
      refresh = true;
    });

    promosList = PromoList();

    // Подгружаем список мероприятий с базы данных

    if (pageTypeEnum == EntityPageTypeEnum.feed){
      promosList = await promosList.getListFromDb();
    } else {
      await _getPromosList(pageTypeEnum: widget.pageTypeEnum, refresh: true);
    }

    _filterListAndIncludeAd();

    setState(() {
      refresh = false;
    });
  }

  void _showFilterDialog() async {
    // Открываем всплывающее окно и ждем результатов
    final results = await Navigator.of(context).push(_createPopupFilter(promoCategoriesList));

    // Если пользователь выбрал что-то в диалоге фильтра
    if (results != null) {
      // Устанавливаем значения, которые он выбрал
      setState(() {

        loading = true;
        cityFromFilter = results[0];
        promoCategoryFromFilter = results[1];
        today = results [2];
        onlyFromPlacePromos = results [3];
        selectedStartDatePeriod = results[4];
        selectedEndDatePeriod = results[5];
        promosList = PromoList();

      });

      // Подгружаем список мероприятий и рекламы
      await _getPromosList(pageTypeEnum: widget.pageTypeEnum);

      setState(() {
        loading = false;
      });
    }
  }

  // ----- Путь для открытия всплывающей страницы фильтра ----

  Route _createPopupFilter(List<PromoCategory> categories) {
    return PageRouteBuilder(

      pageBuilder: (context, animation, secondaryAnimation) {

        // --- Сама страница фильтра ---
        return PromoFilterPage(
          categories: categories,
          chosenCategory: promoCategoryFromFilter,
          chosenCity: cityFromFilter,
          onlyFromPlacePromos: onlyFromPlacePromos,
          today: today,
          selectedEndDatePeriod: selectedEndDatePeriod,
          selectedStartDatePeriod: selectedStartDatePeriod,
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 100),

    );
  }

  Future<void> goToPromoViewScreen(int indexWithAddCountCorrection) async {

    // Переходим на страницу заведения

    final results = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PromoViewScreen(promoId: promosList.promosList[indexWithAddCountCorrection].id),
      ),
    );

    // Если есть результат с той страницы

    if (results != null) {

      // Подгружаем мероприятие из общего списка
      PromoCustom promoCustom = promosList.getEntityFromFeedListById(promosList.promosList[indexWithAddCountCorrection].id);

      // Заменяем мероприятие на обновленное
      setState(() {
        promosList.promosList[indexWithAddCountCorrection] = promoCustom;
      });
    }
  }

  Future<void> addOrDeleteInFav(int indexWithAddCountCorrection) async {

    // ---- Если не зарегистрирован или не вошел ----
    if (UserCustom.currentUser?.uid == '' || UserCustom.currentUser?.uid == null)
    {
      _showSnackBar('Чтобы добавлять в избранное, нужно зарегистрироваться!', AppColors.attentionRed, 2);
    }

    // --- Если пользователь залогинен -----
    else {

      // --- Если уже в избранном ----
      if (promosList.promosList[indexWithAddCountCorrection].inFav == true)
      {

        // --- Удаляем из избранных ---
        String resDel = await promosList.promosList[indexWithAddCountCorrection].deleteFromFav();

        if (resDel == 'success'){
          _showSnackBar('Удалено из избранных', AppColors.attentionRed, 1);
        } else {
          _showSnackBar(resDel, AppColors.attentionRed, 1);
        }
      }
      else {
        // --- Если заведение не в избранном ----

        // -- Добавляем в избранное ----
        String res = await promosList.promosList[indexWithAddCountCorrection].addToFav();

        if (res == 'success') {

          _showSnackBar('Добавлено в избранные', Colors.green, 1);

        } else {
          _showSnackBar(res, AppColors.attentionRed, 1);
        }
      }
    }
  }

  void _showSnackBar(String text, Color color, int secondsToShow){
    showSnackBar(context, text, color, secondsToShow);
  }

  // ---- Функция обвноления счетчика выбранных настроек фильтра ----
  void _setFiltersCount(
      PromoCategory promoCategoryFromFilter,
      City cityFromFilter,
      bool todayFromFilter,
      bool onlyFromPlacePromosFromFilter,
      DateTime selectedStartDatePeriod,
      DateTime selectedEndDatePeriod
      ){

    int count = 0;

    // --- Если значения не соответствуют дефолтным, то плюсуем счетчик ----
    if (promoCategoryFromFilter.name != ''){
      count++;
    }

    if (cityFromFilter.name != ''){
      count++;
    }

    if (todayFromFilter) count++;

    if (onlyFromPlacePromosFromFilter) count++;

    if (selectedStartDatePeriod != DateTime(2100)) count++;

    // --- Обновляем счетчик на странице -----
    setState(() {
      filterCount = count;
    });

  }

  void _filterListAndIncludeAd(){



    setState(() {

      // Фильтруем список

      promosList.filterLists(
          promosList.generateMapForFilter(
              promoCategoryFromFilter,
              cityFromFilter,
              today,
              onlyFromPlacePromos,
              selectedStartDatePeriod,
              selectedEndDatePeriod
          )
      );

      // Сортируем список

      promosList.sortEntitiesList(_selectedSortingOption);

      // Внедряем рекламу

      allElementsList = AdUser.generateIndexedList(adIndexesList, promosList.promosList.length);

    });
  }

}
