import 'package:dvij_flutter/classes/city_class.dart';
import 'package:dvij_flutter/classes/place_category_class.dart';
import 'package:dvij_flutter/classes/place_class.dart';
import 'package:dvij_flutter/elements/places_elements/place_card_widget.dart';
import 'package:dvij_flutter/elements/places_elements/place_filter_page.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../classes/place_sorting_options.dart';
import '../../classes/user_class.dart';
import '../../elements/custom_snack_bar.dart';
import '../../elements/loading_screen.dart';
import 'create_or_edit_place_screen.dart';


// ---- ЭКРАН ЛЕНТЫ ЗАВЕДЕНИЙ ------

class PlacesMyPage extends StatefulWidget {
  const PlacesMyPage({Key? key}) : super(key: key);

  @override
  _PlacesMyPageState createState() => _PlacesMyPageState();
}



class _PlacesMyPageState extends State<PlacesMyPage> {
  late List<Place> placesMyList; // Список мест
  late List<PlaceCategory> placeCategoriesList; // Список категорий мест

  // --- Переменные фильтра по умолчанию ----

  PlaceCategory placeCategoryFromFilter = PlaceCategory(name: '', id: '');
  City cityFromFilter = City(name: '', id: '');
  bool nowIsOpenFromFilter = false;
  bool haveEventsFromFilter = false;
  bool havePromosFromFilter = false;


  Place placeEmpty = Place.empty();

  // --- Переменная сортировки по умолчанию ----

  SortingOption _selectedSortingOption = SortingOption.nameAsc;

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

    /*
    // ---- Подгружаем город в фильтр из данных пользователя ---
    if (UserCustom.currentUser != null){
      if (UserCustom.currentUser!.city != ''){
        City usersCity = City.getCityByIdFromList(UserCustom.currentUser!.city);
        setState(() {
          cityFromFilter = usersCity;
        });
      }
    }*/

    // ---- Устанавливаем счетчик выбранных в фильтре настроек ----

    _setFiltersCount(placeCategoryFromFilter, cityFromFilter, nowIsOpenFromFilter, haveEventsFromFilter, havePromosFromFilter);

    // ----- Работаем со списком заведений -----

