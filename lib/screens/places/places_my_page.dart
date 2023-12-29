import 'package:flutter/material.dart';

import '../../classes/place_class.dart';
import '../../elements/custom_button.dart';
import '../../themes/app_colors.dart';
import 'create_or_edit_place_screen.dart';

class PlacesMyPage extends StatelessWidget {
  const PlacesMyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Place placeEmpty = Place.empty();

    return Container(
      color: AppColors.greyBackground,
      child: Center(
        child: Column(
          children: [
            Text('Заведения лента'),
            CustomButton(
              buttonText: 'Создать место',
              onTapMethod: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateOrEditPlaceScreen(placeInfo: placeEmpty)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
