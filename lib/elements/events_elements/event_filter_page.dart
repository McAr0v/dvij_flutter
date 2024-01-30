import 'package:dvij_flutter/classes/event_category_class.dart';
import 'package:dvij_flutter/classes/place_category_class.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/elements/category_element_in_edit_screen.dart';
import 'package:dvij_flutter/elements/events_elements/event_category_picker_page.dart';
import 'package:dvij_flutter/elements/places_elements/place_category_picker_page.dart';
import 'package:flutter/material.dart';
import '../../classes/city_class.dart';
import '../../classes/event_sorting_options.dart';
import '../../classes/place_sorting_options.dart';
import '../../themes/app_colors.dart';
import '../choose_dialogs/city_choose_dialog.dart';
import '../cities_elements/city_element_in_edit_screen.dart';

class EventFilterPage extends StatefulWidget {
  final List<EventCategory> categories;
  EventCategory chosenCategory;
  City chosenCity;
  bool freePrice;
  bool today;
  bool onlyFromPlaceEvents;
  DateTime selectedStartDatePeriod;
  DateTime selectedEndDatePeriod;

  EventFilterPage({super.key,
    required this.categories,
    required this.chosenCategory,
    required this.chosenCity,
    required this.freePrice,
    required this.onlyFromPlaceEvents,
    required this.today,
    required this.selectedStartDatePeriod,
    required this.selectedEndDatePeriod

  });

  @override
  _EventFilterPageState createState() => _EventFilterPageState();
}

class _EventFilterPageState extends State<EventFilterPage> {

  List<EventCategory> categories = [];
  EventCategory chosenCategory = EventCategory(name: '', id: '');
  City chosenCity = City(name: '', id: '');
  List<City> _cities = [];

  bool freePrice = false;
  bool today = false;
  bool onlyFromPlaceEvents = false;
  DateTime selectedStartDatePeriod = DateTime(2100);
  DateTime selectedEndDatePeriod = DateTime(2100);
  //EventSortingOption _selectedSortingOption = EventSortingOption.nameAsc;

  @override
  void initState() {
    super.initState();
    categories = List.from(widget.categories);
    _cities = City.currentCityList;
    chosenCity = widget.chosenCity;
    chosenCategory = widget.chosenCategory;
    freePrice = widget.freePrice;
    today = widget.today;
    onlyFromPlaceEvents = widget.onlyFromPlaceEvents;
    selectedStartDatePeriod = widget.selectedStartDatePeriod;
    selectedEndDatePeriod = widget.selectedEndDatePeriod;
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

                          // TODO Сделать во всех фильтрах иконку крестик сброса отдельного значения, а не всего фильтра

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

                          if (chosenCategory.id == '') CategoryElementInEditScreen(
                            categoryName: 'Категория не выбрана',
                            onActionPressed: () {
                              //_showCityPickerDialog();
                              _showCategoryPickerDialog();
                            },
                          ),

                          if (chosenCategory.id != "") CategoryElementInEditScreen(
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
                                value: freePrice,
                                onChanged: (value) {
                                  toggleCheckBox('freePrice');
                                },
                              ),
                              // ---- Надпись у чекбокса -----
                              Text(
                                'Только бесплатные',
                                style: Theme.of(context).textTheme.bodyMedium,
                              )

                            ],
                          ),

                          Row(
                            children: [

                              Checkbox(
                                value: today,
                                onChanged: (value) {
                                  toggleCheckBox('today');
                                },
                              ),
                              // ---- Надпись у чекбокса -----
                              Text(
                                'Состоится сегодня',
                                style: Theme.of(context).textTheme.bodyMedium,
                              )

                            ],
                          ),

                          Row(
                            children: [

                              Checkbox(
                                value: onlyFromPlaceEvents,
                                onChanged: (value) {
                                  toggleCheckBox('onlyFromPlaceEvents');
                                },
                              ),
                              // ---- Надпись у чекбокса -----
                              Text(
                                'Только мероприятия от заведений',
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
                  List<dynamic> arguments = [chosenCity, chosenCategory, freePrice, today, onlyFromPlaceEvents, selectedStartDatePeriod, selectedEndDatePeriod];
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
                    chosenCategory = EventCategory(name: '', id: '');
                    chosenCity = City(name: '', id: '');
                    freePrice = false;
                    onlyFromPlaceEvents = false;
                    today = false;
                    selectedStartDatePeriod  = DateTime(2100);
                    selectedEndDatePeriod = DateTime(2100);
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
        case 'freePrice': {
          freePrice = !freePrice;
        }
        case 'today': {
          today = !today;
        }
        case 'onlyFromPlaceEvents': {
          onlyFromPlaceEvents = !onlyFromPlaceEvents;
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

  Route _createPopupCategory(List<EventCategory> categories) {
    return PageRouteBuilder(

      pageBuilder: (context, animation, secondaryAnimation) {

        return EventCategoryPickerPage(categories: categories);
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