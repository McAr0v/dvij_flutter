import 'package:dvij_flutter/classes/ads/ad_admin_class.dart';
import 'package:dvij_flutter/classes/city_class.dart';
import 'package:dvij_flutter/classes/pair.dart';
import 'package:dvij_flutter/classes/place_category_class.dart';
import 'package:dvij_flutter/classes/place_class.dart';
import 'package:dvij_flutter/elements/text_and_icons_widgets/headline_and_desc.dart';
import 'package:dvij_flutter/elements/places_elements/place_card_widget.dart';
import 'package:dvij_flutter/elements/places_elements/place_filter_page.dart';
import 'package:dvij_flutter/screens/places/place_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../classes/ads/ad_user_class.dart';
import '../../classes/place_sorting_options.dart';
import '../../classes/user_class.dart';
import '../../elements/custom_snack_bar.dart';
import '../../elements/loading_screen.dart';


// ---- ЭКРАН ЛЕНТЫ ЗАВЕДЕНИЙ ------

class PlacesFeedPage extends StatefulWidget {
  const PlacesFeedPage({Key? key}) : super(key: key);

  @override
  _PlacesFeedPageState createState() => _PlacesFeedPageState();
}

class _PlacesFeedPageState extends State<PlacesFeedPage> {
  late List<Place> placesList; // Список мест
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

