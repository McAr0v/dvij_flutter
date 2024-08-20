import 'package:dvij_flutter/classes/entity_page_type_enum.dart';
import 'package:dvij_flutter/promos/promotions/promos_lists_page.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';

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
                  PromosListsPage(pageTypeEnum: EntityPageTypeEnum.feed),
                  PromosListsPage(pageTypeEnum: EntityPageTypeEnum.fav),
                  PromosListsPage(pageTypeEnum: EntityPageTypeEnum.my),
                  //PromotionsFeedPage(),
                  //PromotionsFavPage(),
                  //PromotionsMyPage()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}