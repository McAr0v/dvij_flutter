import 'package:flutter/material.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

class SvgIcon extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;
  final Color color;

  const SvgIcon({
    super.key,
    required this.assetPath,
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      color: color,
    );
  }
}