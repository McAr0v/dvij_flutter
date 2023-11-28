import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';

// --- КЛАСС ДЛЯ ЗАГРУЗКИ ИКОНОК SVG ----

class SvgIcon extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;
  final Color color;

  const SvgIcon({
    super.key,
    required this.assetPath,
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      color: color,
    );
  }
}