  // Индекс для корректного отображения элементов ленты с учетом рекламной записи
  //int indexWithAddCountCorrection = 0;

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
      if (UserCustom.currentUser!.city != ''){
        City usersCity = City.getCityByIdFromList(UserCustom.currentUser!.city);
        setState(() {
          cityFromFilter = usersCity;
        });
      }
    }

    // ---- Устанавливаем счетчик выбранных в фильтре настроек ----

    _setFiltersCount(placeCategoryFromFilter, cityFromFilter, nowIsOpenFromFilter, haveEventsFromFilter, havePromosFromFilter);

    // ----- Работаем со списком заведений -----

    // ---- Если список пуст ----
    if (Place.currentFeedPlaceList.isEmpty){

      // ---- Считываем с БД заведения -----
      List<Place> tempPlacesList = await Place.getAllPlaces();

      // --- Фильтруем список -----
      setState(() {
        placesList = Place.filterPlaces(placeCategoryFromFilter, cityFromFilter, nowIsOpenFromFilter, haveEventsFromFilter, havePromosFromFilter, tempPlacesList);
      });

    } else {
      // --- Если список не пустой ----
      // --- Подгружаем готовый список ----
      List<Place> tempList = [];
      tempList = Place.currentFeedPlaceList;

      // --- Фильтруем список ----
      setState(() {
        placesList = Place.filterPlaces(placeCategoryFromFilter, cityFromFilter, nowIsOpenFromFilter, haveEventsFromFilter, havePromosFromFilter, tempList);

      });
    }

    // Подгружаем список категорий заведений
    placeCategoriesList = PlaceCategory.currentPlaceCategoryList;

    // --- Считываем индексы, где будет стоять реклама ----

    adIndexesList = AdUser.getAdIndexesList(adList, adStep, firstIndexOfAd);

    setState(() {
      allElementsList = AdUser.generateIndexedList(adIndexesList, placesList.length);
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

            setState(() {
              refresh = true;
            });

            placesList = [];

            List<Place> tempPlacesList = await Place.getAllPlaces();

            setState(() {
              placesList = Place.filterPlaces(placeCategoryFromFilter, cityFromFilter, nowIsOpenFromFilter, haveEventsFromFilter, havePromosFromFilter, tempPlacesList);
              allElementsList = AdUser.generateIndexedList(adIndexesList, placesList.length);
            });

            setState(() {
              refresh = false;
            });

          },
          child: Stack (
            children: [
              if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка мест')
              else if (refresh) Center(
                child: Text(
                  'Подожди, идет загрузка мест',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
              else Column(
                  children: [
                    // ---- Фильтр и сортировка -----
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                        color: AppColors.greyOnBackground,
                        child: Row (
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            // ---- Фильтр -----

                            GestureDetector(
                              onTap: (){
                                _showFilterDialog();
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Фильтр ${filterCount > 0 ? '($filterCount)' : ''}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: filterCount > 0 ? AppColors.brandColor : AppColors.white),
                                  ),

                                  const SizedBox(width: 20,),

                                  Icon(
                                    FontAwesomeIcons.filter,
                                    size: 20,
                                    color: filterCount > 0 ? AppColors.brandColor : AppColors.white ,
                                  )
                                ],
                              ),
                            ),

                            // ------ Сортировка ------

                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: DropdownButton<PlaceSortingOption>(
                                style: Theme.of(context).textTheme.bodySmall,
                                isExpanded: true,
                                value: _selectedSortingOption,
                                onChanged: (PlaceSortingOption? newValue) {
                                  setState(() {
                                    _selectedSortingOption = newValue!;
                                    Place.sortPlaces(_selectedSortingOption, placesList);
                                  });
                                },
                                items: const [
                                  DropdownMenuItem(
                                    value: PlaceSortingOption.nameAsc,
                                    child: Text('По имени: А-Я'),
                                  ),
                                  DropdownMenuItem(
                                    value: PlaceSortingOption.nameDesc,
                                    child: Text('По имени: Я-А'),
                                  ),
                                  DropdownMenuItem(
                                    value: PlaceSortingOption.favCountAsc,
                                    child: Text('В избранном: по возрастанию'),
                                  ),
                                  DropdownMenuItem(
                                    value: PlaceSortingOption.favCountDesc,
                                    child: Text('В избранном: по убыванию'),
                                  ),
                                  DropdownMenuItem(
                                    value: PlaceSortingOption.promoCountAsc,
                                    child: Text('Акции: по возрастанию'),
                                  ),
                                  DropdownMenuItem(
                                    value: PlaceSortingOption.promoCountDesc,
                                    child: Text('Акции: по убыванию'),
                                  ),
                                  DropdownMenuItem(
                                    value: PlaceSortingOption.eventCountAsc,
                                    child: Text('Мероприятия: по возрастанию'),
                                  ),
                                  DropdownMenuItem(
                                    value: PlaceSortingOption.eventCountDesc,
                                    child: Text('Мероприятия: по убыванию'),
                                  ),
                                ],
                              ),
                            )
                          ],
                        )
                    ),

                    // ---- Если список заведений пустой -----

                    if (placesList.isEmpty) Expanded(
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

                    if (placesList.isNotEmpty) Expanded(

                        child: ListView.builder(
                            padding: const EdgeInsets.all(15.0),
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

                                return PlaceCardWidget(

                                place: placesList[indexWithAddCountCorrection],

                                onTap: () async {

                                  final results = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlaceViewScreen(placeId: placesList[indexWithAddCountCorrection].id),
                                    ),
                                  );

                                  if (results != null) {
                                    setState(() {
                                      placesList[indexWithAddCountCorrection].inFav = results[0].toString();
                                      placesList[indexWithAddCountCorrection].addedToFavouritesCount = results[1].toString();
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
                                    if (placesList[indexWithAddCountCorrection].inFav == 'true')
                                    {
                                      // --- Удаляем из избранных ---
                                      String resDel = await Place.deletePlaceFromFav(placesList[indexWithAddCountCorrection].id);
                                      // ---- Инициализируем счетчик -----
                                      int favCounter = int.parse(placesList[indexWithAddCountCorrection].addedToFavouritesCount!);

                                      if (resDel == 'success'){
                                        // Если удаление успешное, обновляем 2 списка - текущий на экране, и общий загруженный из БД
                                        setState(() {
                                          // Обновляем текущий список
                                          placesList[indexWithAddCountCorrection].inFav = 'false';
                                          favCounter --;
                                          placesList[indexWithAddCountCorrection].addedToFavouritesCount = favCounter.toString();
                                          // Обновляем общий список из БД
                                          Place.updateCurrentPlaceListFavInformation(placesList[indexWithAddCountCorrection].id, favCounter.toString(), 'false');

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
                                      String res = await Place.addPlaceToFav(placesList[indexWithAddCountCorrection].id);
                                      // ---- Инициализируем счетчик добавивших в избранное
                                      int favCounter = int.parse(placesList[indexWithAddCountCorrection].addedToFavouritesCount!);

                                      if (res == 'success') {
                                        // --- Если добавилось успешно, так же обновляем текущий список и список из БД
                                        setState(() {
                                          // Обновляем текущий список
                                          placesList[indexWithAddCountCorrection].inFav = 'true';
                                          favCounter ++;
                                          placesList[indexWithAddCountCorrection].addedToFavouritesCount = favCounter.toString();
                                          // Обновляем список из БД
                                          Place.updateCurrentPlaceListFavInformation(placesList[indexWithAddCountCorrection].id, favCounter.toString(), 'true');
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
        placesList = [];

        // ---- Обновляем счетчик выбранных настроек ----
        _setFiltersCount(placeCategoryFromFilter, cityFromFilter, nowIsOpenFromFilter, haveEventsFromFilter, havePromosFromFilter);

      });

      // --- Заново подгружаем список из БД ---
      List<Place> tempList = [];
      tempList = Place.currentFeedPlaceList;

      // --- Фильтруем список согласно новым выбранным данным из фильтра ----
      setState(() {
        placesList = Place.filterPlaces(placeCategoryFromFilter, cityFromFilter, nowIsOpenFromFilter, haveEventsFromFilter, havePromosFromFilter, tempList);
        allElementsList = AdUser.generateIndexedList(adIndexesList, placesList.length);
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