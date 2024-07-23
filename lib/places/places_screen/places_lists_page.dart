import 'package:dvij_flutter/places/places_screen/create_or_edit_place_screen.dart';
import 'package:dvij_flutter/places/places_screen/place_view_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../ads/ad_user_class.dart';
import '../../cities/city_class.dart';
import '../../classes/entity_page_type_enum.dart';
import '../../classes/pair.dart';
import '../../constants/constants.dart';
import '../../current_user/user_class.dart';
import '../../elements/custom_snack_bar.dart';
import '../../elements/loading_screen.dart';
import '../../themes/app_colors.dart';
import '../../widgets_global/cards_widgets/card_widget_for_event_promo_places.dart';
import '../../widgets_global/default_screens/empty_screen.dart';
import '../../widgets_global/filter_widgets/filter_widget.dart';
import '../../widgets_global/text_widgets/headline_and_desc.dart';
import '../place_category_class.dart';
import '../place_class.dart';
import '../place_list_class.dart';
import '../place_list_manager.dart';
import '../place_sorting_options.dart';
import '../places_elements/place_filter_page.dart';

class PlacesListsPage extends StatefulWidget {
  final EntityPageTypeEnum pageTypeEnum;

  const PlacesListsPage({required this.pageTypeEnum, Key? key}) : super(key: key);

  @override
  State<PlacesListsPage> createState() => _PlacesListsPageState();
}

class _PlacesListsPageState extends State<PlacesListsPage> {

  PlaceList placesList = PlaceList(); // Список мест
  late List<PlaceCategory> placeCategoriesList; // Список категорий мест

  // --- Переменные фильтра по умолчанию ----

  PlaceCategory placeCategoryFromFilter = PlaceCategory(name: '', id: '');
  City cityFromFilter = City.empty();
  bool nowIsOpenFromFilter = false;
  bool haveEventsFromFilter = false;
  bool havePromosFromFilter = false;

  // --- Переменная сортировки по умолчанию ----

  PlaceSortingOption _selectedSortingOption = PlaceSortingOption.favCountDesc;

  // Переменная, включающая экран загрузки
  bool loading = true;

  // Переменная, включающая экран обновления
  bool refresh = false;

  // Счетчик выбранных значений фильтра
  int filterCount = 0;

  // TODO - Сделать загрузку рекламы из БД
  // --- Рекламные переменные -----

  // --- Список рекламы ---
  List<String> adList = ['Реклама №1', 'Реклама №2', 'Реклама №3', 'Реклама №4', 'Реклама №5'];
  List<Pair> allElementsList = [];
  // ---- Список для хранения индексов элементов рекламы
  List<int> adIndexesList = [];
  // --- Шаг - сколько элементов списка будет между рекламными постами
  int adStep = 2;
  // --- Индекс первого рекламного элемента
  int firstIndexOfAd = 1;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState(){

    super.initState();
    _initializeData();
  }

  // --- Функция инициализации данных ----

  Future<void> _initializeData() async {

    setState(() {
      loading = true;
    });

    // ---- Подгружаем город в фильтр из данных пользователя ---
    if (UserCustom.currentUser != null && widget.pageTypeEnum == EntityPageTypeEnum.feed){
      setState(() {
        cityFromFilter = UserCustom.currentUser!.city;
      });
    }


    // Подгружаем список категорий заведений
    placeCategoriesList = PlaceCategory.currentPlaceCategoryList;

    // --- Считываем индексы, где будет стоять реклама ----

    adIndexesList = AdUser.getAdIndexesList(adList, adStep, firstIndexOfAd);

    // ---- Получаем список мероприятий и рекламы

    await _getPlacesList(pageTypeEnum: widget.pageTypeEnum);

    setState(() {
      loading = false;
    });
  }

