import 'package:flutter/cupertino.dart';

// Класс AppState, который использует ChangeNotifier для уведомления слушателей об изменениях состояния
class AppState with ChangeNotifier {

  // Приватное поле для хранения идентификатора пользователя
  String? _uid;

  // Геттер для получения значения идентификатора пользователя
  String? get uid => _uid;

  // Метод для установки значения идентификатора пользователя
  void setUid(String? uid) {

    // Установка значения приватной переменной
    _uid = uid;

    // Уведомление всех слушателей об изменении состояния
    notifyListeners();

  }
}

