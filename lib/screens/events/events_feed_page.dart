
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';


class EventsFeedPage extends StatelessWidget {

  const EventsFeedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.greyBackground,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Мероприятия лента'),
            ]
        ),
      ),
    );
  }
}