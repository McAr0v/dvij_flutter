import 'package:flutter/material.dart';

import 'custom_snack_bar.dart';

// ---- Функция отображения всплывающих сообщений -----

void showSnackBar(BuildContext context, String message, Color color, int showTime) {
  final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}