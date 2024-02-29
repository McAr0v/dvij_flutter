import 'package:dvij_flutter/cities/city_class.dart';
import 'package:dvij_flutter/places/place_category_class.dart';
import 'package:dvij_flutter/places/place_list_class.dart';
import 'package:dvij_flutter/places/place_list_manager.dart';
import 'package:dvij_flutter/places/places_screen/place_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import '../../widgets_global/cards_widgets/card_widget_for_event_promo_places.dart';
import '../../widgets_global/filter_widgets/filter_widget.dart';
import '../place_class.dart';
import '../place_sorting_options.dart';
import '../../classes/user_class.dart';
import '../../elements/custom_snack_bar.dart';
import '../../elements/loading_screen.dart';
import '../places_elements/place_filter_page.dart';


// ---- ЭКРАН ЛЕНТЫ ЗАВЕДЕНИЙ ------

class PlacesFavPage extends StatefulWidget {
  const PlacesFavPage({Key? key}) : super(key: key);

  @override
  PlacesFavPageState createState() => PlacesFavPageState();
}



class PlacesFavPageState extends State<PlacesFavPage> {

  PlaceList placesFavList = PlaceList();
  late List<PlaceCategory> placeCategoriesList;

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

    // ---- Устанавливаем счетчик выбранных в фильтре настроек ----

    _setFiltersCount(placeCategoryFromFilter, cityFromFilter, nowIsOpenFromFilter, haveEventsFromFilter, havePromosFromFilter);

    // ----- Работаем со списком заведений -----

