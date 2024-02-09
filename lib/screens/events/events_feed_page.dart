import 'package:dvij_flutter/classes/city_class.dart';
import 'package:dvij_flutter/classes/event_category_class.dart';
import 'package:dvij_flutter/classes/event_sorting_options.dart';
import 'package:dvij_flutter/elements/events_elements/event_filter_page.dart';
import 'package:dvij_flutter/screens/events/event_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../classes/ads/ad_admin_class.dart';
import '../../classes/ads/ad_user_class.dart';
import '../../classes/event_class.dart';
import '../../classes/pair.dart';
import '../../classes/user_class.dart';
import '../../elements/events_elements/event_card_widget.dart';
import '../../elements/loading_screen.dart';
import '../../elements/snack_bar.dart';
import '../../elements/text_and_icons_widgets/headline_and_desc.dart';


// ---- ЭКРАН ЛЕНТЫ ЗАВЕДЕНИЙ ------

class EventsFeedPage extends StatefulWidget {
  const EventsFeedPage({Key? key}) : super(key: key);

  @override
  _EventsFeedPageState createState() => _EventsFeedPageState();
}



class _EventsFeedPageState extends State<EventsFeedPage> {

  // --- ОБЪЯВЛЯЕМ ПЕРЕМЕННЫЕ -----

  late List<EventCustom> eventsList;
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
  List<String> adList = ['Реклама №1', 'Реклама №2', 'Реклама №3', 'Реклама №4', 'Реклама №5'];
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

    // ---- Подгружаем город в фильтр из данных пользователя ---

    if (UserCustom.currentUser != null){
      if (UserCustom.currentUser!.city != ''){
        City usersCity = City.getCityByIdFromList(UserCustom.currentUser!.city);
        setState(() {
          cityFromFilter = usersCity;
        });
      }
    }

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

    List<EventCustom> tempEventsList = [];

    if (EventCustom.currentFeedEventsList.isEmpty){
      // ---- Если список пуст ----
      // ---- Считываем с БД заведения -----

     tempEventsList = await EventCustom.getAllEvents();

    } else {
      // --- Если список не пустой ----
      // --- Подгружаем готовый список ----

      tempEventsList = EventCustom.currentFeedEventsList;

    }

    // --- Фильтруем список ----

    setState(() {
      eventsList = EventCustom.filterEvents(
          eventCategoryFromFilter,
          cityFromFilter,
          freePrice,
          today,
          onlyFromPlaceEvents,
          tempEventsList,
          selectedStartDatePeriod,
          selectedEndDatePeriod
      );
    });

    // --- Считываем индексы, где будет стоять реклама ----

    adIndexesList = AdUser.getAdIndexesList(adList, adStep, firstIndexOfAd);

    setState(() {
      allElementsList = AdUser.generateIndexedList(adIndexesList, eventsList.length);
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

            eventsList = [];

            List<EventCustom> tempEventsList = await EventCustom.getAllEvents();

            setState(() {
              eventsList = EventCustom.filterEvents(eventCategoryFromFilter, cityFromFilter, freePrice, today, onlyFromPlaceEvents, tempEventsList, selectedStartDatePeriod, selectedEndDatePeriod);

            });

            setState(() {
              refresh = false;
            });

          },
          child: Stack (
            children: [
              if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка мероприятий')
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
                                    EventCustom.sortEvents(_selectedSortingOption, eventsList);
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

                    if (eventsList.isEmpty) Expanded(
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

                    if (eventsList.isNotEmpty) Expanded(
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
                                  event: eventsList[indexWithAddCountCorrection],
                                  onTap: () async {

                                    // TODO - переделать на мероприятия
                                    final results = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EventViewScreen(eventId: eventsList[indexWithAddCountCorrection].id),
                                      ),
                                    );

                                    if (results != null) {
                                      setState(() {
                                        eventsList[indexWithAddCountCorrection].inFav = results[0].toString();
                                        eventsList[indexWithAddCountCorrection].addedToFavouritesCount = results[1].toString();
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
                                      if (eventsList[indexWithAddCountCorrection].inFav == 'true')
                                      {
                                        // --- Удаляем из избранных ---
                                        String resDel = await EventCustom.deleteEventFromFav(eventsList[indexWithAddCountCorrection].id);
                                        // ---- Инициализируем счетчик -----
                                        int favCounter = int.parse(eventsList[indexWithAddCountCorrection].addedToFavouritesCount!);

                                        if (resDel == 'success'){
                                          // Если удаление успешное, обновляем 2 списка - текущий на экране, и общий загруженный из БД
                                          setState(() {
                                            // Обновляем текущий список
                                            eventsList[indexWithAddCountCorrection].inFav = 'false';
                                            favCounter --;
                                            eventsList[indexWithAddCountCorrection].addedToFavouritesCount = favCounter.toString();
                                            // Обновляем общий список из БД
                                            EventCustom.updateCurrentEventListFavInformation(eventsList[indexWithAddCountCorrection].id, favCounter.toString(), 'false');

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
                                        String res = await EventCustom.addEventToFav(eventsList[indexWithAddCountCorrection].id);

                                        // ---- Инициализируем счетчик добавивших в избранное
                                        int favCounter = int.parse(eventsList[indexWithAddCountCorrection].addedToFavouritesCount!);

                                        if (res == 'success') {
                                          // --- Если добавилось успешно, так же обновляем текущий список и список из БД
                                          setState(() {
                                            // Обновляем текущий список
                                            eventsList[indexWithAddCountCorrection].inFav = 'true';
                                            favCounter ++;
                                            eventsList[indexWithAddCountCorrection].addedToFavouritesCount = favCounter.toString();
                                            // Обновляем список из БД
                                            EventCustom.updateCurrentEventListFavInformation(eventsList[indexWithAddCountCorrection].id, favCounter.toString(), 'true');
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
        eventsList = [];

        // ---- Обновляем счетчик выбранных настроек ----
        _setFiltersCount(eventCategoryFromFilter, cityFromFilter, freePrice, today, onlyFromPlaceEvents, selectedStartDatePeriod, selectedEndDatePeriod);

      });

      // --- Заново подгружаем список из БД ---
      List<EventCustom> tempList = [];
      tempList = EventCustom.currentFeedEventsList;

      // --- Фильтруем список согласно новым выбранным данным из фильтра ----
      setState(() {
        eventsList = EventCustom.filterEvents(eventCategoryFromFilter, cityFromFilter, freePrice, today, onlyFromPlaceEvents, tempList, selectedStartDatePeriod, selectedEndDatePeriod);
      });

      allElementsList = AdUser.generateIndexedList(adIndexesList, eventsList.length);

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