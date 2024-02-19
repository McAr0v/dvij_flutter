import 'package:dvij_flutter/places/place_class.dart';
import 'package:dvij_flutter/places/place_list_manager.dart';
import 'package:dvij_flutter/places/place_sorting_options.dart';
import 'package:firebase_database/firebase_database.dart';

import '../database/database_mixin.dart';
import '../interfaces/lists_interface.dart';

class PlaceList implements ILists<PlaceList, Place, PlaceSortingOption>{
  List<Place> placeList = [];

  PlaceList({List<Place>? placeList}){
    this.placeList = placeList ?? this.placeList;
  }

  @override
  void addEntityFromCurrentEntitiesLists(Place entity) {
    // TODO: implement addEntityFromCurrentEntitiesLists
  }

  @override
  void addEntityToCurrentFavList(String entityId) {
    // TODO: implement addEntityToCurrentFavList
  }

  @override
  void deleteEntityFromCurrentEntitiesLists(String id) {
    // TODO: implement deleteEntityFromCurrentEntitiesLists
  }

  @override
  void deleteEntityFromCurrentFavList(String entityId) {
    // TODO: implement deleteEntityFromCurrentFavList
  }

  @override
  void filterLists(Map<String, dynamic> mapOfArguments) {
    // TODO: implement filterLists
  }

  @override
  Future<PlaceList> getEntitiesFromStringList(String listInString, {String decimal = ','}) {
    // TODO: implement getEntitiesFromStringList
    throw UnimplementedError();
  }

  @override
  Place getEntityFromFeedListById(String id) {
    // TODO: implement getEntityFromFeedListById
    throw UnimplementedError();
  }

  @override
  Future<PlaceList> getFavListFromDb(String userId, {bool refresh = false}) async {
    PlaceList places = PlaceList();
    PlaceListManager.currentFavPlacesList = PlaceList();
    List<String> placesId = [];

    String myPath = 'users/$userId/favPlaces/';
    DataSnapshot? myFolder = await MixinDatabase.getInfoFromDB(myPath);

    if (myFolder != null) {
      for (var idFolder in myFolder.children) {

        // ---- Считываем ID и добавляем в список ID

        DataSnapshot idSnapshot = idFolder.child('placeId');

        if (idSnapshot.exists){
          placesId.add(idSnapshot.value.toString());
        }
      }
    }

    // Если список ID не пустой, и не была вызвана функция обновления
    if (placesId.isNotEmpty){

      // Если список всей ленты не пустой, то будем забирать данные из него
      if (PlaceListManager.currentFeedPlacesList.placeList.isNotEmpty && !refresh) {
        for (String id in placesId) {
          Place myPlace = getEntityFromFeedListById(id);
          if (myPlace.id == id) {
            PlaceListManager.currentFavPlacesList.placeList.add(myPlace);
            places.placeList.add(myPlace);
          }
        }
      } else {
        // Если список ленты не прогружен, то считываем каждую сущность из БД
        for (var place in placesId){
          Place temp = Place.emptyPlace;
          temp = await temp.getEntityByIdFromDb(place);
          if (temp.id != ''){
            PlaceListManager.currentFavPlacesList.placeList.add(temp);
            places.placeList.add(temp);
          }
        }
      }
    }
    return places;
  }

  @override
  Future<PlaceList> getListFromDb() async {
    PlaceList places = PlaceList();
    PlaceListManager.currentFeedPlacesList = PlaceList();

    DataSnapshot? placesSnapshot = await MixinDatabase.getInfoFromDB('places');

    if (placesSnapshot != null) {
      for (var placeIdsFolder in placesSnapshot.children) {

        Place place = Place.emptyPlace;

        String placeId = placeIdsFolder.child('place_info').child('id').value.toString();

        place = await place.getEntityByIdFromDb(placeId);

        PlaceListManager.currentFeedPlacesList.placeList.add(place);
        places.placeList.add(place);

      }
    }
    return places;
  }

  @override
  Future<PlaceList> getMyListFromDb(String userId, {bool refresh = false}) async {
    PlaceList places = PlaceList();
    PlaceListManager.currentFeedPlacesList = PlaceList();
    List<String> placesId = [];

    String myPath = 'users/$userId/myPlaces/';
    DataSnapshot? myFolder = await MixinDatabase.getInfoFromDB(myPath);

    if (myFolder != null) {
      for (var idFolder in myFolder.children) {

        // ---- Считываем ID и добавляем в список ID

        DataSnapshot idSnapshot = idFolder.child('placeId');

        if (idSnapshot.exists){
          placesId.add(idSnapshot.value.toString());
        }
      }
    }

    // Если список ID не пустой, и не была вызвана функция обновления
    if (placesId.isNotEmpty){

      // Если список всей ленты не пустой, то будем забирать данные из него
      if (PlaceListManager.currentFeedPlacesList.placeList.isNotEmpty && !refresh) {
        for (String id in placesId) {
          Place myPlace = getEntityFromFeedListById(id);
          if (myPlace.id == id) {
            PlaceListManager.currentMyPlacesList.placeList.add(myPlace);
            places.placeList.add(myPlace);
          }
        }
      } else {
        // Если список ленты не прогружен, то считываем каждую сущность из БД
        for (var place in placesId){
          Place temp = Place.emptyPlace;
          temp = await temp.getEntityByIdFromDb(place);
          if (temp.id != ''){
            PlaceListManager.currentMyPlacesList.placeList.add(temp);
            places.placeList.add(temp);
          }
        }
      }
    }
    return places;
  }

  @override
  void sortEntitiesList(PlaceSortingOption sorting) {
    switch (sorting){

      case PlaceSortingOption.nameAsc: placeList.sort((a, b) => a.name.compareTo(b.name)); break;

      case PlaceSortingOption.nameDesc: placeList.sort((a, b) => b.name.compareTo(a.name)); break;

      case PlaceSortingOption.promoCountAsc: placeList.sort((a, b) => a.promoCount!.compareTo(b.promoCount!)); break;

      case PlaceSortingOption.promoCountDesc: placeList.sort((a, b) => b.promoCount!.compareTo(a.promoCount!)); break;

      case PlaceSortingOption.eventCountAsc: placeList.sort((a, b) => a.eventsCount!.compareTo(b.eventsCount!)); break;

      case PlaceSortingOption.eventCountDesc: placeList.sort((a, b) => b.eventsCount!.compareTo(a.eventsCount!)); break;

      case PlaceSortingOption.favCountAsc: placeList.sort((a, b) => a.addedToFavouritesCount!.compareTo(b.addedToFavouritesCount!)); break;

      case PlaceSortingOption.favCountDesc: placeList.sort((a, b) => b.addedToFavouritesCount!.compareTo(a.addedToFavouritesCount!)); break;

    }
  }

  @override
  void updateCurrentListFavInformation(String entityId, int favCounter, bool inFav) {
    // TODO: implement updateCurrentListFavInformation
  }

}