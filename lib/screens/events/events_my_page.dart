import 'package:dvij_flutter/classes/city_class.dart';
import 'package:dvij_flutter/classes/event_category_class.dart';
import 'package:dvij_flutter/classes/place_category_class.dart';
import 'package:dvij_flutter/classes/place_class.dart';
import 'package:dvij_flutter/elements/places_elements/place_card_widget.dart';
import 'package:dvij_flutter/elements/places_elements/place_filter_page.dart';
import 'package:dvij_flutter/screens/places/place_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../classes/event_class.dart';
import '../../classes/event_sorting_options.dart';
import '../../classes/place_sorting_options.dart';
import '../../classes/user_class.dart';
import '../../elements/custom_snack_bar.dart';
import '../../elements/events_elements/event_card_widget.dart';
import '../../elements/events_elements/event_filter_page.dart';
import '../../elements/loading_screen.dart';
import '../places/create_or_edit_place_screen.dart';
import 'create_or_edit_event_screen.dart';


// ---- ЭКРАН ЛЕНТЫ ЗАВЕДЕНИЙ ------

class EventsMyPage extends StatefulWidget {
  const EventsMyPage({Key? key}) : super(key: key);

  @override
  _EventsMyPageState createState() => _EventsMyPageState();
}



class _EventsMyPageState extends State<EventsMyPage> {
  late List<EventCustom> eventsMyList; // Список мест
  late List<EventCategory> eventCategoriesList; // Список категорий мест

  // --- Переменные фильтра по умолчанию ----

  EventCategory eventCategoryFromFilter = EventCategory(name: '', id: '');
  City cityFromFilter = City(name: '', id: '');
  bool freePrice = false;
  bool today = false;
  bool onlyFromPlaceEvents = false;
  DateTime selectedStartDatePeriod = DateTime(2100);
  DateTime selectedEndDatePeriod = DateTime(2100);

  EventCustom eventEmpty = EventCustom.emptyEvent;

  // --- Переменная сортировки по умолчанию ----

  EventSortingOption _selectedSortingOption = EventSortingOption.nameAsc;

  // Переменная, включающая экран загрузки
  bool loading = true;

  // Переменная, включающая экран обновления
  bool refresh = false;

  // Счетчик выбранных значений фильтра
  int filterCount = 0;

  @override
  void initState(){

    super.initState();
    _initializeData();
  }

  // --- Функция инициализации данных ----

  Future<void> _initializeData() async {

    setState(() {
      loading = true;
    });

    /*
    // ---- Подгружаем город в фильтр из данных пользователя ---
    if (UserCustom.currentUser != null){
      if (UserCustom.currentUser!.city != ''){
        City usersCity = City.getCityByIdFromList(UserCustom.currentUser!.city);
        setState(() {
          cityFromFilter = usersCity;
        });
      }
    }*/

    // ---- Устанавливаем счетчик выбранных в фильтре настроек ----

    _setFiltersCount(eventCategoryFromFilter, cityFromFilter, freePrice, today, onlyFromPlaceEvents);

    // ----- Работаем со списком заведений -----

    // ---- Если список пуст ----
    if (Place.currentMyPlaceList.isEmpty){

      // ---- Считываем с БД заведения -----
      if (UserCustom.currentUser?.uid != null && UserCustom.currentUser?.uid != ''){

        List<EventCustom> tempEventsList = await EventCustom.getMyEvents(UserCustom.currentUser!.uid);

        // --- Фильтруем список -----
        setState(() {

          eventsMyList = EventCustom.filterEvents(eventCategoryFromFilter, cityFromFilter, freePrice, today, onlyFromPlaceEvents, tempEventsList, selectedStartDatePeriod, selectedEndDatePeriod);
        });
      }


    } else {
      // --- Если список не пустой ----
      // --- Подгружаем готовый список ----
      List<EventCustom> tempList = [];
      tempList = EventCustom.currentMyEventsList;

      // --- Фильтруем список ----
      setState(() {
        eventsMyList = EventCustom.filterEvents(eventCategoryFromFilter, cityFromFilter, freePrice, today, onlyFromPlaceEvents, tempList, selectedStartDatePeriod, selectedEndDatePeriod);
      });
    }

    // Подгружаем список категорий заведений
    eventCategoriesList = EventCategory.currentEventCategoryList;

    setState(() {
      loading = false;
    });
  }

