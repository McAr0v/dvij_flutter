import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';

class TextOnBoolResultWidget extends StatelessWidget {
  final bool isTrue;
  final String trueText;
  final String falseText;

  const TextOnBoolResultWidget({super.key, required this.isTrue, required this.trueText, required this.falseText});

  @override
  Widget build(BuildContext context) {
    return Text(
      isTrue ? trueText : falseText, // Задайте разный текст в зависимости от булевого значения
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isTrue? Colors.green : AppColors.attentionRed),
    );
  }
}