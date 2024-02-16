import 'package:dvij_flutter/events/event_category_class.dart';
import 'package:dvij_flutter/events/event_sorting_options.dart';
import 'package:dvij_flutter/events/events_list_manager.dart';
import 'package:dvij_flutter/interfaces/lists_interface.dart';
import 'package:firebase_database/firebase_database.dart';

import '../cities/city_class.dart';
import '../database/database_mixin.dart';
import 'event_class.dart';

class EventsList implements ILists<EventsList, EventCustom, EventSortingOption>{
  List<EventCustom> eventsList = [];

  EventsList({List<EventCustom>? eventsList}){
    this.eventsList = eventsList ?? this.eventsList;
  }

  //EventsList currentFeedEventsList = EventsList();
  //EventsList currentFavEventsList = EventsList();
  //EventsList currentMyEventsList = EventsList();

  @override
  String toString() {
    if (eventsList.isEmpty){
      return 'Список мероприятий пуст';
    } else {
      String result = '';
      for (EventCustom event in eventsList){
        result = '$result${event.id} - ${event.headline}, ';
      }
      return result;
    }
  }

  @override
  Future<EventsList> getListFromDb() async {
    EventsList events = EventsList();
    EventListsManager.currentFeedEventsList = EventsList();

    DataSnapshot? snapshot = await MixinDatabase.getInfoFromDB('events');

    if (snapshot != null) {
      for (var childSnapshot in snapshot.children) {

        EventCustom event = EventCustom.fromSnapshot(childSnapshot.child('event_info'));

        event.inFav = await EventCustom.addedInFavOrNot(event.id);
        event.addedToFavouritesCount = await EventCustom.getFavCount(event.id);

        EventListsManager.currentFeedEventsList.eventsList.add(event);
        events.eventsList.add(event);

      }
    }
    return events;
  }

  @override
  Future<EventsList> getFavListFromDb(String userId, {bool refresh = false}) async {
    EventsList events = EventsList();
    EventListsManager.currentFavEventsList = EventsList();
    List<String> eventsId = [];

    // TODO !!! Сделать загрузку списка избранного при загрузке информации пользователя. Здесь обращаться к уже готовому списку
    // TODO !!! Не забыть реализовать обновление списка избранных при добавлении и удалении из избранных
    String favPath = 'users/$userId/favEvents/';
    DataSnapshot? snapshot = await MixinDatabase.getInfoFromDB(favPath);

    if (snapshot != null) {
      for (var childSnapshot in snapshot.children) {

        DataSnapshot idSnapshot = childSnapshot.child('eventId');

        if (idSnapshot.exists){
          eventsId.add(idSnapshot.value.toString());
        }
      }
    }

    // Если список избранных ID не пустой

    if (eventsId.isNotEmpty){

      // Если список всей ленты не пустой и не была вызвана функция обновления, то будем забирать данные из него
      if (EventListsManager.currentFeedEventsList.eventsList.isNotEmpty && !refresh){

        for (String id in eventsId) {
          EventCustom favEvent = getEntityFromFeedListById(id);
          if (favEvent.id != ''){
            if (favEvent.id == id){
              EventListsManager.currentFavEventsList.eventsList.add(favEvent);
              events.eventsList.add(favEvent);
            }
          }
        }

      } else {

        // Если список ленты не прогружен, то считываем каждую сущность из БД
        for (String event in eventsId){

          EventCustom temp = EventCustom.emptyEvent;
          temp = await temp.getEventById(event);

          if (temp.id != ''){
            EventListsManager.currentFavEventsList.eventsList.add(temp);
            events.eventsList.add(temp);
          }
        }
      }
    }
    return events;
  }

  @override
  EventCustom getEntityFromFeedListById(String id) {
    return EventListsManager.currentFeedEventsList.eventsList.firstWhere((
        element) => element.id == id, orElse: () => EventCustom.emptyEvent);
  }

