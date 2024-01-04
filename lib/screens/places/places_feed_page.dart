import 'package:dvij_flutter/classes/place_class.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/elements/places_elements/place_card_widget.dart';
import 'package:dvij_flutter/screens/places/create_or_edit_place_screen.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:firebase_database/firebase_database.dart';

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
                  return PlaceCardWidget(place: placesList[index]);
                }
            ),
        ],
      ),
    );
  }
}