    // ---- Если список пуст ----
    if (Place.currentMyPlaceList.isEmpty){

      // ---- Считываем с БД заведения -----
      if (UserCustom.currentUser?.uid != null && UserCustom.currentUser?.uid != ''){
        List<Place> tempPlacesList = await Place.getMyPlaces(UserCustom.currentUser!.uid);

        // --- Фильтруем список -----
        setState(() {
          placesMyList = Place.filterPlaces(placeCategoryFromFilter, cityFromFilter, nowIsOpenFromFilter, haveEventsFromFilter, havePromosFromFilter, tempPlacesList);
        });
      }


    } else {
      // --- Если список не пустой ----
      // --- Подгружаем готовый список ----
      List<Place> tempList = [];
      tempList = Place.currentMyPlaceList;

      // --- Фильтруем список ----
      setState(() {
        placesMyList = Place.filterPlaces(placeCategoryFromFilter, cityFromFilter, nowIsOpenFromFilter, haveEventsFromFilter, havePromosFromFilter, tempList);
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

            placesMyList = [];

            if (UserCustom.currentUser?.uid != null || UserCustom.currentUser?.uid != ''){

              List<Place> tempPlacesList = await Place.getMyPlaces(UserCustom.currentUser!.uid);

              setState(() {
                placesMyList = Place.filterPlaces(placeCategoryFromFilter, cityFromFilter, nowIsOpenFromFilter, haveEventsFromFilter, havePromosFromFilter, tempPlacesList);
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
                  'Чтобы создавать места или участвовать в их управлении, нужно зарегистрироваться',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              )
              else if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка мест')
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
                                child: DropdownButton<SortingOption>(
                                  style: Theme.of(context).textTheme.bodySmall,
                                  isExpanded: true,
                                  value: _selectedSortingOption,
                                  onChanged: (SortingOption? newValue) {
                                    setState(() {
                                      _selectedSortingOption = newValue!;
                                      Place.sortPlaces(_selectedSortingOption, placesMyList);
                                    });
                                  },
                                  items: const [
                                    DropdownMenuItem(
                                      value: SortingOption.nameAsc,
                                      child: Text('По имени: А-Я'),
                                    ),
                                    DropdownMenuItem(
                                      value: SortingOption.nameDesc,
                                      child: Text('По имени: Я-А'),
                                    ),
                                    DropdownMenuItem(
                                      value: SortingOption.promoCountAsc,
                                      child: Text('Акции: по возрастанию'),
                                    ),
                                    DropdownMenuItem(
                                      value: SortingOption.promoCountDesc,
                                      child: Text('Акции: по убыванию'),
                                    ),
                                    DropdownMenuItem(
                                      value: SortingOption.eventCountAsc,
                                      child: Text('Мероприятия: по возрастанию'),
                                    ),
                                    DropdownMenuItem(
                                      value: SortingOption.eventCountDesc,
                                      child: Text('Мероприятия: по убыванию'),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )
                      ),

                      // ---- Если список заведений пустой -----

                      if (placesMyList.isEmpty) Expanded(
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

                      if (placesMyList.isNotEmpty) Expanded(
                          child: ListView.builder(
                              padding: const EdgeInsets.all(15.0),
                              itemCount: placesMyList.length,
                              itemBuilder: (context, index) {
                                return PlaceCardWidget(
                                  // TODO Сделать обновление иконки избранного и счетчика при возврате из экрана просмотра заведения
                                  place: placesMyList[index],

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
                                      if (placesMyList[index].inFav == 'true')
                                      {
                                        // --- Удаляем из избранных ---
                                        String resDel = await Place.deletePlaceFromFav(placesMyList[index].id);
                                        // ---- Инициализируем счетчик -----
                                        int favCounter = int.parse(placesMyList[index].addedToFavouritesCount!);

                                        if (resDel == 'success'){
                                          // Если удаление успешное, обновляем 2 списка - текущий на экране, и общий загруженный из БД
                                          setState(() {
                                            // Обновляем текущий список
                                            placesMyList[index].inFav = 'false';
                                            favCounter --;
                                            placesMyList[index].addedToFavouritesCount = favCounter.toString();
                                            // Обновляем списки из БД
                                            Place.updateCurrentPlaceListFavInformation(placesMyList[index].id, favCounter.toString(), 'false');

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
                                        String res = await Place.addPlaceToFav(placesMyList[index].id);
                                        // ---- Инициализируем счетчик добавивших в избранное
                                        int favCounter = int.parse(placesMyList[index].addedToFavouritesCount!);

                                        if (res == 'success') {
                                          // --- Если добавилось успешно, так же обновляем текущий список и список из БД
                                          setState(() {
                                            // Обновляем текущий список
                                            placesMyList[index].inFav = 'true';
                                            favCounter ++;
                                            placesMyList[index].addedToFavouritesCount = favCounter.toString();
                                            // Обновляем списки из БД
                                            Place.updateCurrentPlaceListFavInformation(placesMyList[index].id, favCounter.toString(), 'true');
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
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (UserCustom.currentUser != null && UserCustom.currentUser!.uid != '') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateOrEditPlaceScreen(placeInfo: placeEmpty)),
            );
          } else {

            showSnackBar('Чтобы создать заведение, нужно зарегистрироваться', AppColors.attentionRed, 2);

          }

        },
        backgroundColor: AppColors.brandColor,
        child: const Icon(Icons.add), // Цвет кнопки
      ),
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
        placesMyList = [];

        // ---- Обновляем счетчик выбранных настроек ----
        _setFiltersCount(placeCategoryFromFilter, cityFromFilter, nowIsOpenFromFilter, haveEventsFromFilter, havePromosFromFilter);

      });

      // --- Заново подгружаем список из БД ---
      List<Place> tempList = [];
      tempList = Place.currentMyPlaceList;

      // --- Фильтруем список согласно новым выбранным данным из фильтра ----
      setState(() {
        placesMyList = Place.filterPlaces(placeCategoryFromFilter, cityFromFilter, nowIsOpenFromFilter, haveEventsFromFilter, havePromosFromFilter, tempList);
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