import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../themes/app_colors.dart';
import '../text_widgets/for_cards_small_widget_with_icon_and_text.dart';
import '../text_widgets/headline_and_desc.dart';
import '../text_widgets/now_is_work_widget.dart';
import '../text_widgets/text_size_enum.dart';
import 'image_with_placeholder.dart';

class ImageInViewScreenWidget extends StatefulWidget {
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

  const ImageInViewScreenWidget({
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
    Key? key
  }) : super(key: key);

  @override
  State<ImageInViewScreenWidget> createState() => _ImageInViewScreenWidgetState();
}

class _ImageInViewScreenWidgetState extends State<ImageInViewScreenWidget> {

  bool _isLoading = false;

  void _handlePressed() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onTap();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        // Картинка

        ImageWithPlaceHolderWidget(imagePath: widget.imagePath),

        // Виджет ИЗБРАННОЕ

        if (_isLoading) Positioned(
          top: 10.0,
          right: 10.0,
          child: IconAndTextInTransparentSurfaceWidget(
            icon: FontAwesomeIcons.circle,
            text: 'в процессе...',
            iconColor: AppColors.brandColor,
            side: false,
            backgroundColor: AppColors.greyBackground.withOpacity(0.8),
            onPressed: (){},
          ),
        ),

        if (!_isLoading) Positioned(
          top: 10.0,
          right: 10.0,
          child: IconAndTextInTransparentSurfaceWidget(
            icon: Icons.bookmark,
            text: '${widget.favCounter}',
            iconColor: widget.inFav ? AppColors.brandColor : AppColors.white,
            side: false,
            backgroundColor: AppColors.greyBackground.withOpacity(0.8),
            onPressed: _handlePressed,
          ),
        ),

        // Виджет КАТЕГОРИЯ

        Positioned(
          top: 10.0,
          left: 10.0,
          child: IconAndTextInTransparentSurfaceWidget(
              text: widget.categoryName,
              iconColor: AppColors.white,
              side: true,
              backgroundColor: AppColors.greyBackground.withOpacity(0.8)
          ),
        ),

        Positioned(
          bottom: 20.0,
          left: 20.0,
          child: SizedBox(
            width: MediaQuery.of(context).size.width*0.95,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ФЛАГ - СЕЙЧАС ОТКРЫТО / ЗАКРЫТО

                  TextOnBoolResultWidget(isTrue: widget.openOrToday, trueText: widget.trueText, falseText: widget.falseText),

                  const SizedBox(height: 5,),

                  // НАЗВАНИЕ И АДРЕС

                  HeadlineAndDesc(
                    headline: widget.headline,
                    description: widget.desc,
                    textSize: TextSizeEnum.headlineLarge,
                    descSize: TextSizeEnum.bodySmall,
                    descColor: AppColors.white,
                    padding: 5,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
