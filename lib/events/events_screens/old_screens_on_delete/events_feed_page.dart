import 'package:dvij_flutter/cities/city_class.dart';
import 'package:dvij_flutter/constants/constants.dart';
import 'package:dvij_flutter/events/event_category_class.dart';
import 'package:dvij_flutter/events/event_class.dart';
import 'package:dvij_flutter/events/event_sorting_options.dart';
import 'package:dvij_flutter/events/events_list_class.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import '../../../ads/ad_user_class.dart';
import '../../../classes/pair.dart';
import '../../../current_user/user_class.dart';
import '../../../elements/loading_screen.dart';
import '../../../elements/snack_bar.dart';
import '../../../widgets_global/filter_widgets/filter_widget.dart';
import '../../../widgets_global/text_widgets/headline_and_desc.dart';
import '../../../widgets_global/cards_widgets/card_widget_for_event_promo_places.dart';
import '../../events_elements/event_filter_page.dart';
import '../../events_list_manager.dart';
import '../event_view_screen.dart';


// ---- ЭКРАН ЛЕНТЫ ЗАВЕДЕНИЙ ------

class EventsFeedPage extends StatefulWidget {
  const EventsFeedPage({Key? key}) : super(key: key);

  @override
  EventsFeedPageState createState() => EventsFeedPageState();
}



class EventsFeedPageState extends State<EventsFeedPage> {

  EventsList eventsList = EventListsManager.currentFeedEventsList;
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

  EventSortingOption _selectedSortingOption = EventSortingOption.createDateAsc;

  // ---- Переменные состояния экрана ----

  bool loading = true;
  bool refresh = false;

  // TODO - Сделать загрузку рекламы из БД
  // --- Рекламные переменные -----

  // --- Список рекламы ---
  //List<String> adList = ['Реклама №1', 'Реклама №2', 'Реклама №3', 'Реклама №4', 'Реклама №5'];

  List<AdUser> adList = AdUser.currentAllAdsList;
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

    // --- Считываем индексы, где будет стоять реклама ----

    adIndexesList = AdUser.getAdIndexesList(adList, adStep, firstIndexOfAd);

    // ---- Подгружаем город в фильтр из данных пользователя ---

    if (UserCustom.currentUser != null){
      setState(() {
        cityFromFilter = UserCustom.currentUser!.city;
      });
    }

    // ---- Получаем список мероприятий и рекламы

    await _getEventsList();

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

              // Экран загрузки

              if (loading) const LoadingScreen(loadingText: AppConstants.eventsLoadingMessage)

              // Экран обновления

