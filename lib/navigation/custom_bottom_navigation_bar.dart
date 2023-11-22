import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../elements/icons_elements/svg_icon.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final TabController tabController;
  final void Function(int) onTabTapped;

  CustomBottomNavigationBar({
    required this.tabController,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: tabController.index,
      onTap: onTabTapped,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Профиль',
          backgroundColor: AppColors.greyOnBackground,
        ),
        BottomNavigationBarItem(
          icon: SvgIcon(
            assetPath: 'assets/icon_celebration.svg',
            width: 24.0,
            height: 24.0,
            color: tabController.index == 1
                ? AppColors.brandColor
                : AppColors.greyText,
          ),
          label: 'Мероприятия',
          backgroundColor: AppColors.greyOnBackground,
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.location_on),
          label: 'Места',
          backgroundColor: AppColors.greyOnBackground,
        ),
        BottomNavigationBarItem(
          icon: SvgIcon(
            assetPath: 'assets/fire_solid.svg',
            width: 24.0,
            height: 24.0,
            color: tabController.index == 3
                ? AppColors.brandColor
                : AppColors.greyText,
          ),
          label: 'Акции',
          backgroundColor: AppColors.greyOnBackground,
        ),
      ],
    );
  }
}

