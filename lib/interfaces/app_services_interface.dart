abstract class IAppServices<T> {
  Future<String> addOrEditEntityInDb() async {
    return '';
  }
  Future<String> deleteEntityFromDb() async {
    return '';
  }

  Future<List<T>> getEntitiesListFromDb({bool order = true}) async {
    return [];
  }

  T getEntityByIdFromList(String id);

}