import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:dvij_flutter/widgets_global/text_widgets/text_size_enum.dart';
import 'package:flutter/material.dart';

class TextOnBoolResultWidget extends StatelessWidget {
  final bool isTrue;
  final String trueText;
  final String falseText;
  final TextSizeEnum textSizeEnum;
  final Color trueColor;
  final Color falseColor;

  const TextOnBoolResultWidget({
    super.key,
    required this.isTrue,
    required this.trueText,
    required this.falseText,
    this.textSizeEnum = TextSizeEnum.bodyMedium,
    this.trueColor = Colors.green,
    this.falseColor = AppColors.attentionRed
  });

  @override
  Widget build(BuildContext context) {
    TextSizeClass textSizeClass = TextSizeClass(size: textSizeEnum);
    return Text(
      isTrue ? trueText : falseText, // Задайте разный текст в зависимости от булевого значения
      style: textSizeClass.getTextStyleWithColorFromEnum(context, isTrue? trueColor : falseColor),
    );
  }
}