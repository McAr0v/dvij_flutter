import 'package:flutter/material.dart';
import 'package:dvij_flutter/themes/app_colors.dart';

class PlacesFeedPage extends StatelessWidget {
  const PlacesFeedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.greyBackground,
      child: const Center(
          child: Text('Заведения лента')
      ),
    );


  }
}