  @override
  Future<EventsList> getMyListFromDb(String userId, {bool refresh = false}) async {
    EventsList events = EventsList();
    EventListsManager.currentMyEventsList = EventsList();
    List<String> eventsId = [];

    // TODO !!! Сделать загрузку списка моих сущностей при загрузке информации пользователя. Здесь обращаться к уже готовому списку
    // TODO !!! Не забыть реализовать обновление списка моих сущностей при добавлении и удалении из раздела мои
    String myPath = 'users/$userId/myEvents/';
    DataSnapshot? snapshot = await MixinDatabase.getInfoFromDB(myPath);

    if (snapshot != null) {
      for (var childSnapshot in snapshot.children) {

        DataSnapshot idSnapshot = childSnapshot.child('eventId');

        if (idSnapshot.exists){
          eventsId.add(idSnapshot.value.toString());
        }
      }
    }

    // Если список избранных ID не пустой, и не была вызвана функция обновления
    if (eventsId.isNotEmpty){

      // Если список всей ленты не пустой, то будем забирать данные из него
      if (EventListsManager.currentFeedEventsList.eventsList.isNotEmpty && !refresh) {
        for (String id in eventsId) {
          EventCustom myEvent = getEntityFromFeedListById(id);
          if (myEvent.id == id) {
            EventListsManager.currentMyEventsList.eventsList.add(myEvent);
            events.eventsList.add(myEvent);
          }
        }
      } else {
        // Если список ленты не прогружен, то считываем каждую сущность из БД
        for (var event in eventsId){
          EventCustom temp = EventCustom.emptyEvent;
          temp = await temp.getEventById(event);
          if (temp.id != ''){
            EventListsManager.currentMyEventsList.eventsList.add(temp);
            events.eventsList.add(temp);
          }
        }
      }
    }
    return events;
  }

  Map<String, dynamic> generateMapForFilter (
      EventCategory eventCategoryFromFilter,
      City cityFromFilter,
      bool freePrice,
      bool today,
      bool onlyFromPlaceEvents,
      DateTime selectedStartDatePeriod,
      DateTime selectedEndDatePeriod
      ){
    return {
      'eventCategoryFromFilter': eventCategoryFromFilter,
      'cityFromFilter': cityFromFilter,
      'freePrice': freePrice,
      'today': today,
      'onlyFromPlaceEvents': onlyFromPlaceEvents,
      'selectedStartDatePeriod': selectedStartDatePeriod,
      'selectedEndDatePeriod': selectedEndDatePeriod,
    };
  }

  @override
  EventsList filterLists(Map<String, dynamic> mapOfArguments) {

    EventCategory eventCategoryFromFilter = mapOfArguments['eventCategoryFromFilter'];
    City cityFromFilter = mapOfArguments['cityFromFilter'];
    bool freePrice = mapOfArguments['freePrice'];
    bool today = mapOfArguments['today'];
    bool onlyFromPlaceEvents = mapOfArguments['onlyFromPlaceEvents'];
    DateTime selectedStartDatePeriod = mapOfArguments['selectedStartDatePeriod'];
    DateTime selectedEndDatePeriod = mapOfArguments['selectedEndDatePeriod'];

    EventsList events = EventsList();

    for (EventCustom event in eventsList){
      bool result = event.checkFilter(
          eventCategoryFromFilter,
          cityFromFilter,
          freePrice,
          today,
          onlyFromPlaceEvents,
          selectedStartDatePeriod,
          selectedEndDatePeriod
      );

      if (result) {
        events.eventsList.add(event);
      }
    }
    // Возвращаем список
    return events;
  }

