import 'package:dvij_flutter/classes/city_class.dart';
import 'package:dvij_flutter/classes/place_category_class.dart';
import 'package:dvij_flutter/classes/place_class.dart';
import 'package:dvij_flutter/elements/places_elements/place_card_widget.dart';
import 'package:dvij_flutter/elements/places_elements/place_filter_page.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../classes/user_class.dart';
import '../../elements/custom_snack_bar.dart';
import '../../elements/loading_screen.dart';
import '../../elements/places_elements/place_category_picker_page.dart'; // Импортируйте библиотеку Firebase Database

enum SortingOption {
  nameAsc,
  nameDesc,
  promoCountAsc,
  promoCountDesc,
  eventCountAsc,
  eventCountDesc,
}

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
        cityFromFilter = usersCity;
      }
    }

    placesList = await Place.getAllPlaces();
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
      body: Stack (
        children: [

          // --- ЕСЛИ ЭКРАН ЗАГРУЗКИ -----
          if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка мест')
          // --- ЕСЛИ ГОРОДОВ НЕТ -----
          else if (placesList.isEmpty) const Center(child: Text('Список мест пуст'))
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
                              'Фильтр',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),

                            const SizedBox(width: 20,),

                            const Icon(
                              FontAwesomeIcons.filter,
                              size: 20,
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
                      /*GestureDetector(
                        onTap: (){
                          //showSnackBar('Нажато на фильтр', Colors.green, 1);
                          _showFilterDialog();
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            Text(
                              'Сортировка',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),

                            const SizedBox(width: 20,),

                            const Icon(
                              FontAwesomeIcons.sort,
                              size: 20,
                            )

                          ],
                        ),
                      ),*/
                    ],
                  )
                ),

                Expanded(
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
    );
  }

  void _showFilterDialog() async {
    final results = await Navigator.of(context).push(_createPopupFilter(placeCategoriesList));

    if (results != null) {
      setState(() {
        cityFromFilter = results[0];
        placeCategoryFromFilter = results[1];
        nowIsOpenFromFilter = results [2];
        haveEventsFromFilter = results [3];
        havePromosFromFilter = results [4];
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