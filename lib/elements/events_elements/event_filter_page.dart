import 'package:dvij_flutter/classes/event_category_class.dart';
import 'package:dvij_flutter/classes/place_category_class.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/elements/category_element_in_edit_screen.dart';
import 'package:dvij_flutter/elements/date_elements/period_date_picker.dart';
import 'package:dvij_flutter/elements/events_elements/event_category_picker_page.dart';
import 'package:dvij_flutter/elements/places_elements/place_category_picker_page.dart';
import 'package:flutter/material.dart';
import '../../classes/city_class.dart';
import '../../classes/event_sorting_options.dart';
import '../../classes/place_sorting_options.dart';
import '../../methods/date_functions.dart';
import '../../themes/app_colors.dart';
import '../choose_dialogs/city_choose_dialog.dart';
import '../cities_elements/city_element_in_edit_screen.dart';
import '../date_elements/data_picker.dart';

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column (
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Фильтр и сортировка:',
                                style: Theme.of(context).textTheme.displayMedium,
                              ),
                              SizedBox(height: 5,),
                              Text(
                                'Для наиболее точного поиска мероприятия укажи все возможные элементы фильтра',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.greyText),
                                softWrap: true,
                              ),
                            ],
                          )
                      )
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16.0),

                          //Text('Фильтр по городу и категории:', style: Theme.of(context).textTheme.titleMedium,),
                          //Text('Укажи эти настройки чтобы отобразить только нужные мероприятия', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.greyText),),

                          //SizedBox(height: 20,),

                          Row(
                            children: [
                              Expanded(
                                  child: Column(
                                    children: [
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
                                    ],
                                  )
                              ),
                              if (chosenCity.id != '') Card(
                                color: AppColors.attentionRed,
                                child: IconButton(
                                  onPressed: (){
                                    setState(() {
                                      chosenCity = City(name: '', id: '');
                                    });
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: AppColors.greyOnBackground,
                                  ),
                                ),
                              )
                            ],
                          ),

                          const SizedBox(height: 16.0),

                          Row(
                            children: [
                              Expanded(
                                  child: Column(
                                    children: [
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
                                    ],
                                  )
                              ),
                              if (chosenCategory.id != '') Card(
                                color: AppColors.attentionRed,
                                child: IconButton(
                                  onPressed: (){
                                    setState(() {
                                      chosenCategory = EventCategory(name: '', id: '');
                                    });
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: AppColors.greyOnBackground,
                                  ),
                                ),
                              )
                            ],
                          ),



                          const SizedBox(height: 16.0),

                          //Text('Фильтр по датам', style: Theme.of(context).textTheme.titleMedium,),
                          //Text('Выбери интересующие даты чтобы отобразить мероприятия, проводимые в заданный временной промежуток:', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.greyText),),

                          //SizedBox(height: 20,),

                          Row(
                            children: [
                              Expanded(
                                  child: Column(
                                    children: [
                                      if (selectedStartDatePeriod == DateTime(2100))
                                        DataPickerCustom(
                                          onActionPressed: (){
                                            DateTime temp = DateTime.now();
                                            setState(() {
                                              selectedStartDatePeriod = temp;
                                              //selectedEndDatePeriod = temp;
                                            });
                                            _selectDate(context, selectedStartDatePeriod, needClearInitialDate: true, isStart: true, endDate: selectedEndDatePeriod);
                                          },
                                          date: 'Не выбрано',
                                          labelText: 'Период проведения: Начальная дата',
                                        )

                                      else DataPickerCustom(
                                          onActionPressed: (){
                                            _selectDate(context, selectedStartDatePeriod, needClearInitialDate: false, isStart: true, endDate: selectedEndDatePeriod);

                                          },
                                          date: getHumanDate('${selectedStartDatePeriod.year}-${selectedStartDatePeriod.month}-${selectedStartDatePeriod.day}', '-'),
                                          labelText: 'Период проведения: Начальная дата'
                                      ),
                                    ],
                                  )
                              ),
                              if (selectedStartDatePeriod != DateTime(2100)) Card(
                                color: AppColors.attentionRed,
                                child: IconButton(
                                  onPressed: (){
                                    setState(() {
                                      selectedStartDatePeriod = DateTime(2100);
                                    });
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: AppColors.greyOnBackground,
                                  ),
                                ),
                              )
                            ],
                          ),



                          const SizedBox(height: 16.0),

                          Row(
                            children: [
                              Expanded(
                                  child: Column(
                                    children: [
                                      if (selectedEndDatePeriod == DateTime(2100))
                                        DataPickerCustom(
                                          onActionPressed: (){


                                            setState(() {
                                              if (selectedStartDatePeriod == DateTime(2100)){
                                                selectedStartDatePeriod = DateTime.now();
                                              }

                                              DateTime temp = selectedStartDatePeriod;

                                              selectedEndDatePeriod = temp;
                                            });
                                            _selectDate(context, selectedEndDatePeriod, needClearInitialDate: false, isStart: false, firstDate: selectedStartDatePeriod);
                                          },
                                          date: 'Не выбрано',
                                          labelText: 'Период проведения: Конечная дата',
                                        )

                                      else DataPickerCustom(
                                          onActionPressed: (){
                                            _selectDate(context, selectedEndDatePeriod, needClearInitialDate: false, isStart: false, firstDate: selectedStartDatePeriod);
                                          },
                                          date: getHumanDate('${selectedEndDatePeriod.year}-${selectedEndDatePeriod.month}-${selectedEndDatePeriod.day}', '-'),
                                          labelText: 'Период проведения: Конечная дата'
                                      ),
                                    ],
                                  )
                              ),
                              if (selectedEndDatePeriod != DateTime(2100)) Card(
                                color: AppColors.attentionRed,
                                child: IconButton(
                                  onPressed: (){
                                    setState(() {
                                      selectedEndDatePeriod = DateTime(2100);
                                    });
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: AppColors.greyOnBackground,
                                  ),
                                ),
                              )
                            ],
                          ),



                          const SizedBox(height: 16),

                          //Text('Дополнительные настройки', style: Theme.of(context).textTheme.titleMedium,),
                          //Text('Выбери интересующие даты чтобы отобразить мероприятия, проводимые в заданный временной промежуток:', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.greyText),),

                          //const SizedBox(height: 10),

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
                              ),



                            ],
                          ),

                          //const SizedBox(height: 30.0),

                        ],
                      ),
                    ),
                  )
              ),
              //const SizedBox(height: 16.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomButton(
                    buttonText: 'Применить фильтр',
                    onTapMethod: (){
                      if (selectedEndDatePeriod == DateTime(2100) && selectedStartDatePeriod != DateTime(2100)){
                        setState(() {
                          selectedEndDatePeriod = selectedStartDatePeriod;
                        });
                      } else if (selectedStartDatePeriod == DateTime(2100) && selectedEndDatePeriod != DateTime(2100)){
                        setState(() {
                          selectedStartDatePeriod = selectedEndDatePeriod;
                        });
                      }
                      List<dynamic> arguments = [chosenCity, chosenCategory, freePrice, today, onlyFromPlaceEvents, selectedStartDatePeriod, selectedEndDatePeriod];
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

              /*const SizedBox(height: 20.0),

              CustomButton(
                buttonText: 'Очистить',
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
              ),*/

              const SizedBox(height: 16.0),

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

  Future<void> _selectDate(
      BuildContext context,
      DateTime initial,
      {bool needClearInitialDate = false,
        bool isStart = true,
        DateTime? firstDate = null,
        DateTime? endDate = null,
      }
      ) async {

    if (needClearInitialDate == true) initial = DateTime.now();

    final DateTime? picked = await showDatePicker(

      locale: const Locale('ru', 'RU'),
      context: context,
      initialDate: initial,
      firstDate: firstDate ?? DateTime.now(),
      lastDate: endDate ?? DateTime(2100),
      helpText: 'Выбери дату',
      cancelText: 'Отмена',
      confirmText: 'Подтвердить',
      keyboardType: TextInputType.datetime,
      currentDate: DateTime.now(),
    );

    if (picked != null) {
      if (isStart) {
        setState(() {
          selectedStartDatePeriod = picked;
        });
        _isStartBeforeEnd(true);
      } else {
        setState(() {
          selectedEndDatePeriod = picked;
        });
        _isStartBeforeEnd(false);
      }
    }
  }

  void _isStartBeforeEnd (bool startAfterEnd){
    if (startAfterEnd){
      if (selectedStartDatePeriod.isAfter(selectedEndDatePeriod)){
        setState(() {
          selectedStartDatePeriod = selectedEndDatePeriod;
        });
      }
    } else {
      if (selectedEndDatePeriod.isBefore(selectedStartDatePeriod)){
        setState(() {
          selectedEndDatePeriod = selectedStartDatePeriod;
        });
      }
    }
  }

}