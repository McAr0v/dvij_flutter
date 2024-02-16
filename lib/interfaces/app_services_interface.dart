abstract class IAppServices<T> {
  Future<String> addOrEditEntityInDb();
  Future<String> deleteEntityFromDb();
  Future<List<T>> getEntitiesListFromDb({bool order = true});
  T getEntityByIdFromList(String id);

}