import 'package:dvij_flutter/dates/date_mixin.dart';
import 'package:dvij_flutter/events/event_category_class.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/elements/category_element_in_edit_screen.dart';
import 'package:dvij_flutter/elements/checkbox_with_desc.dart';
import 'package:dvij_flutter/elements/filter_elements/clear_item_widget.dart';
import 'package:flutter/material.dart';
import '../../cities/cities_elements/city_element_in_edit_screen.dart';
import '../../cities/city_class.dart';
import '../../elements/choose_dialogs/city_choose_dialog.dart';
import '../../elements/date_elements/data_picker.dart';
import '../../themes/app_colors.dart';
import 'event_category_picker_page.dart';

class EventFilterPage extends StatefulWidget {
  final List<EventCategory> categories;
  final EventCategory chosenCategory;
  final City chosenCity;
  final bool freePrice;
  final bool today;
  final bool onlyFromPlaceEvents;
  final DateTime selectedStartDatePeriod;
  final DateTime selectedEndDatePeriod;

  const EventFilterPage({super.key,
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
  EventFilterPageState createState() => EventFilterPageState();
}

// -- Виджет отображения фильтра в мероприятиях ---

class EventFilterPageState extends State<EventFilterPage> {

  // ---- Объявляем переменные ----

  List<EventCategory> categories = [];
  EventCategory chosenCategory = EventCategory(name: '', id: '');

  City chosenCity = City(name: '', id: '');
  List<City> _cities = [];

  bool freePrice = false;
  bool today = false;
  bool onlyFromPlaceEvents = false;

  DateTime selectedStartDatePeriod = DateTime(2100);
  DateTime selectedEndDatePeriod = DateTime(2100);

  @override
  void initState() {
    super.initState();

    // ---- Инициализируем переменные ----

    _cities = City.currentCityList;
    chosenCity = widget.chosenCity;

    categories = List.from(widget.categories);
    chosenCategory = widget.chosenCategory;

    freePrice = widget.freePrice;
    today = widget.today;
    onlyFromPlaceEvents = widget.onlyFromPlaceEvents;

    selectedStartDatePeriod = widget.selectedStartDatePeriod;
    selectedEndDatePeriod = widget.selectedEndDatePeriod;

  }

  // ---- САМ ЭКРАН ФИЛЬТРА -----

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
              // ---- Заголовок фильтра и иконка ---
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

                              // ---- Заголовок -----

                              Text(
                                'Фильтр и сортировка:',
                                style: Theme.of(context).textTheme.displayMedium,
                              ),
                              const SizedBox(height: 5,),
                              Text(
                                'Для наиболее точного поиска мероприятия укажи все возможные элементы фильтра',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.greyText),
                                softWrap: true,
                              ),
                            ],
                          )
                      )
                  ),

                  // --- Иконка ----

                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 8.0),

              // ---- Содержимое фильтра -----

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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const SizedBox(height: 16.0),

                          // ---- Город ----

                          ClearItemWidget(
                              showButton: chosenCity.id != '' ? true : false,
                              widget: CityElementInEditScreen(
                                cityName: chosenCity.id == '' ? 'Город не выбран' : chosenCity.name,
                                onActionPressed: () {
                                  //_showCityPickerDialog();
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

                          // --- Категория ------

                          ClearItemWidget(
                              showButton: chosenCategory.id != '' ? true : false,
                              widget: CategoryElementInEditScreen(
                                categoryName: chosenCategory.id == '' ? 'Категория не выбрана' : chosenCategory.name,
                                onActionPressed: () {
                                  //_showCityPickerDialog();
                                  _showCategoryPickerDialog();
                                },
                              ),
                              onButtonPressed: (){
                                setState(() {
                                  chosenCategory = EventCategory(name: '', id: '');
                                });
                              }
                          ),

                          const SizedBox(height: 16.0),

                          // ---- Начало периода по датам ----

                          ClearItemWidget(
                              showButton: selectedStartDatePeriod != DateTime(2100) ? true : false,
                              widget: DataPickerCustom(
                                onActionPressed: (){

                                  if (selectedStartDatePeriod == DateTime(2100)){
                                    DateTime temp = DateTime.now();
                                    setState(() {
                                      selectedStartDatePeriod = temp;
                                    });
                                  }
                                  _selectDate(
                                      context,
                                      selectedStartDatePeriod,
                                      needClearInitialDate: selectedStartDatePeriod != DateTime(2100) ? false : true,
                                      isStart: true,
                                      endDate: selectedEndDatePeriod
                                  );

                                },
                                date: selectedStartDatePeriod != DateTime(2100) ?
                                DateMixin.getHumanDate('${selectedStartDatePeriod.year}-${selectedStartDatePeriod.month}-${selectedStartDatePeriod.day}', '-')
                                    : 'Не выбрано',
                                labelText: 'Период проведения: Начальная дата',
                              ),
                              onButtonPressed: (){
                                setState(() {
                                  selectedStartDatePeriod = DateTime(2100);
                                });
                              }
                          ),

                          const SizedBox(height: 16.0),

                          // --- Конечная дата поиска ----

                          ClearItemWidget(
                              showButton: selectedEndDatePeriod != DateTime(2100) ? true : false,
                              widget: DataPickerCustom(
                                onActionPressed: (){
                                  setState(() {

                                    if(selectedEndDatePeriod == DateTime(2100) ){
                                      if (selectedStartDatePeriod == DateTime(2100)){
                                        selectedStartDatePeriod = DateTime.now();
                                      }
                                      DateTime temp = selectedStartDatePeriod;
                                      selectedEndDatePeriod = temp;
                                    }
                                  });
                                  _selectDate(context, selectedEndDatePeriod, needClearInitialDate: false, isStart: false, firstDate: selectedStartDatePeriod);
                                },
                                date: selectedEndDatePeriod != DateTime(2100) ?
                                DateMixin.getHumanDate('${selectedEndDatePeriod.year}-${selectedEndDatePeriod.month}-${selectedEndDatePeriod.day}', '-')
                                    : 'Не выбрано',
                                labelText: 'Период проведения: Конечная дата',
                              ),
                              onButtonPressed: (){
                                setState(() {
                                  selectedEndDatePeriod = DateTime(2100);
                                });
                              }
                          ),

                          const SizedBox(height: 16),

                          // --- Чек бокс бесплатные ----

                          CheckboxWithText(
                              value: freePrice,
                              label: 'Только бесплатные',
                              description: '',
                              onChanged: (value) {
                                toggleCheckBox('freePrice');
                              }
                          ),

                          // --- Чек бокс сегодня ----

                          CheckboxWithText(
                              value: today,
                              label: 'Проводится сегодня',
                              description: '',
                              onChanged: (value) {
                                toggleCheckBox('today');
                              }
                          ),

                          // ---- Чек бокс только в заведении -----
                          CheckboxWithText(
                              value: onlyFromPlaceEvents,
                              label: 'Проходит в заведении',
                              description: '',
                              onChanged: (value) {
                                toggleCheckBox('onlyFromPlaceEvents');
                              }
                          ),
                        ],
                      ),
                    ),
                  )
              ),

              // ---- Кнопки ПРИМЕНИТЬ / Отменить ---

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomButton(
                    buttonText: 'Применить фильтр',
                    onTapMethod: (){

                      if (selectedEndDatePeriod == DateTime(2100) && selectedStartDatePeriod != DateTime(2100)){
                        // --- Если выбрана начальная дата, а конечная не выбрана
                        // --- Ставим в качестве начальной даты конечную
                        setState(() {
                          selectedEndDatePeriod = selectedStartDatePeriod;
                        });
                      } else if (selectedStartDatePeriod == DateTime(2100) && selectedEndDatePeriod != DateTime(2100)){
                        // --- Если наоборот, по аналогии на стартовую дату ставим конечную
                        setState(() {
                          selectedStartDatePeriod = selectedEndDatePeriod;
                        });
                      }
                      // ---- Возвращаем результаты фильтра на предыдущую страницу ----
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
                          // --- При отмене просто уходим, без аргументов
                          Navigator.of(context).pop();
                        });
                      },
                    ),
                  )

                ],
              ),

              const SizedBox(height: 16.0),

            ],
          ),
        ),
      ),
    );
  }

  void toggleCheckBox(String checkBoxName) {

    // --- Функция переключения чек-боксов
    // --- В зависимости от ключевого слова

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

  Future<void> _selectDate(
      BuildContext context,
      DateTime initial,
      {bool needClearInitialDate = false,
        bool isStart = true,
        DateTime? firstDate,
        DateTime? endDate,
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