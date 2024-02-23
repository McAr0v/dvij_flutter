import 'dart:ui';

import 'package:flutter/material.dart';

enum TextSizeEnum {
  headlineMedium,
  headlineSmall,
  bodyMedium,
  bodySmall,
  labelMedium,
  labelSmall
}

class TextSizeClass {
  TextSizeEnum size;

  TextSizeClass({this.size = TextSizeEnum.bodyMedium});

  TextStyle getTextStyleFromEnum(BuildContext context){
    switch (size) {
      case TextSizeEnum.bodyMedium: return Theme.of(context).textTheme.bodyMedium!;
      case TextSizeEnum.bodySmall: return Theme.of(context).textTheme.bodySmall!;
      case TextSizeEnum.labelMedium: return Theme.of(context).textTheme.labelMedium!;
      case TextSizeEnum.labelSmall: return Theme.of(context).textTheme.labelSmall!;
      case TextSizeEnum.headlineMedium: return Theme.of(context).textTheme.titleMedium!;
      case TextSizeEnum.headlineSmall: return Theme.of(context).textTheme.titleSmall!;
    }
  }

  TextStyle getTextStyleWithColorFromEnum(BuildContext context, Color color){
    switch (size) {
      case TextSizeEnum.bodyMedium: return Theme.of(context).textTheme.bodyMedium!.copyWith(color: color);
      case TextSizeEnum.bodySmall: return Theme.of(context).textTheme.bodySmall!.copyWith(color: color);
      case TextSizeEnum.labelMedium: return Theme.of(context).textTheme.labelMedium!.copyWith(color: color);
      case TextSizeEnum.labelSmall: return Theme.of(context).textTheme.labelSmall!.copyWith(color: color);
      case TextSizeEnum.headlineMedium: return Theme.of(context).textTheme.titleMedium!.copyWith(color: color);
      case TextSizeEnum.headlineSmall: return Theme.of(context).textTheme.titleSmall!.copyWith(color: color);
    }
  }

}