  // ---- Сам экран ленты заведений ----

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // - Обновление списка, если тянуть экран вниз
        body: RefreshIndicator (
          onRefresh: () async {
            await _refreshList(pageTypeEnum: widget.pageTypeEnum);
          },
          child: Stack (
            children: [
              if ((UserCustom.currentUser?.uid == null || UserCustom.currentUser?.uid == '') && widget.pageTypeEnum == EntityPageTypeEnum.fav) Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Чтобы добавлять заведения в избранные, нужно зарегистрироваться',
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
                        'Чтобы создавать заведения, нужно зарегистрироваться',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    )
                )
              else if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка мест')
              else if (refresh) const EmptyScreenWidget(messageText: 'Подожди, идет обновление',)
              else Column(
                  children: [

                    // ---- Фильтр и сортировка -----

                    FilterWidget(
                      onFilterTap: (){
                        _showFilterDialog();
                      },
                      filterCount: filterCount,
                      sortingValue: _selectedSortingOption,
                      onSortingValueChanged: (PlaceSortingOption? newValue) {
                        setState(() {
                          _selectedSortingOption = newValue!;
                          placesList.sortEntitiesList(_selectedSortingOption);
                        });
                      },
                      sortingItems: Place.empty().getPlaceSortingOptionsList(),
                    ),

                    // ---- Если список заведений пустой -----

                    if (placesList.placeList.isEmpty) const Expanded(
                        child: Center(
                          child: Text(AppConstants.emptyMessage),
                        )
                    ),

                    // ---- Если список заведений не пустой -----

                    if (placesList.placeList.isNotEmpty) Expanded(

                        child: ListView.builder(
                            padding: const EdgeInsets.all(10.0),
                            itemCount: allElementsList.length,
                            itemBuilder: (context, index) {
                              if (allElementsList[index].first == 'ad')  {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                      horizontal: 20),
                                  child: HeadlineAndDesc(headline: adList[allElementsList[index].second], description: 'реклама'),
                                );
                              } else {

                                int indexWithAddCountCorrection = allElementsList[index].second;

                                return CardWidgetForEventPromoPlaces(

                                  place: placesList.placeList[indexWithAddCountCorrection],
                                  height: 450,

                                  onTap: () async {
                                    await goToPlaceViewScreen(indexWithAddCountCorrection);
                                  },

                                  // --- Функция на нажатие на карточке кнопки ИЗБРАННОЕ ---
                                  onFavoriteIconPressed: () async {
                                    await addOrDeleteFromFav(indexWithAddCountCorrection);
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
                MaterialPageRoute(builder: (context) => CreateOrEditPlaceScreen(placeInfo: Place.empty(),)),
              );
            }

            // Если пользователь не подтвредил почту

            else if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {

              showSnackBar('Чтобы создать заведение, нужно подтвердить почту', AppColors.attentionRed, 2);

            }

            // Если пользователь совсем не проходил никакую регистрацию

            else {

              showSnackBar('Чтобы создать заведение, нужно зарегистрироваться', AppColors.attentionRed, 2);

            }

          },
          backgroundColor: AppColors.brandColor,
          child: const Icon(Icons.add), // Цвет кнопки
        ) : null
    );
  }

  // --- Функция отображения всплывающего окна ----

  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _getPlacesList({required EntityPageTypeEnum pageTypeEnum, bool refresh = false}) async {

    // ---- Устанавливаем счетчик выбранных в фильтре настроек ----
    setState(() {
      _setFiltersCount(placeCategoryFromFilter, cityFromFilter, nowIsOpenFromFilter, haveEventsFromFilter, havePromosFromFilter);
    });


    // ----- РАБОТАЕМ СО СПИСКОМ МЕРОПРИЯТИЙ -----

    if (pageTypeEnum == EntityPageTypeEnum.feed){

      if (PlaceListManager.currentFeedPlacesList.placeList.isEmpty){
        // ---- Если список пуст ----
        // ---- Считываем с БД заведения -----
        placesList = await placesList.getListFromDb();
      } else {
        // --- Если список не пустой ----
        // --- Подгружаем готовый список ----
        placesList.placeList = PlaceListManager.currentFeedPlacesList.placeList;
      }

    } else {
      if (UserCustom.currentUser?.uid != null && UserCustom.currentUser?.uid != ''){
        if (pageTypeEnum == EntityPageTypeEnum.my){
          placesList = await placesList.getMyListFromDb(UserCustom.currentUser!.uid, refresh: refresh);
        } else if (pageTypeEnum == EntityPageTypeEnum.fav){
          placesList = await placesList.getFavListFromDb(UserCustom.currentUser!.uid, refresh: refresh);
        }

      }
    }

    // Фильтруем список и внедряем в него рекламу
    _filterListAndIncludeAd();

  }

  void _filterListAndIncludeAd(){

    setState(() {
      // Фильтруем список
      placesList.filterLists(
          placesList.generateMapForFilter(
              placeCategoryFromFilter,
              cityFromFilter,
              haveEventsFromFilter,
              nowIsOpenFromFilter,
              havePromosFromFilter
          )
      );

      // Сортируем список
      placesList.sortEntitiesList(_selectedSortingOption);

      // Внедряем рекламу
      allElementsList = AdUser.generateIndexedList(adIndexesList, placesList.placeList.length);

    });

  }

  // ---- Функция обвноления счетчика выбранных настроек фильтра ----
  void _setFiltersCount(
      PlaceCategory placeCategoryFromFilter,
      City cityFromFilter,
      bool nowIsOpenFromFilter,
      bool haveEventsFromFilter,
      bool havePromosFromFilter,
      ){

    int count = 0;

    // --- Если значения не соответствуют дефолтным, то плюсуем счетчик ----
    if (placeCategoryFromFilter.name != ''){
      count++;
    }

    if (cityFromFilter.name != ''){
      count++;
    }

    if (nowIsOpenFromFilter) count++;

    if (haveEventsFromFilter) count++;

    if (havePromosFromFilter) count++;

    // --- Обновляем счетчик на странице -----
    setState(() {
      filterCount = count;
    });

  }

  // ---- Функция отображения диалога фильтра ----

  void _showFilterDialog() async {
    // Открываем всплывающее окно и ждем результатов
    final results = await Navigator.of(context).push(_createPopupFilter(placeCategoriesList));

    // Если пользователь выбрал что-то в диалоге фильтра
    if (results != null) {
      // Устанавливаем значения, которые он выбрал
      setState(() {
        loading = true;
        cityFromFilter = results[0];
        placeCategoryFromFilter = results[1];
        nowIsOpenFromFilter = results [2];
        haveEventsFromFilter = results [3];
        havePromosFromFilter = results [4];
        placesList = PlaceList();

        // ---- Обновляем счетчик выбранных настроек ----
        _setFiltersCount(placeCategoryFromFilter, cityFromFilter, nowIsOpenFromFilter, haveEventsFromFilter, havePromosFromFilter);

      });

      // --- Заново подгружаем список из БД ---

      // --- Фильтруем список согласно новым выбранным данным из фильтра ----
      setState(() {
        placesList.placeList = PlaceListManager.currentFeedPlacesList.placeList;
        placesList.filterLists(
            placesList.generateMapForFilter(
                placeCategoryFromFilter,
                cityFromFilter,
                haveEventsFromFilter,
                nowIsOpenFromFilter,
                havePromosFromFilter
            )
        );

        allElementsList = AdUser.generateIndexedList(adIndexesList, placesList.placeList.length);

      });

      setState(() {
        loading = false;
      });
    }
  }

  // ----- Путь для открытия всплывающей страницы фильтра ----

  Route _createPopupFilter(List<PlaceCategory> categories) {
    return PageRouteBuilder(

      pageBuilder: (context, animation, secondaryAnimation) {

        // --- Сама страница фильтра ---
        return PlaceFilterPage(
          categories: categories,
          chosenCategory: placeCategoryFromFilter,
          chosenCity: cityFromFilter,
          nowIsOpen: nowIsOpenFromFilter,
          haveEvents: haveEventsFromFilter,
          havePromos: havePromosFromFilter,
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

  Future<void> _refreshList({required EntityPageTypeEnum pageTypeEnum}) async {
    setState(() {
      refresh = true;
    });

    // Подгружаем список заведений с базы данных

    placesList = PlaceList();

    if (pageTypeEnum == EntityPageTypeEnum.feed){
      placesList = await placesList.getListFromDb();
    } else {
      await _getPlacesList(pageTypeEnum: widget.pageTypeEnum, refresh: true);
    }

    _filterListAndIncludeAd();

    setState(() {
      refresh = false;
    });
  }

  Future<void> addOrDeleteFromFav(int index) async {
    // ---- Если не зарегистрирован или не вошел ----
    if (UserCustom.currentUser?.uid == '' || UserCustom.currentUser?.uid == null || !_auth.currentUser!.emailVerified)
    {
      showSnackBar('Чтобы добавлять в избранное, нужно зарегистрироваться!', AppColors.attentionRed, 2);
    }

    // --- Если пользователь залогинен -----
    else {

      // --- Если уже в избранном ----
      if (placesList.placeList[index].inFav)
      {
        // --- Удаляем из избранных ---
        String resDel = await placesList.placeList[index].deleteFromFav();

        if (resDel == 'success'){
          showSnackBar('Удалено из избранных', AppColors.attentionRed, 1);
        } else {
          showSnackBar(resDel, AppColors.attentionRed, 1);
        }
      }
      else {
        // --- Если заведение не в избранном ----

        // -- Добавляем в избранное ----
        String res = await placesList.placeList[index].addToFav();

        if (res == 'success') {

          showSnackBar('Добавлено в избранные', Colors.green, 1);

        } else {
          showSnackBar(res, AppColors.attentionRed, 1);
        }
      }
    }
  }

  Future<void> goToPlaceViewScreen(int indexWithAddCountCorrection) async {
    final results = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceViewScreen(placeId: placesList.placeList[indexWithAddCountCorrection].id),
      ),
    );

    if (results != null) {

      Place place = placesList.getEntityFromFeedListById(placesList.placeList[indexWithAddCountCorrection].id);

      setState(() {
        placesList.placeList[indexWithAddCountCorrection] = place;
      });

      /*setState(() {
        placesList.placeList[indexWithAddCountCorrection].inFav = results[0];
        placesList.placeList[indexWithAddCountCorrection].favUsersIds = results[1];
      });*/
    }

    /*if (results != null) {

      // Подгружаем мероприятие из общего списка
      EventCustom eventCustom = eventsList.getEntityFromFeedListById(eventsList.eventsList[indexWithAddCountCorrection].id);

      // Заменяем мероприятие на обновленное
      setState(() {
        eventsList.eventsList[indexWithAddCountCorrection] = eventCustom;
      });
    }*/

  }
}
