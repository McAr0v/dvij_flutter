import 'package:flutter/material.dart';

import '../../themes/app_colors.dart';
import '../text_widgets/for_cards_small_widget_with_icon_and_text.dart';
import '../text_widgets/headline_and_desc.dart';
import '../text_widgets/now_is_work_widget.dart';
import '../text_widgets/text_size_enum.dart';
import 'image_with_placeholder.dart';

class ImageForViewScreen extends StatelessWidget {
  final String imagePath;
  final int favCounter;
  final bool inFav;
  final Function() onTap;
  final String categoryName;
  final String headline;
  final String desc;
  final bool openOrToday;
  final String trueText;
  final String falseText;


  const ImageForViewScreen({
    required this.imagePath,
    required this.favCounter,
    required this.inFav,
    required this.onTap,
    required this.categoryName,
    required this.headline,
    required this.desc,
    required this.openOrToday,
    required this.trueText,
    required this.falseText,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        // Картинка

        ImageWithPlaceHolderWidget(imagePath: imagePath),

        // Виджет ИЗБРАННОЕ

        Positioned(
          top: 10.0,
          right: 10.0,
          child: IconAndTextInTransparentSurfaceWidget(
            icon: Icons.bookmark,
            text: '$favCounter',
            iconColor: inFav ? AppColors.brandColor : AppColors.white,
            side: false,
            backgroundColor: AppColors.greyBackground.withOpacity(0.8),
            onPressed: onTap,
          ),
        ),

        // Виджет КАТЕГОРИЯ

        Positioned(
          top: 10.0,
          left: 10.0,
          child: IconAndTextInTransparentSurfaceWidget(
              text: categoryName,
              iconColor: AppColors.white,
              side: true,
              backgroundColor: AppColors.greyBackground.withOpacity(0.8)
          ),
        ),

        Positioned(
          bottom: 20.0,
          left: 20.0,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // НАЗВАНИЕ И АДРЕС

                HeadlineAndDesc(
                  headline: headline,
                  description: desc,
                  textSize: TextSizeEnum.headlineLarge,
                  descSize: TextSizeEnum.bodySmall,
                  descColor: AppColors.white,
                  padding: 5,
                ),

                const SizedBox(height: 5,),

                // ФЛАГ - СЕЙЧАС ОТКРЫТО / ЗАКРЫТО

                TextOnBoolResultWidget(isTrue: openOrToday, trueText: trueText, falseText: falseText),

              ],
            ),
          ),
        ),
      ],
    );
  }

}