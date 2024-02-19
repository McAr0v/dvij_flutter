import 'package:dvij_flutter/events/event_category_class.dart';
import 'package:dvij_flutter/places/place_category_class.dart';
import 'package:dvij_flutter/places/place_list_class.dart';
import 'package:flutter/material.dart';
import '../../cities/city_class.dart';
import '../../places/place_class.dart';
import '../../themes/app_colors.dart';

class PlacePickerPage extends StatefulWidget {
  final PlaceList places;

  PlacePickerPage({required this.places});

  @override
  _PlacePickerPageState createState() => _PlacePickerPageState();
}

class _PlacePickerPageState extends State<PlacePickerPage> {
  TextEditingController searchController = TextEditingController();
  List<Place> filteredPlaces = [];

  @override
  void initState() {
    super.initState();
    filteredPlaces = List.from(widget.places.placeList);
  }

  void updateFilteredCategories(String query) {
    setState(() {
      filteredPlaces = widget.places.placeList
          .where((category) =>
          category.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground.withOpacity(0.5),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.greyBackground,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Выбери заведение',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Поиск заведения...',
                  ),
                  onChanged: (value) {
                    updateFilteredCategories(value);
                  },
                ),
              ),
              SizedBox(height: 8.0),

              if (widget.places.placeList.isEmpty) Expanded(
                  child: Container (
                    padding: EdgeInsets.all(15),
                    //color: AppColors.greyOnBackground,
                    decoration: BoxDecoration(
                      color: AppColors.greyOnBackground,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text (
                      'У тебя еще нет созданных заведений. Создай заведение или попроси администратора твоего заведения добавить тебя в качестве организатора, чтобы иметь возможность ссылаться на это заведение',
                      style: Theme.of(context).textTheme.bodyMedium,
                      softWrap: true,
                    ),
                  )
              ),

              if (widget.places.placeList.isNotEmpty) Expanded(
                  child: Container (
                    padding: EdgeInsets.all(15),
                    //color: AppColors.greyOnBackground,
                    decoration: BoxDecoration(
                      color: AppColors.greyOnBackground,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: SingleChildScrollView(
                      //padding: EdgeInsets.all(15),
                      child: ListBody(
                        children: filteredPlaces.map((Place place) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(place);
                            },
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(place.name),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}