  @override
  void sortEntitiesList(EventSortingOption sorting) {
    switch (sorting){

      case EventSortingOption.nameAsc: eventsList.sort((a, b) => a.headline.compareTo(b.headline)); break;

      case EventSortingOption.nameDesc: eventsList.sort((a, b) => b.headline.compareTo(a.headline)); break;

      case EventSortingOption.favCountAsc: eventsList.sort((a, b) => a.addedToFavouritesCount!.compareTo(b.addedToFavouritesCount!)); break;

      case EventSortingOption.favCountDesc: eventsList.sort((a, b) => b.addedToFavouritesCount!.compareTo(a.addedToFavouritesCount!)); break;

    }
  }

  @override
  void deleteEntityFromCurrentFavList(String entityId) {
    EventListsManager.currentFavEventsList.eventsList.removeWhere((event) => event.id == entityId);
  }

  @override
  void addEntityToCurrentFavList(String entityId) {
    for (var event in EventListsManager.currentFeedEventsList.eventsList){
      if (event.id == entityId){
        EventListsManager.currentFavEventsList.eventsList.add(event);
        break;
      }
    }
  }

  @override
  void updateCurrentListFavInformation(String entityId, int favCounter, bool inFav) {
    // ---- Функция обновления списка из БД при добавлении или удалении из избранного

    for (int i = 0; i<EventListsManager.currentFeedEventsList.eventsList.length; i++){
      // Если ID совпадает
      if (EventListsManager.currentFeedEventsList.eventsList[i].id == entityId){
        // Обновляем данные об состоянии этого заведения как избранного
        EventListsManager.currentFeedEventsList.eventsList[i].addedToFavouritesCount = favCounter;
        EventListsManager.currentFeedEventsList.eventsList[i].inFav = inFav;
        break;
      }
    }

    for (int i = 0; i<EventListsManager.currentFavEventsList.eventsList.length; i++){
      // Если ID совпадает
      if (EventListsManager.currentFavEventsList.eventsList[i].id == entityId){
        // Обновляем данные об состоянии этого заведения как избранного
        EventListsManager.currentFavEventsList.eventsList[i].addedToFavouritesCount = favCounter;
        EventListsManager.currentFavEventsList.eventsList[i].inFav = inFav;
        break;
      }
    }

    for (int i = 0; i<EventListsManager.currentMyEventsList.eventsList.length; i++){
      // Если ID совпадает
      if (EventListsManager.currentMyEventsList.eventsList[i].id == entityId){
        // Обновляем данные об состоянии этого заведения как избранного
        EventListsManager.currentMyEventsList.eventsList[i].addedToFavouritesCount = favCounter;
        EventListsManager.currentMyEventsList.eventsList[i].inFav = inFav;
        break;
      }
    }
  }

  @override
  void deleteEntityFromCurrentEventLists(String eventId) {
    EventListsManager.currentFeedEventsList.eventsList.removeWhere((event) => event.id == eventId);
    EventListsManager.currentFavEventsList.eventsList.removeWhere((event) => event.id == eventId);
    EventListsManager.currentMyEventsList.eventsList.removeWhere((event) => event.id == eventId);
  }

  @override
  Future<EventsList> getEntitiesFromStringList(String listInString, {String decimal = ','}) async {
    EventsList eventsList = EventsList();

    List<String> splittedString = listInString.split(decimal);

    for (int i = 0; i < splittedString.length; i++){
      EventCustom tempEvent = eventsList.getEntityFromFeedListById(splittedString[i]);

      if (tempEvent.id != ''){
        eventsList.eventsList.add(tempEvent);
      } else {
        tempEvent = await tempEvent.getEventById(splittedString[i]);
        if (tempEvent.id != ''){
          eventsList.eventsList.add(tempEvent);
        }
      }
    }

    return eventsList;
  }

  @override
  void addEntityFromCurrentEventLists(EventCustom entity) {
    EventListsManager.currentFeedEventsList.eventsList.add(entity);
    EventListsManager.currentMyEventsList.eventsList.add(entity);
    if(entity.inFav != null && entity.inFav!) EventListsManager.currentFavEventsList.eventsList.add(entity);
  }
}