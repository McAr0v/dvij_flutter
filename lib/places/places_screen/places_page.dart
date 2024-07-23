import 'package:dvij_flutter/classes/entity_page_type_enum.dart';
import 'package:dvij_flutter/places/places_screen/places_lists_page.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'places_fav_page.dart';
import 'places_feed_page.dart';
import 'places_my_page.dart';


class PlacesPage extends StatelessWidget {
  const PlacesPage({Key? key}) : super(key: key);

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
                Tab(text: 'Все'),
                Tab(text: 'Избранные'),
                Tab(text: 'Мои'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  PlacesListsPage(pageTypeEnum: EntityPageTypeEnum.feed),
                  PlacesListsPage(pageTypeEnum: EntityPageTypeEnum.fav),
                  PlacesListsPage(pageTypeEnum: EntityPageTypeEnum.my),
                  //PlacesFeedPage(),
                  //PlacesFavPage(),
                  //PlacesMyPage()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}