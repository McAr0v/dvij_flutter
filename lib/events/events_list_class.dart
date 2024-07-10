import 'package:dvij_flutter/current_user/user_class.dart';
import 'package:dvij_flutter/events/event_category_class.dart';
import 'package:dvij_flutter/events/event_sorting_options.dart';
import 'package:dvij_flutter/events/events_list_manager.dart';
import 'package:dvij_flutter/interfaces/lists_interface.dart';
import 'package:dvij_flutter/places/users_my_place/my_places_class.dart';
import 'package:dvij_flutter/users/place_users_roles.dart';
import 'package:firebase_database/firebase_database.dart';
import '../cities/city_class.dart';
import '../database/database_mixin.dart';
import 'event_class.dart';

class EventsList implements ILists<EventsList, EventCustom, EventSortingOption>{
  List<EventCustom> eventsList = [];

  EventsList({List<EventCustom>? eventsList}){
    this.eventsList = eventsList ?? this.eventsList;
  }

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

    DataSnapshot? eventsSnapshot = await MixinDatabase.getInfoFromDB('events');

    if (eventsSnapshot != null) {
      for (DataSnapshot eventIdsFolder in eventsSnapshot.children) {

        EventCustom event = EventCustom.emptyEvent.getEntityFromSnapshot(eventIdsFolder);

        EventListsManager.currentFeedEventsList.eventsList.add(event);
        events.eventsList.add(event);

      }
    }
    return events;
  }

  @override
  Future<EventsList> getFavListFromDb(String userId, {bool refresh = false}) async {
    EventsList events = EventsList();

    EventsList downloadedEventsList = EventListsManager.currentFeedEventsList;

    if (downloadedEventsList.eventsList.isEmpty || refresh) {
      EventsList tempList = await getListFromDb();
      downloadedEventsList = tempList;
    }

    for (EventCustom event in downloadedEventsList.eventsList){
      if (event.favUsersIds.contains(userId)){
        events.eventsList.add(event);
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
    List<MyPlaces> myPlaces = UserCustom.currentUser!.myPlaces;

    EventsList events = EventsList();

    EventsList downloadedEventsList = EventListsManager.currentFeedEventsList;

    if (downloadedEventsList.eventsList.isEmpty || refresh) {
      EventsList tempList = await getListFromDb();
      downloadedEventsList = tempList;
    }

    for (EventCustom event in downloadedEventsList.eventsList){
      if (event.creatorId == userId){
        events.eventsList.add(event);
      } else if (event.placeId != '' && myPlaces.isNotEmpty) {
        for (MyPlaces place in myPlaces){
          if (place.placeId == event.placeId
              && (place.placeRole.roleInPlaceEnum != PlaceUserRoleEnum.reader && place.placeRole.roleInPlaceEnum != PlaceUserRoleEnum.org)){
            events.eventsList.add(event);
            break;
          }
        }
      }
    }

    return events;
  }

  /// ФУНКЦИЯ ГЕНЕРАЦИИ СЛОВАРЯ ДЛЯ ФИЛЬТРА
  /// <br><br>
  /// Автоматически генерирует ключ-значение, для передачи
  /// в функцию [filterLists]
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
  void filterLists(Map<String, dynamic> mapOfArguments) {

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
          generateMapForFilter(eventCategoryFromFilter, cityFromFilter, freePrice, today, onlyFromPlaceEvents, selectedStartDatePeriod, selectedEndDatePeriod)
      );

      if (result) {
        events.eventsList.add(event);
      }
    }
    eventsList = events.eventsList;
  }

  @override
  void sortEntitiesList(EventSortingOption sorting) {
    switch (sorting){

      case EventSortingOption.nameAsc: eventsList.sort((a, b) => b.headline.compareTo(a.headline)); break;

      case EventSortingOption.nameDesc: eventsList.sort((a, b) => a.headline.compareTo(b.headline)); break;

      case EventSortingOption.favCountAsc: eventsList.sort((a, b) => b.favUsersIds.length.compareTo(a.favUsersIds.length)); break;

      case EventSortingOption.favCountDesc: eventsList.sort((a, b) => a.favUsersIds.length.compareTo(b.favUsersIds.length)); break;

      case EventSortingOption.fromDb: eventsList; break;

      case EventSortingOption.createDateAsc: eventsList.sort((a,b) => b.createDate.compareTo(a.createDate)); break;

      case EventSortingOption.createDateDesc: eventsList.sort((a,b) => a.createDate.compareTo(b.createDate)); break;

    }
  }

  @override
  void updateCurrentListFavInformation(String entityId, List<String> usersIdsList, bool inFav) {
    // ---- Функция обновления списка из БД при добавлении или удалении из избранного

    for (EventCustom event in EventListsManager.currentFeedEventsList.eventsList){
      if (event.id == entityId){
        event.favUsersIds = usersIdsList;
        event.inFav = inFav;
        break;
      }
    }

  }

  @override
  void deleteEntityFromCurrentEntitiesLists(String eventId) {
    EventListsManager.currentFeedEventsList.eventsList.removeWhere((event) => event.id == eventId);
  }

  @override
  Future<EventsList> getEntitiesFromStringList(List<String> listInString) async {
    EventsList eventsList = EventsList();

    for (int i = 0; i < listInString.length; i++){
      EventCustom tempEvent = eventsList.getEntityFromFeedListById(listInString[i]);

      if (tempEvent.id != ''){
        eventsList.eventsList.add(tempEvent);
      } else {
        tempEvent = await tempEvent.getEntityByIdFromDb(listInString[i]);
        if (tempEvent.id != ''){
          eventsList.eventsList.add(tempEvent);
        }
      }
    }

    return eventsList;
  }

  @override
  void addEntityFromCurrentEntitiesLists(EventCustom entity) {
    EventListsManager.currentFeedEventsList.eventsList.add(entity);
  }

  @override
  void updateCurrentEntityInEntitiesList(EventCustom newEvent) {
    for (EventCustom oldEvent in EventListsManager.currentFeedEventsList.eventsList){
      if (oldEvent.id == newEvent.id){
        oldEvent = newEvent;
        break;
      }
    }
  }
}