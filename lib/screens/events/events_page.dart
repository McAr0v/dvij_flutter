// events/events_page.dart
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import '../../app_state/appstate.dart';
import 'events_fav_page.dart';
import 'events_feed_page.dart';
import 'events_my_page.dart';


class EventsPage extends StatelessWidget {
  final AppState appState;
  const EventsPage({Key? key, required this.appState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Количество табов
      child: Scaffold(
        backgroundColor: AppColors.greyOnBackground,
        body: Column(
          children: [
            //const SizedBox(height: 24), // Добавьте отступ, если нужно
            const TabBar(
              tabs: [
                Tab(text: 'Лента'),
                Tab(text: 'Избранные'),
                Tab(text: 'Мои'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  EventsFeedPage(appState: appState,),
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