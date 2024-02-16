abstract class IEntity <T> {
  Map<String, dynamic> generateEntityDataCode();
  void updateCurrentListFavInformation();
  Future<String> publishToDb();
  Future<String> deleteFromDb();
  void deleteEntityFromCurrentEntityLists();
  void addEntityToCurrentEventLists();
  T getEntityFromFeedList(String id);
  Future<String> deleteEntityIdFromPlace(String placeId);
  bool checkFilter (Map<String, dynamic> mapOfArguments);
  Future<T> getEntityById(String eventId);
  Future<int> getFavCount();
  Future<bool> addedInFavOrNot();
  Future<String> addToFav();
  Future<String> deleteFromFav();
}