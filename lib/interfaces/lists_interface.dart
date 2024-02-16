abstract class ILists<T, K, J>{
  Future<T> getListFromDb();
  Future<T> getFavListFromDb(String userId, {bool refresh = false});
  Future<T> getMyListFromDb(String userId, {bool refresh = false});
  K getEntityFromFeedListById(String id);
  void filterLists(Map<String, dynamic> mapOfArguments);
  void sortEntitiesList(J sorting);
  void deleteEntityFromCurrentFavList(String entityId);
  void addEntityToCurrentFavList(String entityId);
  void updateCurrentListFavInformation(String entityId, int favCounter, bool inFav);
  void deleteEntityFromCurrentEventLists(String eventId);
  void addEntityFromCurrentEventLists(K entity);
  Future<T> getEntitiesFromStringList(String listInString, {String decimal = ','});
}