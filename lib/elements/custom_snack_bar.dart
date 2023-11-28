import 'package:flutter/material.dart';

// --- ВИДЖЕТ ВСПЛЫВАЮЩЕГО ОПОВЕЩЕНИЯ ----
SnackBar customSnackBar({
  // Сообщение
  required String message,
  // Время показа в секундах
  int showTime = 2,
  // Цвет фона
  required Color backgroundColor,
}) {
  return SnackBar(
    content: Text(message),
    duration: Duration(seconds: showTime),
    backgroundColor: backgroundColor
  );
}