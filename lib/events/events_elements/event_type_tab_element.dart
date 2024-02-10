import 'package:flutter/material.dart';

import '../../themes/app_colors.dart';

class EventTypeTabElement extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool active;

  EventTypeTabElement({required this.onTap, required this.text, required this.active});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
        child: GestureDetector(
          child: Text(
              text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: active ? AppColors.greyOnBackground : AppColors.white),
          ),
          onTap: onTap,
        ),
      ),
      color: active ? AppColors.brandColor : AppColors.greyOnBackground,
      margin: EdgeInsets.symmetric(vertical: 10),
    );
  }
}