              else if (refresh) Center(
                child: Text(
                  AppConstants.eventsRefreshMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )

              // Экран с фильтром и мероприятиями

              else Column(
                  children: [

                    // ---- Виджет фильтра

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

                    if (eventsList.eventsList.isEmpty) const Expanded(
                        child: Center(
                          child: Text(AppConstants.emptyMessage),
                        )
                    ),

                    // ---- Если список не пустой -----

                    if (eventsList.eventsList.isNotEmpty) Expanded(
                        child: ListView.builder(
                            padding: const EdgeInsets.all(10.0),
                            itemCount: allElementsList.length,
                            itemBuilder: (context, index) {

                              // --- ЕСЛИ ЭТО РЕКЛАМА, ОТОБРАЖАЕМ ВИДЖЕТ РЕКЛАМЫ ----

                              if (allElementsList[index].first == 'ad')  {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                      horizontal: 20
                                  ),
                                  child: HeadlineAndDesc(headline: adList[allElementsList[index].second].headline, description: 'реклама'),
                                );
                              }

                              // ----- ЕСЛИ МЕРОПРИЯТИЕ, ТО КАРТОЧКУ МЕРОПРИЯТИЯ ----

                              else {

                                // Переменная индекса мероприятия в списке, до смешивания с сущностями рекламы
                                int indexWithAddCountCorrection = allElementsList[index].second;

                                // ---- Виджет карточки

                                return CardWidgetForEventPromoPlaces(
                                  height: 450,
                                  event: eventsList.eventsList[indexWithAddCountCorrection],
                                  onTap: () async {
                                    // --- Переход на страницу просмотра мероприятия
                                    await goToEventViewScreen(indexWithAddCountCorrection);
                                  },
                                  // --- Функция на нажатие на карточке кнопки ИЗБРАННОЕ ---
                                  onFavoriteIconPressed: () async {
                                    await addOrDeleteInFav(indexWithAddCountCorrection);
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
      });

      // Подгружаем список мероприятий и рекламы
      await _getEventsList();

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _getEventsList() async {

    // ---- Обновляем счетчик выбранных настроек ----
    setState(() {
      _setFiltersCount(eventCategoryFromFilter, cityFromFilter, freePrice, today, onlyFromPlaceEvents, selectedStartDatePeriod, selectedEndDatePeriod);
    });

    // ----- РАБОТАЕМ СО СПИСКОМ МЕРОПРИЯТИЙ -----

    if (EventListsManager.currentFeedEventsList.eventsList.isEmpty){
      // ---- Если список пуст ----
      // ---- Считываем с БД заведения -----

      eventsList = await eventsList.getListFromDb();

    } else {
      // --- Если список не пустой ----
      // --- Подгружаем готовый список ----

      eventsList.eventsList = EventListsManager.currentFeedEventsList.eventsList;

    }

    // Фильтруем список и внедряем в него рекламу
    _filterListAndIncludeAd();

  }

  Future<void> refreshList() async {
    setState(() {
      refresh = true;
    });

    eventsList = EventsList();

    // Подгружаем список мероприятий с базы данных

    eventsList = await eventsList.getListFromDb();

    _filterListAndIncludeAd();

    setState(() {
      refresh = false;
    });
  }

  void _filterListAndIncludeAd(){



    setState(() {

      // Фильтруем список

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

      // Сортируем список

      eventsList.sortEntitiesList(_selectedSortingOption);

      // Внедряем рекламу

      allElementsList = AdUser.generateIndexedList(adIndexesList, eventsList.eventsList.length);

    });
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

    // Переходим на страницу заведения

    final results = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventViewScreen(eventId: eventsList.eventsList[indexWithAddCountCorrection].id),
      ),
    );

    // Если есть результат с той страницы

    if (results != null) {

      // Подгружаем мероприятие из общего списка
      EventCustom eventCustom = eventsList.getEntityFromFeedListById(eventsList.eventsList[indexWithAddCountCorrection].id);

      // Заменяем мероприятие на обновленное
      setState(() {
        eventsList.eventsList[indexWithAddCountCorrection] = eventCustom;
      });
    }
  }

  Future<void> addOrDeleteInFav(int indexWithAddCountCorrection) async {

    // ---- Если не зарегистрирован или не вошел ----
    if (UserCustom.currentUser?.uid == '' || UserCustom.currentUser?.uid == null)
    {
      _showSnackBar('Чтобы добавлять в избранное, нужно зарегистрироваться!', AppColors.attentionRed, 2);
    }

    // --- Если пользователь залогинен -----
    else {

      // --- Если уже в избранном ----
      if (eventsList.eventsList[indexWithAddCountCorrection].inFav == true)
      {

        // --- Удаляем из избранных ---
        String resDel = await eventsList.eventsList[indexWithAddCountCorrection].deleteFromFav();

        if (resDel == 'success'){
          _showSnackBar('Удалено из избранных', AppColors.attentionRed, 1);
        } else {
          _showSnackBar(resDel, AppColors.attentionRed, 1);
        }
      }
      else {
        // --- Если заведение не в избранном ----

        // -- Добавляем в избранное ----
        String res = await eventsList.eventsList[indexWithAddCountCorrection].addToFav();

        if (res == 'success') {

          _showSnackBar('Добавлено в избранные', Colors.green, 1);

        } else {
          _showSnackBar(res, AppColors.attentionRed, 1);
        }
      }
    }
  }

  void _showSnackBar(String text, Color color, int secondsToShow){
    showSnackBar(context, text, color, secondsToShow);
  }

}