// events/events_page.dart
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import '../../app_state/appstate.dart';
import 'events_fav_page.dart';
import 'events_feed_page.dart';
import 'events_my_page.dart';


class EventsPage extends StatelessWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3, // Количество табов
      child: Scaffold(
        backgroundColor: AppColors.greyOnBackground,
        body: Column(
          children: [
            //const SizedBox(height: 24), // Добавьте отступ, если нужно
            TabBar(
              tabs: [
                Tab(text: 'Лента'),
                Tab(text: 'Избранные'),
                Tab(text: 'Мои'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  EventsFeedPage(),
                  EventsFavPage(),
                  EventsMyPage()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}