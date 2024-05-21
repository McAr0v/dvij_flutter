import 'package:firebase_database/firebase_database.dart';

// НУЖНО ИЗБАВИТЬСЯ ОТ ЭТОГО
class RoleInApp {
  late String id; // Идентификатор роли
  late String name; // Название роли

  RoleInApp({required this.name, required this.id});

  // Метод для преобразования данных из Firebase в объект RoleInApp

  factory RoleInApp.fromSnapshot(DataSnapshot snapshot) {
    // Указываем путь к нашим полям
    DataSnapshot idSnapshot = snapshot.child('id');
    DataSnapshot nameSnapshot = snapshot.child('name');

    // Берем из них данные и заполняем в класс Gender И возвращаем его
    return RoleInApp(
      id: idSnapshot.value.toString() ?? '',
      name: nameSnapshot.value.toString() ?? '',
    );
  }


  // Статическая переменная для хранения списка ролей
  static List<RoleInApp> currentRoleInAppList = [];

  // Метод для получения списка ролей из Firebase и сохранения в переменную
  static Future<void> getRolesInAppAndSave({bool order = true}) async {

    currentRoleInAppList = await getRolesInApp(order: order);

  }

  static  RoleInApp getRoleInAppFromList (String roleId){
    if (currentRoleInAppList.isNotEmpty){
      for(RoleInApp role in currentRoleInAppList){
        if (role.id == roleId){
          return role;
          break;
        }
      }
    }
    return RoleInApp(name: '', id: '');

  }

  // Функция фильтрации ролей по вводимому значению

  static List<RoleInApp> filterRolesInApp(List<RoleInApp> inputList, String filter) {
    List<RoleInApp> newList = [];

    for (int i = 0; i<inputList.length; i++)
    {
      if (inputList[i].name.contains(filter))
      {
        newList.add(inputList[i]);
      }
    }

    return newList;
  }



  // Метод для добавления новых ролей или редактирования в Firebase

  static Future<String> addAndEditRoleInApp(String name, {String id = ''}) async {
    try {
      String? roleInAppKey;

      // --- Указываем папку, где будут хранится роль ----

      DatabaseReference genderReference = FirebaseDatabase.instance.ref().child('roleInApp');

      if (id == '') {

        // --- Генерируем уникальный ключ ---
        DatabaseReference newGenderReference = genderReference.push();
        // ---- Получаем уникальный ключ ----
        roleInAppKey = newGenderReference.key; // Получаем уникальный ключ

      }

      // --- Создаем окончательный путь ----
      final DatabaseReference reference =
      FirebaseDatabase.instance.ref().child('roleInApp').child(roleInAppKey ?? id);

      // ---- Публикуем роль -----
      await reference.set({
        'name': name,
        'id': roleInAppKey ?? id
      });

      // Обновляем список наших ролей в локальную переменную
      await getRolesInAppAndSave();

      // --- Возвращаем успех ----
      //TODO - Есть вариант, что тут может роль не опубликоваться. Надо как то подумать, чтобы точно знать что он опубиковался
      return 'success';

    } catch (error) {
      // Видимо здесь проверка - если не удалось опубликовать роль, то возвращаем ошибку
      return 'Error: $error';
    }
  }

  static Future<String> deleteRoleInApp(String roleId) async {
    try {
      DatabaseReference reference = FirebaseDatabase.instance.ref().child('roleInApp').child(roleId);

      // Проверяем, существует ли роль с указанным ID
      DataSnapshot snapshot = await reference.get();
      if (!snapshot.exists) {
        return 'Такая роль не найдена';
      }

      // Удаляем роль
      await reference.remove();

      // Обновляем список наших ролей в локальную переменную
      await getRolesInAppAndSave();

      return 'success';
    } catch (error) {
      return 'Ошибка при удалении роли в приложении: $error';
    }
  }

  // Сортировка списка ролей по имени

  static void sortRoleInAppByName(List<RoleInApp> roleInApp, bool order) {

    if (order) {
      roleInApp.sort((a, b) => a.name.compareTo(b.name));
    } else {
      roleInApp.sort((a, b) => b.name.compareTo(a.name));
    }
  }

  // Метод для получения списка ролей из Firebase

  static Future<List<RoleInApp>> getRolesInApp({bool order = true}) async {

    List<RoleInApp> roles = [];

    // Указываем путь
    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('roleInApp');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    // Итерируем по каждому дочернему элементу
    // Здесь сделано так потому что мы не знаем ключа роли
    // и нам нужен каждая роль, независимо от ключа

    for (var childSnapshot in snapshot.children) {
      // заполняем роль (RoleInApp.fromSnapshot) из снимка данных
      // и добавляем в список ролей
      roles.add(RoleInApp.fromSnapshot(childSnapshot));
    }

    sortRoleInAppByName(roles, order);

    // Возвращаем список
    return roles;
  }

  // Метод для поиска роли по id
  static Future<RoleInApp?> getRoleInAppById(String id) async {

    // Указываем путь
    final DatabaseReference reference =
    FirebaseDatabase.instance.ref().child('roleInApp');

    // Получаем снимок конкретной роли, по id
    DataSnapshot snapshot = await reference.child(id).get();

    if (snapshot.value != null) {

      // Заполняем класс Role данными из БД и возвращаем его ====
      return RoleInApp.fromSnapshot(snapshot);

    } else {
      // Если не нашел, возвращаем null
      //return null;
      return RoleInApp(name: '', id: '');
    }
  }

  /*// Метод для получения кода зарегистрированного пользователя без админских прав в приложении

  static Future<String> getDefaultUserId() async {

    // Указываем путь
    final DatabaseReference reference =
    FirebaseDatabase.instance.ref().child('roleInApp');

    // Получаем снимок конкретной роли, по id
    DataSnapshot snapshot = await reference.child('registeredUser').get();

    if (snapshot.value != null) {

      // Заполняем класс Role данными из БД и возвращаем его ====
      return RoleInApp.fromSnapshot(snapshot).id;

    } else {
      // Если не нашел, возвращаем null
      //return null;
      return '';
    }
  }*/

}