import 'package:dvij_flutter/classes/place_class.dart';
import 'package:dvij_flutter/elements/places_elements/place_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import '../../classes/user_class.dart';
import '../../elements/custom_snack_bar.dart';
import '../../elements/loading_screen.dart'; // Импортируйте библиотеку Firebase Database

class PlacesFeedPage extends StatefulWidget {
  const PlacesFeedPage({Key? key}) : super(key: key);

  @override
  _PlacesFeedPageState createState() => _PlacesFeedPageState();
}



class _PlacesFeedPageState extends State<PlacesFeedPage> {
  late List<Place> placesList;

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

    placesList = await Place.getAllPlaces();

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
          else ListView.builder(
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
            ),
        ],
      ),
    );
  }
}