
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
import '../../elements/places_elements/place_category_picker_page.dart'; // Импортируйте библиотеку Firebase Database



class PlacesFeedPage extends StatefulWidget {
  const PlacesFeedPage({Key? key}) : super(key: key);

  @override
  _PlacesFeedPageState createState() => _PlacesFeedPageState();
}



class _PlacesFeedPageState extends State<PlacesFeedPage> {
  late List<Place> placesList;
  late List<PlaceCategory> placeCategoriesList;

  PlaceCategory placeCategoryFromFilter = PlaceCategory(name: '', id: '');
  City cityFromFilter = City(name: '', id: '');
  bool nowIsOpenFromFilter = false;
  bool haveEventsFromFilter = false;
  bool havePromosFromFilter = false;

  SortingOption _selectedSortingOption = SortingOption.nameAsc;

  // Переменная, включающая экран загрузки
  bool loading = true;
  bool refresh = false;

  int filterCount = 0;

  @override
  void initState(){

    super.initState();
    // Call the asynchronous initialization method
    _initializeData();
  }

  // Asynchronous initialization method
  Future<void> _initializeData() async {


    // Enable loading screen
    setState(() {
      loading = true;
    });

    if (UserCustom.currentUser != null){
      if (UserCustom.currentUser!.city != ''){
        City usersCity = City.getCityByIdFromList(UserCustom.currentUser!.city);
        setState(() {
          cityFromFilter = usersCity;
          filterCount++;
        });
      }
    }

    if (Place.currentFeedPlaceList.isEmpty){

      List<Place> tempPlacesList = await Place.getAllPlaces(
        //placeCategoryFromFilter, cityFromFilter, nowIsOpenFromFilter, haveEventsFromFilter, havePromosFromFilter
      );
      setState(() {
        placesList = Place.filterPlaces(placeCategoryFromFilter, cityFromFilter, nowIsOpenFromFilter, haveEventsFromFilter, havePromosFromFilter, tempPlacesList);
      });
    } else {
      List<Place> tempList = [];
      tempList = Place.currentFeedPlaceList;

      setState(() {
        placesList = Place.filterPlaces(placeCategoryFromFilter, cityFromFilter, nowIsOpenFromFilter, haveEventsFromFilter, havePromosFromFilter, tempList);
      });
    }


    placeCategoriesList = PlaceCategory.currentPlaceCategoryList;

    // Disable loading screen
    setState(() {
      loading = false;
    });
  }

  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator (

          onRefresh: () async {
            setState(() {
              refresh = true;
            });

            placesList = [];

            List<Place> tempPlacesList = await Place.getAllPlaces(
              //placeCategoryFromFilter, cityFromFilter, nowIsOpenFromFilter, haveEventsFromFilter, havePromosFromFilter
            );
            setState(() {
              placesList = Place.filterPlaces(placeCategoryFromFilter, cityFromFilter, nowIsOpenFromFilter, haveEventsFromFilter, havePromosFromFilter, tempPlacesList);
            });

            /*placesList = await Place.getAllPlaces(
                //placeCategoryFromFilter, cityFromFilter, nowIsOpenFromFilter, haveEventsFromFilter, havePromosFromFilter
            );*/

            setState(() {
              refresh = false;
            });

          },
          child: Stack (
            children: [

              // --- ЕСЛИ ЭКРАН ЗАГРУЗКИ -----
              if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка мест')
              else if (refresh) Center(
                child: Text('Подожди, идет загрузка мест', style: Theme.of(context).textTheme.bodyMedium,),
              )
              // --- ЕСЛИ ГОРОДА ЗАГРУЗИЛИСЬ
              else Column(
                  children: [
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20), // Пример задания паддингов
                        color: AppColors.greyOnBackground, // Пример задания фона
                        child: Row (
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: (){
                                //showSnackBar('Нажато на фильтр', Colors.green, 1);
                                _showFilterDialog();
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Фильтр ${filterCount > 0 ? '($filterCount)' : ''}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: filterCount > 0 ? AppColors.brandColor : AppColors.white ),
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
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: DropdownButton<SortingOption>(
                                style: Theme.of(context).textTheme.bodySmall,
                                isExpanded: true,
                                value: _selectedSortingOption,
                                onChanged: (SortingOption? newValue) {
                                  setState(() {
                                    _selectedSortingOption = newValue!;
                                    Place.sortPlaces(_selectedSortingOption, placesList);
                                    // Здесь вы можете добавить логику для обработки изменения сортировки
                                    // Например, вызвать функцию для сортировки вашего списка
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

                    if (placesList.isEmpty) Expanded(
                        child: ListView.builder(
                          // Открываем создатель списков
                            padding: const EdgeInsets.all(15.0),
                            itemCount: 1,
                            // Шаблоны для элементов
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

                    if (placesList.isNotEmpty) Expanded(
                        child: ListView.builder(
                          // Открываем создатель списков
                            padding: const EdgeInsets.all(15.0),
                            itemCount: placesList.length,
                            // Шаблоны для элементов
                            itemBuilder: (context, index) {
                              return PlaceCardWidget(
                                // TODO Сделать обновление иконки избранного и счетчика при возврате из экрана просмотра заведения
                                place: placesList[index],
                                onFavoriteIconPressed: () async {

                                  // TODO Сделать проверку на подтвержденный Email
                                  if (UserCustom.currentUser?.uid == '' || UserCustom.currentUser?.uid == null)
                                  {

                                    showSnackBar('Чтобы добавлять в избранное, нужно зарегистрироваться!', AppColors.attentionRed, 2);

                                  }

                                  else {

                                    if (placesList[index].inFav == 'true')
                                    {

                                      String resDel = await Place.deletePlaceFromFav(placesList[index].id);

                                      int favCounter = int.parse(placesList[index].addedToFavouritesCount!);


                                      if (resDel == 'success'){
                                        setState(() {
                                          placesList[index].inFav = 'false';
                                          favCounter --;
                                          placesList[index].addedToFavouritesCount = favCounter.toString();
                                        });

                                        showSnackBar('Удалено из избранных', AppColors.attentionRed, 1);
                                      } else {
                                        showSnackBar(resDel, AppColors.attentionRed, 1);
                                      }
                                    }
                                    else {
                                      String res = await Place.addPlaceToFav(placesList[index].id);
                                      int favCounter = int.parse(placesList[index].addedToFavouritesCount!);

                                      if (res == 'success') {

                                        setState(() {
                                          placesList[index].inFav = 'true';
                                          favCounter ++;
                                          placesList[index].addedToFavouritesCount = favCounter.toString();
                                        });

                                        showSnackBar('Добавлено в избранные', Colors.green, 1);

                                      } else {

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

  void _setFiltersCount(
  PlaceCategory placeCategoryFromFilter,
  City cityFromFilter,
  bool nowIsOpenFromFilter,
  bool haveEventsFromFilter,
  bool havePromosFromFilter,
      ){

    int count = 0;

    if (placeCategoryFromFilter.name != ''){
      count++;
    }

    if (cityFromFilter.name != ''){
      count++;
    }

    if (nowIsOpenFromFilter) count++;

    if (haveEventsFromFilter) count++;

    if (havePromosFromFilter) count++;

    setState(() {
      filterCount = count;
    });

  }

  void _showFilterDialog() async {
    final results = await Navigator.of(context).push(_createPopupFilter(placeCategoriesList));

    if (results != null) {
      setState(() {
        loading = true;
        cityFromFilter = results[0];
        placeCategoryFromFilter = results[1];
        nowIsOpenFromFilter = results [2];
        haveEventsFromFilter = results [3];
        havePromosFromFilter = results [4];
        placesList = [];

        _setFiltersCount(placeCategoryFromFilter, cityFromFilter, nowIsOpenFromFilter, haveEventsFromFilter, havePromosFromFilter);

      });

      List<Place> tempList = [];
      tempList = Place.currentFeedPlaceList;

      setState(() {
        placesList = Place.filterPlaces(placeCategoryFromFilter, cityFromFilter, nowIsOpenFromFilter, haveEventsFromFilter, havePromosFromFilter, tempList);
      });
      print('${results[0]}, ${results[1]}, ${results[2]}, ${results[3]}, ${results[4]}');



      setState(() {
        loading = false;
      });

    }
  }

  Route _createPopupFilter(List<PlaceCategory> categories) {
    return PageRouteBuilder(

      pageBuilder: (context, animation, secondaryAnimation) {

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
      transitionDuration: Duration(milliseconds: 100),

    );
  }

}