import 'package:dvij_flutter/cities/city_class.dart';
import 'package:dvij_flutter/events/event_category_class.dart';
import 'package:dvij_flutter/events/event_sorting_options.dart';
import 'package:dvij_flutter/events/events_list_class.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import '../../ads/ad_user_class.dart';
import '../../classes/pair.dart';
import '../../current_user/user_class.dart';
import '../../elements/loading_screen.dart';
import '../../elements/snack_bar.dart';
import '../../widgets_global/cards_widgets/card_widget_for_event_promo_places.dart';
import '../../widgets_global/filter_widgets/filter_widget.dart';
import '../../widgets_global/text_widgets/headline_and_desc.dart';
import '../event_class.dart';
import '../events_elements/event_filter_page.dart';
import '../events_list_manager.dart';
import 'event_view_screen.dart';


// ---- ЭКРАН ЛЕНТЫ ЗАВЕДЕНИЙ ------

class EventsFavPage extends StatefulWidget {
  const EventsFavPage({Key? key}) : super(key: key);

  @override
  EventsFavPageState createState() => EventsFavPageState();
}



class EventsFavPageState extends State<EventsFavPage> {

  // --- ОБЪЯВЛЯЕМ ПЕРЕМЕННЫЕ -----

  EventsList eventsList = EventsList();
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

  void _showSnackBar(String text, Color color, int showSeconds){
    showSnackBar(context, text, color, showSeconds);
  }

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

    //EventsList tempEventsList = EventsList();

    if (UserCustom.currentUser?.uid != null && UserCustom.currentUser?.uid != ''){
      eventsList = await eventsList.getFavListFromDb(UserCustom.currentUser!.uid);
    }

    /*if (EventListsManager.currentFavEventsList.eventsList.isEmpty){
      // ---- Если список пуст ----
      // ---- И Юзер залогинен
      // ---- Считываем с БД заведения -----

      if (UserCustom.currentUser?.uid != null && UserCustom.currentUser?.uid != ''){
        eventsList = await eventsList.getFavListFromDb(UserCustom.currentUser!.uid);
      }

    } else {
      // --- Если список не пустой ----
      // --- Подгружаем готовый список ----

      eventsList = EventListsManager.currentFavEventsList;

    }*/

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
            await refreshList();
          },
          child: Stack (
            children: [
              if (UserCustom.currentUser?.uid == null || UserCustom.currentUser?.uid == '') Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Чтобы добавлять мероприятия в избранные, нужно зарегистрироваться',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                )
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

                    FilterWidget(
                      onFilterTap: (){
                        _showFilterDialog();
                      },
                      filterCount: filterCount,
                      sortingValue: _selectedSortingOption,
                      onSortingValueChanged: (EventSortingOption? newValue) {
                        setState(() {
                          _selectedSortingOption = newValue!;
                          eventsList.sortEntitiesList(_selectedSortingOption);
                        });
                      },
                      sortingItems: EventCustom.emptyEvent.getEventSortingOptionsList(),
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
                            padding: const EdgeInsets.all(10.0),
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
                                return CardWidgetForEventPromoPlaces(
                                  height: 450,
                                  event: eventsList.eventsList[indexWithAddCountCorrection],
                                  onTap: () async {
                                    await goToEventViewScreen(indexWithAddCountCorrection);
                                  },

                                  // --- Функция на нажатие на карточке кнопки ИЗБРАННОЕ ---
                                  onFavoriteIconPressed: () async {
                                    await addOrDeleteFromFav(indexWithAddCountCorrection);
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
        )
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
      eventsList.eventsList = EventListsManager.currentFavEventsList.eventsList;
      //tempList = EventCustom.currentFavEventsList;

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

  Future<void> goToEventViewScreen(int indexWithAddCountCorrection) async {
    final results = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventViewScreen(eventId: eventsList.eventsList[indexWithAddCountCorrection].id),
      ),
    );

    if (results != null) {
      EventsList tempList = await eventsList.getFavListFromDb(UserCustom.currentUser!.uid);
      eventsList = tempList;

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

      setState(() {
        allElementsList = AdUser.generateIndexedList(adIndexesList, eventsList.eventsList.length);
      });
    }
  }

  Future<void> addOrDeleteFromFav(int indexWithAddCountCorrection) async {

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
        //int favCounter = eventsList.eventsList[indexWithAddCountCorrection].favUsersIds;
        setState(() {
          loading = true;
          // Обновляем текущий список
        });
        // --- Удаляем из избранных ---
        String resDel = await eventsList.eventsList[indexWithAddCountCorrection].deleteFromFav();



        if (resDel == 'success'){
          eventsList.eventsList[indexWithAddCountCorrection].inFav = false;
          //favCounter --;
          //eventsList.eventsList[indexWithAddCountCorrection].favUsersIds = favCounter;
          // Обновляем общий список из БД
          eventsList.eventsList[indexWithAddCountCorrection].updateCurrentListFavInformation();
          EventsList tempList = await eventsList.getFavListFromDb(UserCustom.currentUser!.uid);

          setState(() {
            eventsList = tempList;
            allElementsList = AdUser.generateIndexedList(adIndexesList, eventsList.eventsList.length);
            loading = false;
          });
          // Если удаление успешное, обновляем 2 списка - текущий на экране, и общий загруженный из БД
          _showSnackBar('Удалено из избранных', AppColors.attentionRed, 1);

        } else {
          // Если удаление из избранных не прошло, показываем сообщение
          _showSnackBar(resDel, AppColors.attentionRed, 1);
        }
      }
      else {

        setState(() {
          loading = true;
          // Обновляем текущий список
        });
        // --- Если заведение не в избранном ----

        // -- Добавляем в избранное ----
        String res = await eventsList.eventsList[indexWithAddCountCorrection].addToFav();

        // ---- Инициализируем счетчик добавивших в избранное
        //int favCounter = eventsList.eventsList[indexWithAddCountCorrection].favUsersIds;

        if (res == 'success') {
          // --- Если добавилось успешно, так же обновляем текущий список и список из БД

          EventsList tempList = await eventsList.getFavListFromDb(UserCustom.currentUser!.uid);

          setState(() {
            // Обновляем текущий список
            eventsList.eventsList[indexWithAddCountCorrection].inFav = true;
            //favCounter ++;
            //eventsList.eventsList[indexWithAddCountCorrection].favUsersIds = favCounter;

            eventsList.eventsList[indexWithAddCountCorrection].updateCurrentListFavInformation();

            eventsList = tempList;
            //eventsList = EventListsManager.currentFavEventsList;
            allElementsList = AdUser.generateIndexedList(adIndexesList, eventsList.eventsList.length);

            loading = false;

          });
          _showSnackBar('Добавлено в избранные', Colors.green, 1);

        } else {
          // Если добавление прошло неудачно, отображаем всплывающее окно
          _showSnackBar(res, AppColors.attentionRed, 1);
        }
      }
    }
  }

  Future<void> refreshList() async {
    setState(() {
      refresh = true;
    });

    eventsList = EventsList();

    if (UserCustom.currentUser?.uid != null || UserCustom.currentUser?.uid != ''){

      eventsList = await eventsList.getFavListFromDb(UserCustom.currentUser!.uid, refresh: true);

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

      allElementsList = AdUser.generateIndexedList(adIndexesList, eventsList.eventsList.length);

    }

    setState(() {
      refresh = false;
    });
  }
}