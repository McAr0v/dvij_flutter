import 'package:flutter/material.dart';

import '../navigation/custom_bottom_navigation_bar.dart';
import '../themes/app_colors.dart';
import 'icons_elements/svg_icon.dart';

class LogoView extends StatelessWidget {
  final double width;
  final double height;

  LogoView({this.width = 50.0, this.height = 50.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 20.0, 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgIcon(
            assetPath: 'assets/logo.svg',
            width: width,
            height: height,
            color: AppColors.brandColor,
          ),
        ],
      ),
    );
  }
}