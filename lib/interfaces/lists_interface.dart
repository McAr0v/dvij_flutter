abstract class ILists<T, K, J>{
  /// ФУНКЦИЯ ЧТЕНИЯ СПИСКА СУЩНОСТЕЙ ДЛЯ FEED ИЗ БД
  /// <br><br>
  /// [T] - Класс списка сущности
  /// <br><br>
  /// Считывает сущности и добавляет в список Feed
  /// <br> Вернет список сущностей
  /// <br> Если сущностей не найдено, вернет пустой список
  Future<T> getListFromDb();

  /// ФУНКЦИЯ ЧТЕНИЯ СПИСКА СУЩНОСТЕЙ ДЛЯ FavList ИЗ БД
  /// <br><br>
  /// [T] - Класс списка сущности
  /// <br><br>
  /// Считывает сущности и добавляет в список FavList
  /// <br> Вернет список сущностей
  /// <br> Если сущностей не найдено, вернет пустой список
  Future<T> getFavListFromDb(String userId, {bool refresh = false});

  /// ФУНКЦИЯ ЧТЕНИЯ СПИСКА СУЩНОСТЕЙ ДЛЯ MyList ИЗ БД
  /// <br><br>
  /// [T] - Класс списка сущности
  /// <br><br>
  /// Считывает сущности и добавляет в список MyList
  /// <br> Вернет список сущностей
  /// <br> Если сущностей не найдено, вернет пустой список
  Future<T> getMyListFromDb(String userId, {bool refresh = false});

  /// ФУНКЦИЯ ЧТЕНИЯ СУЩНОСТИ ИЗ СПИСКА FEED
  /// <br><br>
  /// [K] - Класс сущности
  /// <br><br>
  /// Перебирает список сущностей Feed и если требуемый Id найден,
  /// возвращает эту сущность
  /// <br>
  /// <br> Принимает [id] для поиска
  K getEntityFromFeedListById(String id);

  /// ФУНКЦИЯ ФИЛЬТРАЦИИ СПИСКА
  /// <br><br>
  /// Просто фильтрует текущий список согласно параметрам из фильтра
  /// <br><br>
  /// Принимает словарь аргументов из фильтра.
  /// <br> Для генерации словаря есть функция в классе [generateMapForFilter]
  void filterLists(Map<String, dynamic> mapOfArguments);

  /// ФУНКЦИЯ СОРТИРОВКИ СПИСКА
  /// <br><br>
  /// [J] - Класс Enum по сортировке
  /// <br><br>
  /// Просто сортирует текущий список согласно параметрам
  void sortEntitiesList(J sorting);

  /// ФУНКЦИЯ УДАЛЕНИЯ СУЩНОСТИ ИЗ СПИСКА Fav_List
  /// <br><br>
  /// Перебирает список сущностей Fav_List и если требуемый Id найден,
  /// удаляет эту сущность
  /// <br>
  /// <br> Принимает [id] для поиска
  //void deleteEntityFromCurrentFavList(String entityId);

  /// ФУНКЦИЯ ДОБАВЛЕНИЯ СУЩНОСТИ В СПИСОК Fav_List
  /// <br><br>
  /// Перебирает список сущностей Feed, считывает из него по Id сущность,
  /// и добавляет эту сущность в Fav_List
  /// <br>
  /// <br> Принимает [id] для поиска
 // void addEntityToCurrentFavList(String entityId);

  /// ФУНКЦИЯ ОБНОВЛЕНИЯ НЕОБХОДИМЫХ СПИСКОВ ИНФОРМАЦИЕЙ ОБ ИЗБРАННОМ СУЩНОСТИ
  /// <br><br>
  /// Обновляет информацию в списках:
  /// <br>
  /// <br>Feed
  /// <br>Fav
  /// <br>My
  /// <br><br>
  /// Принимает [entityId], [usersIdsList], [inFav] для поиска сущности и обновления данных
  void updateCurrentListFavInformation(String entityId, List<String> usersIdsList, bool inFav);

  /// ФУНКЦИЯ УдАЛЕНИЯ СУЩНОСТИ ИЗ НЕОБХОДИМЫХ СПИСКОВ
  /// <br><br>
  /// Удаляет из списков:
  /// <br>
  /// <br>Feed
  /// <br>Fav
  /// <br>My
  /// <br><br>
  /// Принимает [id] для поиска
  void deleteEntityFromCurrentEntitiesLists(String id);

  /// ФУНКЦИЯ ДОБАВЛЕНИЯ СУЩНОСТИ В НЕОБХОДИМЫЕ СПИСКИ
  /// <br><br>
  /// [K] - Класс сущности
  /// Добавляет в списки:
  /// <br>
  /// <br>Feed
  /// <br>Fav
  /// <br>My
  /// <br><br>
  /// Принимает [entity] для добавления сущности в списки
  void addEntityFromCurrentEntitiesLists(K entity);

  /// ФУНКЦИЯ ЧТЕНИЯ СПИСКА СУЩНОСТЕЙ ИЗ [String]
  /// <br><br>
  /// Используется для чтения My или Fav сущностей
  /// <br><br>
  /// [T] - Класс списка сущности
  /// <br><br>
  /// Считывает сущности из Feed или БД и добавляет в возвращаемый список
  /// <br> Вернет список сущностей
  /// <br> Если сущностей не найдено, вернет пустой список
  Future<T> getEntitiesFromStringList(List<String> listInString);
}