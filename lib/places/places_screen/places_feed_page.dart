import 'package:dvij_flutter/cities/city_class.dart';
import 'package:dvij_flutter/classes/pair.dart';
import 'package:dvij_flutter/places/place_category_class.dart';
import 'package:dvij_flutter/places/place_class.dart';
import 'package:dvij_flutter/widgets_global/default_screens/empty_screen.dart';
import 'package:dvij_flutter/widgets_global/filter_widgets/filter_widget.dart';
import 'package:dvij_flutter/widgets_global/text_widgets/headline_and_desc.dart';
import 'package:dvij_flutter/places/place_list_class.dart';
import 'package:dvij_flutter/places/place_list_manager.dart';
import 'package:dvij_flutter/places/places_screen/place_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import '../../ads/ad_user_class.dart';
import '../../widgets_global/cards_widgets/card_widget_for_event_promo_places.dart';
import '../place_sorting_options.dart';
import '../../current_user/user_class.dart';
import '../../elements/custom_snack_bar.dart';
import '../../elements/loading_screen.dart';
import '../places_elements/place_filter_page.dart';


// ---- ЭКРАН ЛЕНТЫ ЗАВЕДЕНИЙ ------

class PlacesFeedPage extends StatefulWidget {
  const PlacesFeedPage({Key? key}) : super(key: key);

  @override
  PlacesFeedPageState createState() => PlacesFeedPageState();
}

class PlacesFeedPageState extends State<PlacesFeedPage> {
  PlaceList placesList = PlaceList(); // Список мест
  late List<PlaceCategory> placeCategoriesList; // Список категорий мест

  // --- Переменные фильтра по умолчанию ----

  PlaceCategory placeCategoryFromFilter = PlaceCategory(name: '', id: '');
  City cityFromFilter = City(name: '', id: '');
  bool nowIsOpenFromFilter = false;
  bool haveEventsFromFilter = false;
  bool havePromosFromFilter = false;

  // --- Переменная сортировки по умолчанию ----

  PlaceSortingOption _selectedSortingOption = PlaceSortingOption.nameAsc;

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

  List<Pair> pairList = [];

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
    if (UserCustom.currentUser != null){
      setState(() {
        cityFromFilter = UserCustom.currentUser!.city;
      });
      /*if (UserCustom.currentUser!.city != ''){
        City usersCity = City.getCityByIdFromList(UserCustom.currentUser!.city);
        setState(() {
          cityFromFilter = usersCity;
        });
      }*/

    }

    // ---- Устанавливаем счетчик выбранных в фильтре настроек ----

    _setFiltersCount(placeCategoryFromFilter, cityFromFilter, nowIsOpenFromFilter, haveEventsFromFilter, havePromosFromFilter);

    // ----- Работаем со списком заведений -----

    // ---- Если список пуст ----
    if (PlaceListManager.currentFeedPlacesList.placeList.isEmpty){

      // ---- Считываем с БД заведения -----
      placesList = await placesList.getListFromDb();

      // --- Фильтруем список -----
      if (placesList.placeList.isNotEmpty){
        setState(() {
          placesList.filterLists(
              placesList.generateMapForFilter(
                  placeCategoryFromFilter,
                  cityFromFilter,
                  haveEventsFromFilter,
                  nowIsOpenFromFilter,
                  havePromosFromFilter
              )
          );
        });
      }
    } else {
      // --- Если список не пустой ----
      // --- Подгружаем готовый список ----

      // --- Фильтруем список -----
      setState(() {
        placesList = PlaceListManager.currentFeedPlacesList;
        placesList.filterLists(
            placesList.generateMapForFilter(
                placeCategoryFromFilter,
                cityFromFilter,
                haveEventsFromFilter,
                nowIsOpenFromFilter,
                havePromosFromFilter
            )
        );
      });
    }

    // Подгружаем список категорий заведений
    placeCategoriesList = PlaceCategory.currentPlaceCategoryList;

    // --- Считываем индексы, где будет стоять реклама ----

    adIndexesList = AdUser.getAdIndexesList(adList, adStep, firstIndexOfAd);

    setState(() {
      allElementsList = AdUser.generateIndexedList(adIndexesList, placesList.placeList.length);
    });

