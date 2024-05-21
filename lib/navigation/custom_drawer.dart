import 'package:dvij_flutter/elements/logo_view.dart';
import 'package:dvij_flutter/navigation/profile_box_in_drawer.dart';
import 'package:dvij_flutter/screens/role_in_app_screens/roles_in_app_list_screen.dart';
import 'package:dvij_flutter/screens/users_list_screens/users_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:dvij_flutter/screens/otherPages/about_app_page.dart';
import 'package:dvij_flutter/screens/otherPages/about_ad_page.dart';
import 'package:dvij_flutter/screens/otherPages/feedback_page.dart';
import 'package:dvij_flutter/screens/otherPages/privacy_policy_page.dart';
import 'package:dvij_flutter/current_user/user_class.dart' as local_user;
import '../cities/cities_screens/cities_list_screen.dart';
import '../events/event_categories_screens/event_categories_list_screen.dart';
import '../places/place_categories_screens/place_categories_list_screen.dart';
import '../promos/promo_categories_screen/promo_categories_list_screen.dart';
import '../screens/genders_screens/genders_list_screen.dart';
import '../test_screen.dart';

// --- КАСТОМНАЯ БОКОВАЯ ШТОРКА -----

class CustomDrawer extends StatelessWidget {
  final local_user.UserCustom userInfo;

  const CustomDrawer({required this.userInfo, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {



    // -- Определяем ширину Drawer в зависимости от ширины всего экрана
    double drawerWidthPercentage = 0.85;

    return Drawer(

      // Помещаем в контейнер, чтобы окрасить в нужный цвет

      // -- Устанавливаем ширину Drawer в зависимости от ширины всего экрана
      width: MediaQuery.of(context).size.width * drawerWidthPercentage,

      child: Container(

        // Внутренние отступы
        padding: const EdgeInsets.fromLTRB(5.0, 50.0, 5.0, 5.0),
        color: AppColors.greyOnBackground,
        child: ListView(
          // ListView Чтобы все элементы шли друг за другом

          padding: const EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 5.0),
          children: [

            // Отдельный виджет логотипа
            const LogoView(),

            // Отдельный виджет отображения профиля в Drawer
            ProfileBoxInDrawer(userInfo: userInfo),

            // Дополнительные страницы - О приложении, написать разработчику и тд.

            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('О приложении'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutAppPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Написать разработчику'),
              leading: const Icon(Icons.feedback),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeedbackPage()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.ad_units),
              title: const Text('Реклама в приложении'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutAdPage()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Политика конфиденциальности'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyPage()),
                );
              },
            ),

            if (local_user.UserCustom.accessLevel >= 50) ListTile(
              title: Text(
                  'Админ панель',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              contentPadding: const EdgeInsets.all(15),
            ),

            if (local_user.UserCustom.accessLevel >= 100) ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Список пользователей'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UsersListScreen()),
                );
              },
            ),

            if (local_user.UserCustom.accessLevel >= 80) ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Список городов'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CitiesListScreen()),
                );
              },
            ),

            if (local_user.UserCustom.accessLevel >= 90) ListTile(
              leading: const Icon(Icons.man),
              title: const Text('Список гендеров'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GendersListScreen()),
                );
              },
            ),

            if (local_user.UserCustom.accessLevel >= 90) ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Список ролей для приложения'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RolesInAppListScreen()),
                );
              },
            ),

            if (local_user.UserCustom.accessLevel >= 80) ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Список категорий мест'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PlaceCategoriesListScreen()),
                );
              },
            ),

            if (local_user.UserCustom.accessLevel >= 80) ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Список категорий мероприятий'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EventCategoriesListScreen()),
                );
              },
            ),

            if (local_user.UserCustom.accessLevel >= 80) ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Список категорий акций'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PromoCategoriesListScreen()),
                );
              },
            ),

            if (local_user.UserCustom.accessLevel >= 80) ListTile(
              leading: const Icon(Icons.category),
              title: const Text('ТЕСТОВАЯ СТРАНИЦА'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VerticalHorizontalScrollScreen()),
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}