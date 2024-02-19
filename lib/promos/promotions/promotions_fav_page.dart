import 'package:dvij_flutter/cities/city_class.dart';
import 'package:dvij_flutter/promos/promo_category_class.dart';
import 'package:dvij_flutter/promos/promo_sorting_options.dart';
import 'package:dvij_flutter/promos/promos_elements/promo_card_widget.dart';
import 'package:dvij_flutter/promos/promos_elements/promo_filter_page.dart';
import 'package:dvij_flutter/promos/promos_list_class.dart';
import 'package:dvij_flutter/promos/promos_list_manager.dart';
import 'package:dvij_flutter/promos/promotions/promo_view_page.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../ads/ad_user_class.dart';
import '../../classes/pair.dart';
import '../../classes/user_class.dart';
import '../../elements/loading_screen.dart';
import '../../elements/snack_bar.dart';
import '../../elements/text_and_icons_widgets/headline_and_desc.dart';


// ---- ЭКРАН ЛЕНТЫ ЗАВЕДЕНИЙ ------

class PromotionsFavPage extends StatefulWidget {
  const PromotionsFavPage({Key? key}) : super(key: key);

  @override
  PromotionsFavPageState createState() => PromotionsFavPageState();
}



class PromotionsFavPageState extends State<PromotionsFavPage> {

  // --- ОБЪЯВЛЯЕМ ПЕРЕМЕННЫЕ -----

  PromoList promosList = PromoListsManager.currentFavPromoList;
  late List<PromoCategory> promoCategoriesList;

  // --- Переменные фильтра по умолчанию ----

  PromoCategory promoCategoryFromFilter = PromoCategory(name: '', id: '');
  City cityFromFilter = City(name: '', id: '');

  bool today = false;
  bool onlyFromPlacePromos = false;

  DateTime selectedStartDatePeriod = DateTime(2100);
  DateTime selectedEndDatePeriod = DateTime(2100);

  // --- Счетчик выбранных значений фильтра ---

  int filterCount = 0;

  // --- Переменная сортировки по умолчанию ----

  PromoSortingOption _selectedSortingOption = PromoSortingOption.nameAsc;

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

    promoCategoriesList = PromoCategory.currentPromoCategoryList;

    // ---- Устанавливаем счетчик выбранных настроек в фильтре ----

    _setFiltersCount(
        promoCategoryFromFilter,
        cityFromFilter,
        today,
        onlyFromPlacePromos,
        selectedStartDatePeriod,
        selectedEndDatePeriod
    );

    // ----- РАБОТАЕМ СО СПИСКОМ МЕРОПРИЯТИЙ -----

    //EventsList tempEventsList = EventsList();

    if (PromoListsManager.currentFavPromoList.promosList.isEmpty){
      // ---- Если список пуст ----
      // ---- И Юзер залогинен
      // ---- Считываем с БД заведения -----

      if (UserCustom.currentUser?.uid != null && UserCustom.currentUser?.uid != ''){
        //tempEventsList = await EventCustom.getFavEvents(UserCustom.currentUser!.uid);
        promosList = await promosList.getFavListFromDb(UserCustom.currentUser!.uid);
      }

    } else {
      // --- Если список не пустой ----
      // --- Подгружаем готовый список ----

      //tempEventsList = EventCustom.currentFavEventsList;
      setState(() {
        promosList = PromoListsManager.currentFavPromoList;
      });


    }

    // --- Фильтруем список ----

    setState(() {
      promosList.filterLists(
          promosList.generateMapForFilter(
              promoCategoryFromFilter,
              cityFromFilter,
              today,
              onlyFromPlacePromos,
              selectedStartDatePeriod,
              selectedEndDatePeriod
          )
      );
    });

    // --- Считываем индексы, где будет стоять реклама ----

    adIndexesList = AdUser.getAdIndexesList(adList, adStep, firstIndexOfAd);

