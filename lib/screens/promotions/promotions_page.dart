import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'promotions_fav_page.dart';
import 'promotions_feed_page.dart';
import 'promotions_my_page.dart';


class PromotionsPage extends StatelessWidget {
  const PromotionsPage({Key? key}) : super(key: key);

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
                Tab(text: 'Все'),
                Tab(text: 'Избранные'),
                Tab(text: 'Мои'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  PromotionsFeedPage(),
                  PromotionsFavPage(),
                  PromotionsMyPage()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}