    // ---- Если список пуст ----
    if (PlaceListManager.currentFavPlacesList.placeList.isEmpty){

      // ---- Считываем с БД заведения -----
      if (UserCustom.currentUser?.uid != null && UserCustom.currentUser?.uid != ''){

        placesFavList = await placesFavList.getFavListFromDb(UserCustom.currentUser!.uid);

        // --- Фильтруем список -----
        setState(() {
          placesFavList.filterLists(
              placesFavList.generateMapForFilter(
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
      placesFavList = PlaceListManager.currentFavPlacesList;

      // --- Фильтруем список ----
      setState(() {
        placesFavList.filterLists(
            placesFavList.generateMapForFilter(
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

            setState(() {
              refresh = true;
            });

            placesFavList = PlaceList();

            if (UserCustom.currentUser?.uid != null || UserCustom.currentUser?.uid != ''){

              placesFavList = await placesFavList.getFavListFromDb(UserCustom.currentUser!.uid, refresh: true);

              setState(() {
                placesFavList.filterLists(
                    placesFavList.generateMapForFilter(
                        placeCategoryFromFilter,
                        cityFromFilter,
                        haveEventsFromFilter,
                        nowIsOpenFromFilter,
                        havePromosFromFilter
                    )
                );
              });
            }

            setState(() {
              refresh = false;
            });

          },
          child: Stack (
            children: [
              if (UserCustom.currentUser?.uid == null || UserCustom.currentUser?.uid == '') Center(
                child: Text(
                  'Чтобы добавлять места в избранные, нужно зарегистрироваться',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              )
              else if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка мест')
              else if (refresh) Center(
                child: Text(
                  'Подожди, идет обновление',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
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
                          placesFavList.sortEntitiesList(_selectedSortingOption);
                        });
                      },
                      sortingItems: Place.emptyPlace.getPlaceSortingOptionsList(),
                    ),

                    // ---- Если список заведений пустой -----

                    if (placesFavList.placeList.isEmpty) Expanded(
                        child: ListView.builder(
                            padding: const EdgeInsets.all(15.0),
                            itemCount: 1,
                            itemBuilder: (context, index) {
                              return const Column(
                                  children: [
                                    Center(
                                      child: Text('Пусто'),
                                    )
                                  ]
                              );
                            }
                        )
                    ),

                    // ---- Если список заведений не пустой -----

                    if (placesFavList.placeList.isNotEmpty) Expanded(
                        child: ListView.builder(
                            padding: const EdgeInsets.all(15.0),
                            itemCount: placesFavList.placeList.length,
                            itemBuilder: (context, index) {
                              return CardWidgetForEventPromoPlaces(
                                // TODO Сделать обновление иконки избранного и счетчика при возврате из экрана просмотра заведения
                                place: placesFavList.placeList[index],
                                height: 450,

                                onTap: () async {

                                  final results = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlaceViewScreen(placeId: placesFavList.placeList[index].id),
                                    ),
                                  );

                                  if (results != null) {

                                    placesFavList = PlaceListManager.currentFavPlacesList;
                                    setState(() {

                                      placesFavList.placeList[index].inFav = results[0];
                                      placesFavList.placeList[index].addedToFavouritesCount = results[1];

                                      placesFavList.filterLists(
                                          placesFavList.generateMapForFilter(
                                              placeCategoryFromFilter,
                                              cityFromFilter,
                                              haveEventsFromFilter,
                                              nowIsOpenFromFilter,
                                              havePromosFromFilter
                                          )
                                      );
                                    });
                                  }
                                },

                                // --- Функция на нажатие на карточке кнопки ИЗБРАННОЕ ---
                                onFavoriteIconPressed: () async {

                                  // TODO Сделать проверку на подтвержденный Email
                                  // ---- Если не зарегистрирован или не вошел ----
                                  if (UserCustom.currentUser?.uid == '' || UserCustom.currentUser?.uid == null)
                                  {
                                    showSnackBar('Чтобы добавлять в избранное, нужно зарегистрироваться!', AppColors.attentionRed, 2);
                                  }

                                  // --- Если пользователь залогинен -----
                                  else {

                                    // --- Если уже в избранном ----
                                    if (placesFavList.placeList[index].inFav!)
                                    {

                                      // ---- Инициализируем счетчик -----
                                      int favCounter = placesFavList.placeList[index].addedToFavouritesCount!;

                                      setState(() {
                                        loading = true;
                                        // Обновляем текущий список
                                        placesFavList.placeList[index].inFav = false;
                                        favCounter --;
                                        placesFavList.placeList[index].addedToFavouritesCount = favCounter;
                                        // Обновляем общий список из БД
                                        placesFavList.placeList[index].updateCurrentListFavInformation();

                                      });

                                      String resDel = await placesFavList.placeList[index].deleteFromFav();

                                      setState(() {
                                        placesFavList = PlaceListManager.currentFavPlacesList;
                                        loading = false;
                                      });

                                      if (resDel == 'success'){
                                        showSnackBar('Удалено из избранных', AppColors.attentionRed, 1);
                                      } else {
                                        // Если удаление из избранных не прошло, показываем сообщение
                                        showSnackBar(resDel, AppColors.attentionRed, 1);
                                      }
                                    }
                                    else {
                                      // --- Если заведение не в избранном ----

                                      // -- Добавляем в избранное ----
                                      String res = await placesFavList.placeList[index].addToFav();
                                      // ---- Инициализируем счетчик добавивших в избранное
                                      int favCounter = placesFavList.placeList[index].addedToFavouritesCount!;

                                      if (res == 'success') {
                                        // --- Если добавилось успешно, так же обновляем текущий список и список из БД
                                        setState(() {
                                          // Обновляем текущий список
                                          placesFavList.placeList[index].inFav = true;
                                          favCounter ++;
                                          placesFavList.placeList[index].addedToFavouritesCount = favCounter;

                                          placesFavList.placeList[index].updateCurrentListFavInformation();

                                          placesFavList = PlaceList();
                                          placesFavList = PlaceListManager.currentFavPlacesList;

                                        });

                                        showSnackBar('Добавлено в избранные', Colors.green, 1);

                                      } else {
                                        // Если добавление прошло неудачно, отображаем всплывающее окно
                                        showSnackBar(res, AppColors.attentionRed, 1);
                                      }
                                    }
                                  }
                                },
                              );
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
        placesFavList.placeList = [];

        // ---- Обновляем счетчик выбранных настроек ----
        _setFiltersCount(placeCategoryFromFilter, cityFromFilter, nowIsOpenFromFilter, haveEventsFromFilter, havePromosFromFilter);

      });

      // --- Заново подгружаем список из БД ---
      //List<Place> tempList = [];
      placesFavList.placeList = PlaceListManager.currentFavPlacesList.placeList;

      // --- Фильтруем список согласно новым выбранным данным из фильтра ----
      // --- Фильтруем список ----
      setState(() {
        placesFavList.filterLists(
            placesFavList.generateMapForFilter(
                placeCategoryFromFilter,
                cityFromFilter,
                haveEventsFromFilter,
                nowIsOpenFromFilter,
                havePromosFromFilter
            )
        );
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
}