  // --- Функция отображения всплывающего окна ----

  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  // ---- Сам экран ленты заведений ----

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // - Обновление списка, если тянуть экран вниз
      body: RefreshIndicator (
        onRefresh: () async {

          setState(() {
            refresh = true;
          });

          eventsMyList = [];

          if (UserCustom.currentUser?.uid != null || UserCustom.currentUser?.uid != ''){

            List<EventCustom> tempEventsList = await EventCustom.getMyEvents(UserCustom.currentUser!.uid);

            setState(() {
              eventsMyList = EventCustom.filterEvents(eventCategoryFromFilter, cityFromFilter, freePrice, today, onlyFromPlaceEvents, tempEventsList, selectedStartDatePeriod, selectedEndDatePeriod);
            });

          }

          setState(() {
            refresh = false;
          });

        },
        child: Stack (
          children: [
            if (UserCustom.currentUser?.uid == null || UserCustom.currentUser?.uid == '') Center(
              child: Text(
                'Чтобы создавать мероприятия или участвовать в их управлении, нужно зарегистрироваться',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            )
            else if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка мероприятий')
            else if (refresh) Center(
                child: Text(
                  'Подожди, идет обновление мероприятий',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
              else Column(
                  children: [
                    // ---- Фильтр и сортировка -----
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                        color: AppColors.greyOnBackground,
                        child: Row (
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            // ---- Фильтр -----

                            GestureDetector(
                              onTap: (){
                                _showFilterDialog();
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Фильтр ${filterCount > 0 ? '($filterCount)' : ''}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: filterCount > 0 ? AppColors.brandColor : AppColors.white),
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

                            // ------ Сортировка ------

                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: DropdownButton<EventSortingOption>(
                                style: Theme.of(context).textTheme.bodySmall,
                                isExpanded: true,
                                value: _selectedSortingOption,
                                onChanged: (EventSortingOption? newValue) {
                                  setState(() {
                                    _selectedSortingOption = newValue!;
                                    EventCustom.sortEvents(_selectedSortingOption, eventsMyList);
                                  });
                                },
                                items: const [
                                  DropdownMenuItem(
                                    value: EventSortingOption.nameAsc,
                                    child: Text('По имени: А-Я'),
                                  ),
                                  DropdownMenuItem(
                                    value: EventSortingOption.nameDesc,
                                    child: Text('По имени: Я-А'),
                                  ),
                                  DropdownMenuItem(
                                    value: EventSortingOption.favCountAsc,
                                    child: Text('В избранном: по возрастанию'),
                                  ),
                                  DropdownMenuItem(
                                    value: EventSortingOption.favCountDesc,
                                    child: Text('В избранном: по убыванию'),
                                  ),
                                ],
                              ),
                            )
                          ],
                        )
                    ),

                    // ---- Если список заведений пустой -----

                    if (eventsMyList.isEmpty) Expanded(
                        child: ListView.builder(
                            padding: const EdgeInsets.all(15.0),
                            itemCount: 1,
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

                    // ---- Если список заведений не пустой -----

                    if (eventsMyList.isNotEmpty) Expanded(
                        child: ListView.builder(
                            padding: const EdgeInsets.all(15.0),
                            itemCount: eventsMyList.length,
                            itemBuilder: (context, index) {
                              return EventCardWidget(
                                event: eventsMyList[index],
                                onTap: () async {

                                  // TODO - переделать на мероприятия
                                  final results = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlaceViewScreen(placeId: eventsMyList[index].id),
                                    ),
                                  );

                                  if (results != null) {
                                    setState(() {
                                      eventsMyList[index].inFav = results[0].toString();
                                      eventsMyList[index].addedToFavouritesCount = results[1].toString();
                                    });
                                  }
                                },

                                // --- Функция на нажатие на карточке кнопки ИЗБРАННОЕ ---
                                onFavoriteIconPressed: () async {

                                  // TODO Сделать проверку на подтвержденный Email
                                  // ---- Если не зарегистрирован или не вошел ----
                                  if (UserCustom.currentUser?.uid == '' || UserCustom.currentUser?.uid == null)
                                  {
                                    showSnackBar('Чтобы добавлять в избранное, нужно зарегистрироваться!', AppColors.attentionRed, 2);
                                  }

                                  // --- Если пользователь залогинен -----
                                  else {

                                    // --- Если уже в избранном ----
                                    if (eventsMyList[index].inFav == 'true')
                                    {
                                      // --- Удаляем из избранных ---
                                      String resDel = await EventCustom.deleteEventFromFav(eventsMyList[index].id);
                                      // ---- Инициализируем счетчик -----
                                      int favCounter = int.parse(eventsMyList[index].addedToFavouritesCount!);

                                      if (resDel == 'success'){
                                        // Если удаление успешное, обновляем 2 списка - текущий на экране, и общий загруженный из БД
                                        setState(() {
                                          // Обновляем текущий список
                                          eventsMyList[index].inFav = 'false';
                                          favCounter --;
                                          eventsMyList[index].addedToFavouritesCount = favCounter.toString();
                                          // Обновляем общий список из БД
                                          EventCustom.updateCurrentEventListFavInformation(eventsMyList[index].id, favCounter.toString(), 'false');

                                        });
                                        showSnackBar('Удалено из избранных', AppColors.attentionRed, 1);
                                      } else {
                                        // Если удаление из избранных не прошло, показываем сообщение
                                        showSnackBar(resDel, AppColors.attentionRed, 1);
                                      }
                                    }
                                    else {
                                      // --- Если заведение не в избранном ----

                                      // -- Добавляем в избранное ----
                                      String res = await EventCustom.addEventToFav(eventsMyList[index].id);

                                      // ---- Инициализируем счетчик добавивших в избранное
                                      int favCounter = int.parse(eventsMyList[index].addedToFavouritesCount!);

                                      if (res == 'success') {
                                        // --- Если добавилось успешно, так же обновляем текущий список и список из БД
                                        setState(() {
                                          // Обновляем текущий список
                                          eventsMyList[index].inFav = 'true';
                                          favCounter ++;
                                          eventsMyList[index].addedToFavouritesCount = favCounter.toString();
                                          // Обновляем список из БД
                                          EventCustom.updateCurrentEventListFavInformation(eventsMyList[index].id, favCounter.toString(), 'true');
                                        });

                                        showSnackBar('Добавлено в избранные', Colors.green, 1);

                                      } else {
                                        // Если добавление прошло неудачно, отображаем всплывающее окно
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (UserCustom.currentUser != null && UserCustom.currentUser!.uid != '') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateOrEditEventScreen(eventInfo: eventEmpty)),
            );
          } else {

            showSnackBar('Чтобы создать мероприятие, нужно зарегистрироваться', AppColors.attentionRed, 2);

          }

        },
        backgroundColor: AppColors.brandColor,
        child: const Icon(Icons.add), // Цвет кнопки
      ),
    );
  }

  // ---- Функция обвноления счетчика выбранных настроек фильтра ----
  void _setFiltersCount(
      EventCategory eventCategoryFromFilter,
      City cityFromFilter,
      bool freePriceFromFilter,
      bool todayFromFilter,
      bool onlyFromPlaceEventsFromFilter,
      ){

    int count = 0;

    // --- Если значения не соответствуют дефолтным, то плюсуем счетчик ----
    if (eventCategoryFromFilter.name != ''){
      count++;
    }

    if (cityFromFilter.name != ''){
      count++;
    }

    if (freePriceFromFilter) count++;

    if (todayFromFilter) count++;

    if (onlyFromPlaceEventsFromFilter) count++;

    // --- Обновляем счетчик на странице -----
    setState(() {
      filterCount = count;
    });

  }

  // ---- Функция отображения диалога фильтра ----

  void _showFilterDialog() async {
    // Открываем всплывающее окно и ждем результатов
    final results = await Navigator.of(context).push(_createPopupFilter(eventCategoriesList));

    // Если пользователь выбрал что-то в диалоге фильтра
    if (results != null) {
      // Устанавливаем значения, которые он выбрал
      setState(() {
        loading = true;
        cityFromFilter = results[0];
        eventCategoryFromFilter = results[1];
        freePrice = results [2];
        today = results [3];
        onlyFromPlaceEvents = results [4];
        selectedStartDatePeriod = results[5];
        selectedEndDatePeriod = results[6];
        eventsMyList = [];

        // ---- Обновляем счетчик выбранных настроек ----
        _setFiltersCount(eventCategoryFromFilter, cityFromFilter, freePrice, today, onlyFromPlaceEvents);

      });

      // --- Заново подгружаем список из БД ---
      List<EventCustom> tempList = [];
      tempList = EventCustom.currentFeedEventsList;

      // --- Фильтруем список согласно новым выбранным данным из фильтра ----
      setState(() {
        eventsMyList = EventCustom.filterEvents(eventCategoryFromFilter, cityFromFilter, freePrice, today, onlyFromPlaceEvents, tempList, selectedStartDatePeriod, selectedEndDatePeriod);
      });

      setState(() {
        loading = false;
      });
    }
  }

  // ----- Путь для открытия всплывающей страницы фильтра ----

  Route _createPopupFilter(List<EventCategory> categories) {
    return PageRouteBuilder(

      pageBuilder: (context, animation, secondaryAnimation) {

        // --- Сама страница фильтра ---
        return EventFilterPage(
            categories: categories,
            chosenCategory: eventCategoryFromFilter,
            chosenCity: cityFromFilter,
            freePrice: freePrice,
            onlyFromPlaceEvents: onlyFromPlaceEvents,
            today: today,
          selectedStartDatePeriod: selectedStartDatePeriod,
          selectedEndDatePeriod: selectedEndDatePeriod,
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
      transitionDuration: const Duration(milliseconds: 100),

    );
  }
}