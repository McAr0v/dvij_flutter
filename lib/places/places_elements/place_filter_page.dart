import 'package:dvij_flutter/places/place_category_class.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/elements/category_element_in_edit_screen.dart';
import 'package:dvij_flutter/elements/checkbox_with_desc.dart';
import 'package:dvij_flutter/elements/filter_elements/clear_item_widget.dart';
import 'package:dvij_flutter/places/places_elements/place_category_picker_page.dart';
import 'package:flutter/material.dart';
import '../../cities/cities_elements/city_element_in_edit_screen.dart';
import '../../cities/city_class.dart';
import '../../elements/choose_dialogs/city_choose_dialog.dart';
import '../../themes/app_colors.dart';

class PlaceFilterPage extends StatefulWidget {
  final List<PlaceCategory> categories;
  final PlaceCategory chosenCategory;
  final City chosenCity;
  final bool nowIsOpen;
  final bool haveEvents;
  final bool havePromos;

  const PlaceFilterPage({super.key,
    required this.categories,
    required this.chosenCategory,
    required this.chosenCity,
    required this.nowIsOpen,
    required this.havePromos,
    required this.haveEvents
  });

  @override
  PlaceFilterPageState createState() => PlaceFilterPageState();
}

// ---- Виджет фильтра заведений ----

class PlaceFilterPageState extends State<PlaceFilterPage> {

  // ---- Объявляем переменные ---

  List<PlaceCategory> categories = [];
  PlaceCategory chosenCategory = PlaceCategory(name: '', id: '');

  City chosenCity = City(name: '', id: '');
  List<City> _cities = [];

  bool nowIsOpen = false;
  bool haveEvents = false;
  bool havePromos = false;

  @override
  void initState() {
    super.initState();

    // --- Инициализируем переменные ----

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

              // ---- Заголовок и кнопка закрыть ----

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column (
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // --- Заголовок -----

                            Text(
                              'Фильтр и сортировка:',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            const SizedBox(height: 5,),
                            Text(
                              'Для наиболее точного поиска укажи все возможные элементы фильтра',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.greyText),
                              softWrap: true,
                            ),
                          ],
                        )
                      ),
                  ),

                  // --- Кнопка закрыть ---

                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 8.0),

              // --- Содержимое фильтра ----

              Expanded(
                  child: SingleChildScrollView (
                    child: Container (
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.greyBackground,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [

                          const SizedBox(height: 16.0),

                          // ---- Город ----

                          ClearItemWidget(
                              showButton: chosenCity.id != '' ? true : false,
                              widget: CityElementInEditScreen(
                                cityName: chosenCity.id != '' ? chosenCity.name : 'Город не выбран',
                                onActionPressed: () {
                                  _showCityPickerDialog();
                                },
                              ),
                              onButtonPressed: (){
                                setState(() {
                                  chosenCity = City(name: '', id: '');
                                });
                              }
                          ),

                          const SizedBox(height: 16.0),

                          // --- Категория ----

                          ClearItemWidget(
                              showButton: chosenCategory.id != '' ? true : false,
                              widget: CategoryElementInEditScreen(
                                categoryName: chosenCategory.id != '' ? chosenCategory.name : 'Категория не выбрана',
                                onActionPressed: () {
                                  //_showCityPickerDialog();
                                  _showCategoryPickerDialog();
                                },
                              ),
                              onButtonPressed: (){
                                setState(() {
                                  chosenCategory = PlaceCategory(name: '', id: '');
                                });
                              }
                          ),

                          const SizedBox(height: 16.0),

                          CheckboxWithText(
                              value: nowIsOpen,
                              label: 'Сейчас открыто',
                              description: 'Показать заведения, которые работают в данный момент',
                              onChanged: (value) {
                                toggleCheckBox('nowIsOpen');
                              },
                            verticalPadding: 10,
                          ),

                          CheckboxWithText(
                            value: haveEvents,
                            label: 'Есть мероприятия',
                            description: 'Показать заведения, в которых проходит хотя бы одно мероприятие',
                            onChanged: (value) {
                              toggleCheckBox('haveEvents');
                            },
                            verticalPadding: 10,
                          ),

                          CheckboxWithText(
                            value: havePromos,
                            label: 'Есть акции',
                            description: 'Показать заведения, в которых проходит хотя бы одна акция',
                            onChanged: (value) {
                              toggleCheckBox('havePromos');
                            },
                            verticalPadding: 10,
                          ),

                          const SizedBox(height: 50,),

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
                  )
              ),

              // --- Кнопки Применить / Отменить ----

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomButton(
                    buttonText: 'Применить фильтр',
                    onTapMethod: (){
                      List<dynamic> arguments = [chosenCity, chosenCategory, nowIsOpen, haveEvents, havePromos];
                      Navigator.of(context).pop(arguments);
                    },
                  ),

                  const SizedBox(width: 10.0),

                  Expanded(
                    child: CustomButton(
                      buttonText: 'Отменить',
                      state: 'secondary',
                      onTapMethod: (){
                        setState(() {
                          Navigator.of(context).pop();
                        });
                      },
                    ),
                  )
                ],
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
      transitionDuration: const Duration(milliseconds: 100),

    );
  }

  void _showCityPickerDialog() async {
    final selectedCity = await Navigator.of(context).push(_createPopup(_cities));

    if (selectedCity != null) {
      setState(() {
        chosenCity = selectedCity;
      });
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
      transitionDuration: const Duration(milliseconds: 100),

    );
  }

}