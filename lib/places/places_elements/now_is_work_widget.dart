import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';

class NowIsWorkWidget extends StatelessWidget {
  final bool isTrue;

  const NowIsWorkWidget({super.key, required this.isTrue});

  @override
  Widget build(BuildContext context) {
    return Text(
      isTrue ? 'Сейчас открыто' : 'Сейчас закрыто', // Задайте разный текст в зависимости от булевого значения
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isTrue? Colors.green : AppColors.attentionRed),
    );
  }
}