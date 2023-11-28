import 'package:firebase_database/firebase_database.dart';

import '../classes/user_class.dart';

class UserDatabase {

  // --- ИНИЦИАЛИЗИРУЕМ БАЗУ ДАННЫХ -----
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  // --- ФУНКЦИЯ ЗАПИСИ ДАННЫХ ПОЛЬЗОВАТЕЛЯ -----
  Future<String?> writeUserData(User user) async {

    try {
      // Создаем путь для пользователя в базе данных
      String userPath = 'users/${user.uid}/user_info';

      // Записываем данные пользователя в базу данных
      await _databaseReference.child(userPath).set({
        'uid': user.uid,
        'role': user.role,
        'name': user.name,
        'lastname': user.lastname,
        'phone': user.phone,
        'whatsapp': user.whatsapp,
        'telegram': user.telegram,
        'instagram': user.instagram,
        'city': user.city,
        'birth_date': user.birthDate,
        'sex': user.sex,
        'avatar': user.avatar,
      });

      // Если успешно
      return 'success';

    } catch (e) {
      // Если ошибки
      // TODO Сделать обработку ошибок. Наверняка есть какие то, которые можно различать и писать что случилось
      print('Error writing user data: $e');
      return 'Failed to write user data. Error: $e';
    }
  }

  // ---- ФУНКЦИЯ ЧТЕНИЯ ИНФОРМАЦИИ О ПОЛЬЗОВАТЕЛЕ -----

  Future<User?> readUserData(String uid) async {
    try {
      // Путь к данным пользователя
      String userPath = 'users/$uid/user_info';

      // Считываем данные
      DatabaseEvent snapshot = await _databaseReference.child(userPath).once();

      // Получаем значение и заполняем как User
      Map<dynamic, dynamic>? data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        User user = User(
          uid: data['uid'] ?? '',
          role: data['role'] ?? '',
          name: data['name'] ?? '',
          lastname: data['lastname'] ?? '',
          phone: data['phone'] ?? '',
          whatsapp: data['whatsapp'] ?? '',
          telegram: data['telegram'] ?? '',
          instagram: data['instagram'] ?? '',
          city: data['city'] ?? '',
          birthDate: data['birth_date'] ?? '',
          sex: data['sex'] ?? '',
          avatar: data['avatar'] ?? '',
        );

        return user;
      } else {
        return null; // Возвращаем null, если данных нет
      }
    } catch (e) {
      print('Error reading user data: $e');
      return null; // Возвращаем null в случае ошибки
    }
  }
}