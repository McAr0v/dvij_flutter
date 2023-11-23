import 'package:dvij_flutter/elements/logo_view.dart';
import 'package:dvij_flutter/navigation/profile_box_in_drawer.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:dvij_flutter/screens/otherPages/about_app_page.dart';
import 'package:dvij_flutter/screens/otherPages/about_ad_page.dart';
import 'package:dvij_flutter/screens/otherPages/feedback_page.dart';
import 'package:dvij_flutter/screens/otherPages/privacy_policy_page.dart';


// --- КАСТОМНАЯ БОКОВАЯ ШТОРКА -----

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    double drawerWidthPercentage = 0.85; // 80% от ширины экрана

    return Drawer(
      // Помещаем в контейнер, чтобы окрасить в нужный цвет

      width: MediaQuery.of(context).size.width * drawerWidthPercentage,

      child: Container(

        padding: const EdgeInsets.fromLTRB(5.0, 50.0, 5.0, 5.0),
        color: AppColors.greyOnBackground,
        child: ListView(
          // ListView Чтобы все элементы шли друг за другом
          //padding: EdgeInsets.all(5.0),
          padding: const EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 5.0),
          children: [

            // Отдельный виджет логотипа
            const LogoView(),

            // Отдельный виджет отображения профиля в Drawer
            const ProfileBoxInDrawer(),

            // Дополнительные страницы - О приложении, написать разработчику и тд.

            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('О приложении'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutAppPage()),
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
                  MaterialPageRoute(builder: (context) => FeedbackPage()),
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
                  MaterialPageRoute(builder: (context) => AboutAdPage()),
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
                      builder: (context) => PrivacyPolicyPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}