    setState(() {
      allElementsList = AdUser.generateIndexedList(adIndexesList, promosList.promosList.length);
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

            promosList = PromoList();

            if (UserCustom.currentUser?.uid != null || UserCustom.currentUser?.uid != ''){

              promosList = await promosList.getFavListFromDb(UserCustom.currentUser!.uid, refresh: true);

              setState(() {
                promosList.filterLists(
                    promosList.generateMapForFilter(
                        promoCategoryFromFilter,
                        cityFromFilter,
                        today,
                        onlyFromPlacePromos,
                        selectedStartDatePeriod,
                        selectedEndDatePeriod
                    )
                );
              });

              allElementsList = AdUser.generateIndexedList(adIndexesList, promosList.promosList.length);

            }

            setState(() {
              refresh = false;
            });

          },
          child: Stack (
            children: [
              if (UserCustom.currentUser?.uid == null || UserCustom.currentUser?.uid == '') Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Чтобы добавлять акции в избранные, нужно зарегистрироваться',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  )
              )
              else if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка акций')
              else if (refresh) Center(
                  child: Text(
                    'Подожди, идет обновление акций',
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
                                child: DropdownButton<PromoSortingOption>(
                                  style: Theme.of(context).textTheme.bodySmall,
                                  isExpanded: true,
                                  value: _selectedSortingOption,
                                  onChanged: (PromoSortingOption? newValue) {
                                    setState(() {
                                      _selectedSortingOption = newValue!;
                                      promosList.sortEntitiesList(_selectedSortingOption);
                                    });
                                  },
                                  items: const [
                                    DropdownMenuItem(
                                      value: PromoSortingOption.nameAsc,
                                      child: Text('По имени: А-Я'),
                                    ),
                                    DropdownMenuItem(
                                      value: PromoSortingOption.nameDesc,
                                      child: Text('По имени: Я-А'),
                                    ),
                                    DropdownMenuItem(
                                      value: PromoSortingOption.favCountAsc,
                                      child: Text('В избранном: по возрастанию'),
                                    ),
                                    DropdownMenuItem(
                                      value: PromoSortingOption.favCountDesc,
                                      child: Text('В избранном: по убыванию'),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )
                      ),

                      // ---- Если список пустой -----

                      if (promosList.promosList.isEmpty) Expanded(
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

                      if (promosList.promosList.isNotEmpty) Expanded(
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
                                  return PromoCardWidget(
                                    promo: promosList.promosList[indexWithAddCountCorrection],
                                    onTap: () async {

                                      // TODO - переделать на мероприятия
                                      final results = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PromoViewScreen(promoId: promosList.promosList[indexWithAddCountCorrection].id),
                                        ),
                                      );

                                      if (results != null) {
                                        promosList = PromoListsManager.currentFavPromoList;
                                        setState(() {
                                          promosList.filterLists(
                                              promosList.generateMapForFilter(
                                                  promoCategoryFromFilter,
                                                  cityFromFilter,
                                                  today,
                                                  onlyFromPlacePromos,
                                                  selectedStartDatePeriod,
                                                  selectedEndDatePeriod
                                              )
                                          );
                                        });

                                        // --- Считываем индексы, где будет стоять реклама ----

                                        adIndexesList = AdUser.getAdIndexesList(adList, adStep, firstIndexOfAd);

                                        setState(() {
                                          allElementsList = AdUser.generateIndexedList(adIndexesList, promosList.promosList.length);
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
                                        if (promosList.promosList[indexWithAddCountCorrection].inFav == true)
                                        {
                                          int favCounter = promosList.promosList[indexWithAddCountCorrection].addedToFavouritesCount!;
                                          setState(() {
                                            loading = true;
                                            // Обновляем текущий список
                                            promosList.promosList[indexWithAddCountCorrection].inFav = false;
                                            favCounter --;
                                            promosList.promosList[indexWithAddCountCorrection].addedToFavouritesCount = favCounter;
                                            // Обновляем общий список из БД
                                            promosList.promosList[indexWithAddCountCorrection].updateCurrentListFavInformation();

                                            //EventCustom.updateCurrentEventListFavInformation(eventsList[indexWithAddCountCorrection].id, favCounter, false);

                                          });
                                          // --- Удаляем из избранных ---
                                          String resDel = await promosList.promosList[indexWithAddCountCorrection].deleteFromFav();

                                          setState(() {
                                            promosList = PromoListsManager.currentFavPromoList;
                                            allElementsList = AdUser.generateIndexedList(adIndexesList, promosList.promosList.length);
                                            loading = false;
                                          });

                                          if (resDel == 'success'){
                                            // Если удаление успешное, обновляем 2 списка - текущий на экране, и общий загруженный из БД
                                            _showSnackBar('Удалено из избранных', AppColors.attentionRed, 1);

                                          } else {
                                            // Если удаление из избранных не прошло, показываем сообщение
                                            _showSnackBar(resDel, AppColors.attentionRed, 1);
                                          }
                                        }
                                        else {
                                          // --- Если заведение не в избранном ----

                                          // -- Добавляем в избранное ----
                                          String res = await promosList.promosList[indexWithAddCountCorrection].addToFav();

                                          // ---- Инициализируем счетчик добавивших в избранное
                                          int favCounter = promosList.promosList[indexWithAddCountCorrection].addedToFavouritesCount!;

                                          if (res == 'success') {
                                            // --- Если добавилось успешно, так же обновляем текущий список и список из БД
                                            setState(() {
                                              // Обновляем текущий список
                                              promosList.promosList[indexWithAddCountCorrection].inFav = true;
                                              favCounter ++;
                                              promosList.promosList[indexWithAddCountCorrection].addedToFavouritesCount = favCounter;

                                              promosList.promosList[indexWithAddCountCorrection].updateCurrentListFavInformation();

                                              promosList = PromoList();
                                              promosList = PromoListsManager.currentFavPromoList;
                                              allElementsList = AdUser.generateIndexedList(adIndexesList, promosList.promosList.length);

                                              // Обновляем список из БД
                                              //EventCustom.updateCurrentEventListFavInformation(eventsList[indexWithAddCountCorrection].id, favCounter, true);

                                            });
                                            _showSnackBar('Добавлено в избранные', Colors.green, 1);

                                          } else {
                                            // Если добавление прошло неудачно, отображаем всплывающее окно
                                            _showSnackBar(res, AppColors.attentionRed, 1);
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
      PromoCategory promoCategoryFromFilter,
      City cityFromFilter,
      bool todayFromFilter,
      bool onlyFromPlaceEventsFromFilter,
      DateTime selectedStartDatePeriod,
      DateTime selectedEndDatePeriod
      ){

    int count = 0;

    // --- Если значения не соответствуют дефолтным, то плюсуем счетчик ----
    if (promoCategoryFromFilter.name != ''){
      count++;
    }

    if (cityFromFilter.name != ''){
      count++;
    }

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
    final results = await Navigator.of(context).push(_createPopupFilter(promoCategoriesList));

    // Если пользователь выбрал что-то в диалоге фильтра
    if (results != null) {
      // Устанавливаем значения, которые он выбрал
      setState(() {
        loading = true;
        cityFromFilter = results[0];
        promoCategoryFromFilter = results[1];
        today = results [2];
        onlyFromPlacePromos = results [3];
        selectedStartDatePeriod = results[4];
        selectedEndDatePeriod = results[5];
        promosList = PromoList();

        // ---- Обновляем счетчик выбранных настроек ----
        _setFiltersCount(promoCategoryFromFilter, cityFromFilter, today, onlyFromPlacePromos, selectedStartDatePeriod, selectedEndDatePeriod);

      });

      // --- Заново подгружаем список из БД ---
      promosList.promosList = PromoListsManager.currentFavPromoList.promosList;
      //tempList = EventCustom.currentFavEventsList;

      // --- Фильтруем список согласно новым выбранным данным из фильтра ----
      setState(() {
        promosList.filterLists(
            promosList.generateMapForFilter(
                promoCategoryFromFilter,
                cityFromFilter,
                today,
                onlyFromPlacePromos,
                selectedStartDatePeriod,
                selectedEndDatePeriod
            )
        );
      });



      setState(() {
        allElementsList = AdUser.generateIndexedList(adIndexesList, promosList.promosList.length);
        loading = false;
      });
    }
  }

  // ----- Путь для открытия всплывающей страницы фильтра ----

  Route _createPopupFilter(List<PromoCategory> categories) {
    return PageRouteBuilder(

      pageBuilder: (context, animation, secondaryAnimation) {

        // --- Сама страница фильтра ---
        return PromoFilterPage(
          categories: categories,
          chosenCategory: promoCategoryFromFilter,
          chosenCity: cityFromFilter,
          onlyFromPlacePromos: onlyFromPlacePromos,
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