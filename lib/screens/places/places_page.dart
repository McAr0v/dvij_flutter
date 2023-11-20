import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'places_fav_page.dart';
import 'places_feed_page.dart';
import 'places_my_page.dart';


class PlacesPage extends StatelessWidget {
  const PlacesPage({Key? key}) : super(key: key);

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
                Tab(text: 'Все'),
                Tab(text: 'Избранные'),
                Tab(text: 'Мои'),
              ],
            ),
            Expanded(
              child: const TabBarView(
                children: [
                  PlacesFeedPage(),
                  PlacesFavPage(),
                  PlacesMyPage()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}