import 'package:flutter/material.dart';

import '../../themes/app_colors.dart';

class TodayWidget extends StatelessWidget {
  final bool isTrue;

  const TodayWidget({super.key, required this.isTrue});

  @override
  Widget build(BuildContext context) {
    return Text(
      isTrue ? 'Сегодня' : 'Не сегодня', // Задайте разный текст в зависимости от булевого значения
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isTrue? Colors.green : AppColors.attentionRed),
    );
  }
}