    setState(() {
      loading = false;
    });
  }

  // --- Функция отображения всплывающего окна ----

  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  // ---- Сам экран ленты заведений ----

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // - Обновление списка, если тянуть экран вниз
        body: RefreshIndicator (
          onRefresh: () async {
            await _refreshFeed();
          },
          child: Stack (
            children: [
              if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка мест')
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
                        sortingItems: Place.emptyPlace.getPlaceSortingOptionsList(),
                    ),

                    // ---- Если список заведений пустой -----

                    if (placesList.placeList.isEmpty) Expanded(
                        child: ListView.builder(
                            padding: const EdgeInsets.all(15.0),
                            itemCount: 1,
                            itemBuilder: (context, index) {
                              return const EmptyScreenWidget();
                            }
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
        )
    );
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

  Future<void> _refreshFeed() async {
    setState(() {
      refresh = true;
    });

    placesList = PlaceList();

    placesList = await placesList.getListFromDb();

    // --- Фильтруем список -----
    setState(() {
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
      refresh = false;
    });
  }

  Future<void> addOrDeleteFromFav(int index) async {
    // TODO Сделать проверку на подтвержденный Email
    // ---- Если не зарегистрирован или не вошел ----
    if (UserCustom.currentUser?.uid == '' || UserCustom.currentUser?.uid == null)
    {
      showSnackBar('Чтобы добавлять в избранное, нужно зарегистрироваться!', AppColors.attentionRed, 2);
    }

    // --- Если пользователь залогинен -----
    else {

      setState(() {
        loading = true;
      });

      // --- Если уже в избранном ----
      if (placesList.placeList[index].inFav!)
      {
        // --- Удаляем из избранных ---
        //String resDel = await Place.deletePlaceFromFav(placesList[indexWithAddCountCorrection].id);
        String resDel = await placesList.placeList[index].deleteFromFav();
        // ---- Инициализируем счетчик -----
        //int favCounter = placesList.placeList[index].favUsersIds!;

        if (resDel == 'success'){
          // Если удаление успешное, обновляем 2 списка - текущий на экране, и общий загруженный из БД
          setState(() {
            // Обновляем текущий список
            placesList.placeList[index].inFav = false;
            //favCounter --;
            //placesList.placeList[index].favUsersIds = favCounter;

            // Обновляем общий список из БД
            //Place.updateCurrentPlaceListFavInformation(placesList[indexWithAddCountCorrection].id, favCounter.toString(), 'false');
            placesList.placeList[index].updateCurrentListFavInformation();

          });
          showSnackBar('Удалено из избранных', AppColors.attentionRed, 1);
        } else {
          // Если удаление из избранных не прошло, показываем сообщение
          showSnackBar(resDel, AppColors.attentionRed, 1);
        }
      }
      else {
        // --- Если заведение не в избранном ----

        // -- Добавляем в избранное ----
        //String res = await Place.addPlaceToFav(placesList[indexWithAddCountCorrection].id);
        String res = await placesList.placeList[index].addToFav();
        // ---- Инициализируем счетчик добавивших в избранное
        //int favCounter = placesList.placeList[index].favUsersIds!;

        if (res == 'success') {
          // --- Если добавилось успешно, так же обновляем текущий список и список из БД
          setState(() {
            // Обновляем текущий список
            placesList.placeList[index].inFav = true;
           // favCounter ++;
            //placesList.placeList[index].favUsersIds = favCounter;
            // Обновляем список из БД
            placesList.placeList[index].updateCurrentListFavInformation();
            //Place.updateCurrentPlaceListFavInformation(placesList[indexWithAddCountCorrection].id, favCounter.toString(), 'true');
          });

          showSnackBar('Добавлено в избранные', Colors.green, 1);

        } else {
          // Если добавление прошло неудачно, отображаем всплывающее окно
          showSnackBar(res, AppColors.attentionRed, 1);
        }
      }

      setState(() {
        loading = false;
      });
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
      setState(() {
        placesList.placeList[indexWithAddCountCorrection].inFav = results[0];
        placesList.placeList[indexWithAddCountCorrection].favUsersIds = results[1];
      });
    }
  }
}