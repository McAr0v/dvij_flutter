import 'package:flutter/material.dart';

SnackBar customSnackBar({
  required String message,
  int showTime = 2,
  required Color backgroundColor,
}) {
  return SnackBar(
    content: Text(message),
    duration: Duration(seconds: showTime),
    backgroundColor: backgroundColor
  );
}