import 'package:firebase_database/firebase_database.dart';

class PlaceRole {
  late String id; // Идентификатор роли
  late String name; // Название роли
  late String desc; // описание роли

  PlaceRole({required this.name, required this.id, required this.desc});

  // Метод для преобразования данных из Firebase в объект City

  factory PlaceRole.fromSnapshot(DataSnapshot snapshot) {
    // Указываем путь к нашим полям
    DataSnapshot idSnapshot = snapshot.child('id');
    DataSnapshot nameSnapshot = snapshot.child('name');
    DataSnapshot descSnapshot = snapshot.child('desc');

    // Берем из них данные и заполняем в класс City. И возвращаем его
    return PlaceRole(
      id: idSnapshot.value.toString() ?? '',
      name: nameSnapshot.value.toString() ?? '',
      desc: descSnapshot.value.toString() ?? ''
    );
  }


  // Статическая переменная для хранения списка городов
  static List<PlaceRole> currentPlaceRoleList = [];

  // Метод для получения списка городов из Firebase и сохранения в currentCityList
  static Future<void> getPlaceRolesAndSave({bool order = true}) async {

    currentPlaceRoleList = await getPlaceRoles(order: order);

  }

  // Функция фильтрации городов по вводимому значению

  static List<PlaceRole> filterStrings(List<PlaceRole> inputList, String filter) {
    List<PlaceRole> newList = [];

    for (int i = 0; i<inputList.length; i++)
    {
      if (inputList[i].name.contains(filter))
      {
        newList.add(inputList[i]);
      }
    }

    return newList;
  }



  // Метод для добавления нового города или редактирования города в Firebase

  static Future<String> addAndEditPlaceRole(String name, String desc, {String id = ''}) async {
    try {
      String? roleKey;

      // --- Указываем папку, где будут хранится города ----

      DatabaseReference rolesReference = FirebaseDatabase.instance.ref().child('placesRoles');

      if (id == '') {

        // --- Генерируем уникальный ключ ---
        DatabaseReference newPlaceRoleReference = rolesReference.push();
        // ---- Получаем уникальный ключ ----
        roleKey = newPlaceRoleReference.key; // Получаем уникальный ключ

      }

      // --- Создаем окончательный путь ----
      final DatabaseReference reference =
      FirebaseDatabase.instance.ref().child('placesRoles').child(roleKey ?? id);

      // ---- Публикуем город -----
      await reference.set({
        'name': name,
        'id': roleKey ?? id,
        'desc': desc
      });

      // Обновляем список наших городов в локальную переменную
      await getPlaceRolesAndSave();

      // --- Возвращаем успех ----
      //TODO - Есть вариант, что тут может город не опубликоваться. Надо как то подумать, чтобы точно знать что он опубиковался
      return 'success';

    } catch (error) {
      // Видимо здесь проверка - если не удалось опубликовать город, то возвращаем ошибку
      return 'Error: $error';
    }
  }

  static Future<String> deletePlaceRole(String roleId) async {
    try {
      DatabaseReference reference = FirebaseDatabase.instance.ref().child('placesRoles').child(roleId);

      // Проверяем, существует ли город с указанным ID
      DataSnapshot snapshot = await reference.get();
      if (!snapshot.exists) {
        return 'Роль места не найдена';
      }

      // Удаляем город
      await reference.remove();

      // Обновляем список наших городов в локальную переменную
      await getPlaceRolesAndSave();

      return 'success';
    } catch (error) {
      return 'Ошибка при удалении города: $error';
    }
  }

  // Сортировка городов по имени

  static void sortPlaceRolesByName(List<PlaceRole> roles, bool order) {

    if (order) roles.sort((a, b) => a.name.compareTo(b.name));
    else {
      roles.sort((a, b) => b.name.compareTo(a.name));
    }
  }

  // Метод для получения списка городов из Firebase

  static Future<List<PlaceRole>> getPlaceRoles({bool order = true}) async {

    List<PlaceRole> placesRoles = [];

    // Указываем путь
    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('placesRoles');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    // Итерируем по каждому дочернему элементу
    // Здесь сделано так потому что мы не знаем ключа города
    // и нам нужен каждый город, независимо от ключа

    for (var childSnapshot in snapshot.children) {
      // заполняем город (City.fromSnapshot) из снимка данных
      // и обавляем в список городов
      placesRoles.add(PlaceRole.fromSnapshot(childSnapshot));
    }

    sortPlaceRolesByName(placesRoles, order);

    // Возвращаем список
    return placesRoles;
  }

  // Метод для поиска города по id
  static Future<PlaceRole?> getPlaceRoleById(String id) async {

    // Указываем путь
    final DatabaseReference reference =
    FirebaseDatabase.instance.ref().child('placesRoles');

    // Получаем снимок конкретного города, по id
    DataSnapshot snapshot = await reference.child(id).get();

    if (snapshot.value != null) {

      // Заполняем класс City данными из БД и возвращаем его ====
      return PlaceRole.fromSnapshot(snapshot);

    } else {
      // Если не нашел, возвращаем null
      //return null;
      return PlaceRole(name: '', id: '', desc: '');
    }
  }

  static String getPlaceRoleName (String id) {
    String result = 'Роль места не найдена';

    for (int i = 0; i < PlaceRole.currentPlaceRoleList.length; i++ )
    {
      if (PlaceRole.currentPlaceRoleList[i].id == id) {
        result = currentPlaceRoleList[i].name;
      }
    }
    return result;
  }

  static PlaceRole getPlaceRoleNameInRolesList (String id) {
    PlaceRole result = PlaceRole(name: 'Роль не найдена', id: '', desc: '');

    for (int i = 0; i < PlaceRole.currentPlaceRoleList.length; i++ )
    {
      if (PlaceRole.currentPlaceRoleList[i].id == id) {
        result = currentPlaceRoleList[i];
      }
    }
    return result;
  }

}