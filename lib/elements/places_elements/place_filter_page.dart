import 'package:dvij_flutter/classes/place_category_class.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/elements/places_elements/place_category_element_in_edit_place_screen.dart';
import 'package:dvij_flutter/elements/places_elements/place_category_picker_page.dart';
import 'package:flutter/material.dart';
import '../../classes/city_class.dart';
import '../../themes/app_colors.dart';
import '../choose_dialogs/city_choose_dialog.dart';
import '../cities_elements/city_element_in_edit_screen.dart';
enum SortingOption {
  nameAsc,
  nameDesc,
  promoCountAsc,
  promoCountDesc,
  eventCountAsc,
  eventCountDesc,
}
class PlaceFilterPage extends StatefulWidget {
  final List<PlaceCategory> categories;
  PlaceCategory chosenCategory;
  City chosenCity;
  bool nowIsOpen;
  bool haveEvents;
  bool havePromos;

  PlaceFilterPage({
    required this.categories,
    required this.chosenCategory,
    required this.chosenCity,
    required this.nowIsOpen,
    required this.havePromos,
    required this.haveEvents
  });

  @override
  _PlaceFilterPageState createState() => _PlaceFilterPageState();
}

class _PlaceFilterPageState extends State<PlaceFilterPage> {

  List<PlaceCategory> categories = [];
  PlaceCategory chosenCategory = PlaceCategory(name: '', id: '');
  City chosenCity = City(name: '', id: '');
  List<City> _cities = [];

  bool nowIsOpen = false;
  bool haveEvents = false;
  bool havePromos = false;
  SortingOption _selectedSortingOption = SortingOption.nameAsc;

  @override
  void initState() {
    super.initState();
    categories = List.from(widget.categories);
    _cities = City.currentCityList;
    chosenCity = widget.chosenCity;
    chosenCategory = widget.chosenCategory;
    nowIsOpen = widget.nowIsOpen;
    haveEvents = widget.haveEvents;
    havePromos = widget.havePromos;
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
            color: AppColors.greyOnBackground,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Фильтр и сортировка:',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Expanded(
                  child: SingleChildScrollView (
                    child: Container (
                      padding: EdgeInsets.all(15),
                      //color: AppColors.greyOnBackground,
                      decoration: BoxDecoration(
                        color: AppColors.greyBackground,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16.0),

                          if (chosenCity.id == '') CityElementInEditScreen(
                            cityName: 'Город не выбран',
                            onActionPressed: () {
                              //_showCityPickerDialog();
                              _showCityPickerDialog();
                            },
                          ),

                          if (chosenCity.id != "") CityElementInEditScreen(
                            cityName: chosenCity.name,
                            onActionPressed: () {
                              //_showCityPickerDialog();
                              _showCityPickerDialog();
                            },
                          ),

                          const SizedBox(height: 16.0),

                          if (chosenCategory.id == '') PlaceCategoryElementInEditPlaceScreen(
                            categoryName: 'Категория не выбрана',
                            onActionPressed: () {
                              //_showCityPickerDialog();
                              _showCategoryPickerDialog();
                            },
                          ),

                          if (chosenCategory.id != "") PlaceCategoryElementInEditPlaceScreen(
                            categoryName: chosenCategory.name,
                            onActionPressed: () {
                              //_showCityPickerDialog();
                              _showCategoryPickerDialog();
                            },
                          ),

                          const SizedBox(height: 16.0),

                          Row(
                            children: [

                              Checkbox(
                                value: nowIsOpen,
                                onChanged: (value) {
                                  toggleCheckBox('nowIsOpen');
                                },
                              ),
                              // ---- Надпись у чекбокса -----
                              Text(
                                'Сейчас открыто',
                                style: Theme.of(context).textTheme.bodyMedium,
                              )

                            ],
                          ),

                          Row(
                            children: [

                              Checkbox(
                                value: haveEvents,
                                onChanged: (value) {
                                  toggleCheckBox('haveEvents');
                                },
                              ),
                              // ---- Надпись у чекбокса -----
                              Text(
                                'Есть мероприятия',
                                style: Theme.of(context).textTheme.bodyMedium,
                              )

                            ],
                          ),

                          Row(
                            children: [

                              Checkbox(
                                value: havePromos,
                                onChanged: (value) {
                                  toggleCheckBox('havePromos');
                                },
                              ),
                              // ---- Надпись у чекбокса -----
                              Text(
                                'Есть акции',
                                style: Theme.of(context).textTheme.bodyMedium,
                              )

                            ],
                          ),
                        ],
                      ),
                    ),
                  )
              ),
              //const SizedBox(height: 20.0),

              CustomButton(
                buttonText: 'Применить фильтр',
                onTapMethod: (){
                  List<dynamic> arguments = [chosenCity, chosenCategory, nowIsOpen, haveEvents, havePromos];
                  Navigator.of(context).pop(arguments);
                },
              ),

              const SizedBox(height: 20.0),

              CustomButton(
                buttonText: 'Выйти из фильтра',
                state: 'secondary',
                onTapMethod: (){
                  setState(() {
                    Navigator.of(context).pop();
                  });
                },
              ),

              const SizedBox(height: 50.0),

              CustomButton(
                buttonText: 'Очистить фильтр',
                state: 'error',
                onTapMethod: (){
                  setState(() {
                    chosenCategory = PlaceCategory(name: '', id: '');
                    chosenCity = City(name: '', id: '');
                    nowIsOpen = false;
                    havePromos = false;
                    haveEvents = false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void toggleCheckBox(String checkBoxName) {
    setState(() {
      switch (checkBoxName){
        case 'nowIsOpen': {
          nowIsOpen = !nowIsOpen;
        }
        case 'haveEvents': {
          haveEvents = !haveEvents;
        }
        case 'havePromos': {
          havePromos = !havePromos;
        }
      }
    });
  }


  void _showCategoryPickerDialog() async {
    final selectedCategory = await Navigator.of(context).push(_createPopupCategory(categories));

    if (selectedCategory != null) {
      setState(() {
        chosenCategory = selectedCategory;
      });
    }
  }

  Route _createPopupCategory(List<PlaceCategory> categories) {
    return PageRouteBuilder(

      pageBuilder: (context, animation, secondaryAnimation) {

        return PlaceCategoryPickerPage(categories: categories);
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

  void _showCityPickerDialog() async {
    final selectedCity = await Navigator.of(context).push(_createPopup(_cities));

    if (selectedCity != null) {
      setState(() {
        chosenCity = selectedCity;
      });
      print("Selected city: ${selectedCity.name}, ID: ${selectedCity.id}");
    }
  }

  Route _createPopup(List<City> cities) {
    return PageRouteBuilder(

      pageBuilder: (context, animation, secondaryAnimation) {

        return CityPickerPage(cities: cities);
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