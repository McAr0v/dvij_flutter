import 'package:dvij_flutter/classes/entity_page_type_enum.dart';
import 'package:dvij_flutter/events/events_screens/events_lists_page.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';



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
                  //EventsFeedPage(),
                  //EventsFavPage(),
                  //EventsMyPage()
                  EventsListsPage(pageTypeEnum: EntityPageTypeEnum.feed),
                  EventsListsPage(pageTypeEnum: EntityPageTypeEnum.fav),
                  EventsListsPage(pageTypeEnum: EntityPageTypeEnum.my),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}