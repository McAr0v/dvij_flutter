import 'package:dvij_flutter/cities/city_class.dart';
import 'package:dvij_flutter/events/event_category_class.dart';
import 'package:dvij_flutter/events/event_sorting_options.dart';
import 'package:dvij_flutter/events/events_list_class.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../ads/ad_user_class.dart';
import '../event_class.dart';
import '../../classes/pair.dart';
import '../../classes/user_class.dart';
import '../../elements/loading_screen.dart';
import '../../elements/snack_bar.dart';
import '../../widgets_global/text_widgets/headline_and_desc.dart';
import '../events_elements/event_card_widget.dart';
import '../events_elements/event_filter_page.dart';
import '../events_list_manager.dart';
import 'create_or_edit_event_screen.dart';
import 'event_view_screen.dart';


// ---- ЭКРАН ЛЕНТЫ ЗАВЕДЕНИЙ ------

class EventsMyPage extends StatefulWidget {
  const EventsMyPage({Key? key}) : super(key: key);

  @override
  _EventsMyPageState createState() => _EventsMyPageState();
}



class _EventsMyPageState extends State<EventsMyPage> {

  // --- ОБЪЯВЛЯЕМ ПЕРЕМЕННЫЕ -----

  EventsList eventsList = EventListsManager.currentMyEventsList;
  late List<EventCategory> eventCategoriesList;

  // --- Переменные фильтра по умолчанию ----

  EventCategory eventCategoryFromFilter = EventCategory(name: '', id: '');
  City cityFromFilter = City(name: '', id: '');

  bool freePrice = false;
  bool today = false;
  bool onlyFromPlaceEvents = false;

  DateTime selectedStartDatePeriod = DateTime(2100);
  DateTime selectedEndDatePeriod = DateTime(2100);

  // --- Счетчик выбранных значений фильтра ---

  int filterCount = 0;

  // --- Переменная сортировки по умолчанию ----

  EventSortingOption _selectedSortingOption = EventSortingOption.nameAsc;

  // ---- Переменные состояния экрана ----

  bool loading = true;
  bool refresh = false;

  // TODO - Сделать загрузку рекламы из БД
  // --- Рекламные переменные -----

  // --- Список рекламы ---
  List<String> adList = ['Реклама №1', 'Реклама №2'];
  List<Pair> allElementsList = [];
  // ---- Список для хранения индексов элементов рекламы
  List<int> adIndexesList = [];
  // --- Шаг - сколько элементов списка будет между рекламными постами
  int adStep = 2;
  // --- Индекс первого рекламного элемента
  int firstIndexOfAd = 1;

  @override
  void initState(){

    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {

    // --- Функция инициализации данных ----

    setState(() {
      loading = true;
    });

    // --- Подгружаем список категорий заведений -----

    eventCategoriesList = EventCategory.currentEventCategoryList;

    // ---- Устанавливаем счетчик выбранных настроек в фильтре ----

    _setFiltersCount(
        eventCategoryFromFilter,
        cityFromFilter,
        freePrice,
        today,
        onlyFromPlaceEvents,
        selectedStartDatePeriod,
        selectedEndDatePeriod
    );

    // ----- РАБОТАЕМ СО СПИСКОМ МЕРОПРИЯТИЙ -----

    //List<EventCustom> tempEventsList = [];

    if (EventListsManager.currentMyEventsList.eventsList.isEmpty){
      // ---- Если список пуст ----
      // ---- И Юзер залогинен
      // ---- Считываем с БД заведения -----

      if (UserCustom.currentUser?.uid != null && UserCustom.currentUser?.uid != ''){
        eventsList = await eventsList.getMyListFromDb(UserCustom.currentUser!.uid);
        //tempEventsList = await EventCustom.getMyEvents(UserCustom.currentUser!.uid);
      }

    } else {
      // --- Если список не пустой ----
      // --- Подгружаем готовый список ----

      eventsList = EventListsManager.currentMyEventsList;
      //tempEventsList = EventCustom.currentMyEventsList;

    }

    // --- Фильтруем список ----

    setState(() {
      eventsList.filterLists(
          eventsList.generateMapForFilter(
              eventCategoryFromFilter,
              cityFromFilter,
              freePrice,
              today,
              onlyFromPlaceEvents,
              selectedStartDatePeriod,
              selectedEndDatePeriod
          )
      );
    });

    // --- Считываем индексы, где будет стоять реклама ----

    adIndexesList = AdUser.getAdIndexesList(adList, adStep, firstIndexOfAd);

    setState(() {
      allElementsList = AdUser.generateIndexedList(adIndexesList, eventsList.eventsList.length);
    });

    setState(() {
      loading = false;
    });
  }

  // ---- Сам экран ленты заведений ----

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator (

          // ---- Виджет обновления списка при протягивании экрана вниз ----

          onRefresh: () async {

            setState(() {
              refresh = true;
            });

            eventsList = EventsList();

            if (UserCustom.currentUser?.uid != null || UserCustom.currentUser?.uid != ''){

              eventsList = await eventsList.getMyListFromDb(UserCustom.currentUser!.uid, refresh: true);

              //List<EventCustom> tempEventsList = await EventCustom.getMyEvents(UserCustom.currentUser!.uid, refresh: true);

              setState(() {
                //eventsList = EventCustom.filterEvents(eventCategoryFromFilter, cityFromFilter, freePrice, today, onlyFromPlaceEvents, tempEventsList, selectedStartDatePeriod, selectedEndDatePeriod);

                eventsList.filterLists(
                    eventsList.generateMapForFilter(
                        eventCategoryFromFilter,
                        cityFromFilter,
                        freePrice,
                        today,
                        onlyFromPlaceEvents,
                        selectedStartDatePeriod,
                        selectedEndDatePeriod
                    )
                );

              });

              allElementsList = AdUser.generateIndexedList(adIndexesList, eventsList.eventsList.length);

            }

            setState(() {
              refresh = false;
            });

          },
          child: Stack (
            children: [
              if (UserCustom.currentUser?.uid == null || UserCustom.currentUser?.uid == '') Center(
                child: Text(
                  'Чтобы создавать мероприятия, нужно зарегистрироваться',
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
                                      eventsList.sortEntitiesList(_selectedSortingOption);
                                      //EventCustom.sortEvents(_selectedSortingOption, eventsList);
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

                      // ---- Если список пустой -----

                      if (eventsList.eventsList.isEmpty) Expanded(
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

                      // ---- Если список не пустой -----

                      if (eventsList.eventsList.isNotEmpty) Expanded(
                          child: ListView.builder(
                              padding: const EdgeInsets.all(15.0),
                              itemCount: allElementsList.length,
                              itemBuilder: (context, index) {
                                if (allElementsList[index].first == 'ad')  {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20,
                                        horizontal: 20),
                                    child: HeadlineAndDesc(headline: adList[allElementsList[index].second], description: 'реклама'),
                                  );
                                } else {
                                  int indexWithAddCountCorrection = allElementsList[index].second;
                                  return EventCardWidget(
                                    event: eventsList.eventsList[indexWithAddCountCorrection],
                                    onTap: () async {

                                      // TODO - переделать на мероприятия
                                      final results = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EventViewScreen(eventId: eventsList.eventsList[indexWithAddCountCorrection].id),
                                        ),
                                      );

                                      if (results != null) {
                                        setState(() {
                                          eventsList.eventsList[indexWithAddCountCorrection].inFav = results[0];
                                          eventsList.eventsList[indexWithAddCountCorrection].addedToFavouritesCount = results[1];
                                        });
                                      }
                                    },

                                    // --- Функция на нажатие на карточке кнопки ИЗБРАННОЕ ---
                                    onFavoriteIconPressed: () async {

                                      // TODO Сделать проверку на подтвержденный Email
                                      // ---- Если не зарегистрирован или не вошел ----
                                      if (UserCustom.currentUser?.uid == '' || UserCustom.currentUser?.uid == null)
                                      {
                                        showSnackBar(context, 'Чтобы добавлять в избранное, нужно зарегистрироваться!', AppColors.attentionRed, 2);
                                      }

                                      // --- Если пользователь залогинен -----
                                      else {

                                        // --- Если уже в избранном ----
                                        if (eventsList.eventsList[indexWithAddCountCorrection].inFav == true)
                                        {
                                          // --- Удаляем из избранных ---
                                          String resDel = await eventsList.eventsList[indexWithAddCountCorrection].deleteFromFav();
                                          // ---- Инициализируем счетчик -----
                                          int favCounter = eventsList.eventsList[indexWithAddCountCorrection].addedToFavouritesCount!;

                                          if (resDel == 'success'){
                                            // Если удаление успешное, обновляем 2 списка - текущий на экране, и общий загруженный из БД
                                            setState(() {
                                              // Обновляем текущий список
                                              eventsList.eventsList[indexWithAddCountCorrection].inFav = false;
                                              favCounter --;
                                              eventsList.eventsList[indexWithAddCountCorrection].addedToFavouritesCount = favCounter;
                                              // Обновляем общий список из БД
                                              //EventCustom.updateCurrentEventListFavInformation(eventsList[indexWithAddCountCorrection].id, favCounter, false);
                                              eventsList.eventsList[indexWithAddCountCorrection].updateCurrentListFavInformation();

                                            });
                                            showSnackBar(context, 'Удалено из избранных', AppColors.attentionRed, 1);
                                          } else {
                                            // Если удаление из избранных не прошло, показываем сообщение
                                            showSnackBar(context, resDel, AppColors.attentionRed, 1);
                                          }
                                        }
                                        else {
                                          // --- Если заведение не в избранном ----

                                          // -- Добавляем в избранное ----
                                          String res = await eventsList.eventsList[indexWithAddCountCorrection].addToFav();

                                          // ---- Инициализируем счетчик добавивших в избранное
                                          int favCounter = eventsList.eventsList[indexWithAddCountCorrection].addedToFavouritesCount!;

                                          if (res == 'success') {
                                            // --- Если добавилось успешно, так же обновляем текущий список и список из БД
                                            setState(() {
                                              // Обновляем текущий список
                                              eventsList.eventsList[indexWithAddCountCorrection].inFav = true;
                                              favCounter ++;
                                              eventsList.eventsList[indexWithAddCountCorrection].addedToFavouritesCount = favCounter;
                                              // Обновляем список из БД
                                              //EventCustom.updateCurrentEventListFavInformation(eventsList[indexWithAddCountCorrection].id, favCounter, true);
                                              eventsList.eventsList[indexWithAddCountCorrection].updateCurrentListFavInformation();

                                            });

                                            showSnackBar(context, 'Добавлено в избранные', Colors.green, 1);

                                          } else {
                                            // Если добавление прошло неудачно, отображаем всплывающее окно
                                            showSnackBar(context , res, AppColors.attentionRed, 1);
                                          }
                                        }
                                      }
                                    },
                                  );
                                }

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
              MaterialPageRoute(builder: (context) => CreateOrEditEventScreen(eventInfo: EventCustom.emptyEvent)),
            );
          } else {

            showSnackBar(context,'Чтобы создать мероприятие, нужно зарегистрироваться', AppColors.attentionRed, 2);

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
      DateTime selectedStartDatePeriod,
      DateTime selectedEndDatePeriod
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

    if (selectedStartDatePeriod != DateTime(2100)) count++;

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
        eventsList = EventsList();

        // ---- Обновляем счетчик выбранных настроек ----
        _setFiltersCount(eventCategoryFromFilter, cityFromFilter, freePrice, today, onlyFromPlaceEvents, selectedStartDatePeriod, selectedEndDatePeriod);

      });

      // --- Заново подгружаем список из БД ---
      //List<EventCustom> tempList = [];
      //tempList = EventCustom.currentMyEventsList;
      eventsList.eventsList = EventListsManager.currentMyEventsList.eventsList;

      // --- Фильтруем список согласно новым выбранным данным из фильтра ----
      setState(() {
        eventsList.filterLists(
            eventsList.generateMapForFilter(
                eventCategoryFromFilter,
                cityFromFilter,
                freePrice,
                today,
                onlyFromPlaceEvents,
                selectedStartDatePeriod,
                selectedEndDatePeriod
            )
        );
        //eventsList = EventCustom.filterEvents(eventCategoryFromFilter, cityFromFilter, freePrice, today, onlyFromPlaceEvents, tempList, selectedStartDatePeriod, selectedEndDatePeriod);
      });



      setState(() {
        allElementsList = AdUser.generateIndexedList(adIndexesList, eventsList.eventsList.length);
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
          selectedEndDatePeriod: selectedEndDatePeriod,
          selectedStartDatePeriod: selectedStartDatePeriod,
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