import 'package:dvij_flutter/ads/ad_user_class.dart';
import 'package:flutter/material.dart';

import '../../themes/app_colors.dart';
import '../../widgets_global/text_widgets/for_cards_small_widget_with_icon_and_text.dart';

class CardForAd extends StatefulWidget {

  final AdUser ad;
  final Function() onTap;

  const CardForAd({required this.ad, required this.onTap, Key? key}) : super(key: key);

  @override
  State<CardForAd> createState() => _CardForAdState();
}

class _CardForAdState extends State<CardForAd> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5, bottom: 10, top: 10),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Card(
          margin: const EdgeInsets.only(left: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // настройте необходимый радиус скругления углов
          ),
          child: Container(
            height: 250,
            width: 330,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), // настройте радиус скругления углов для контейнера
              image: DecorationImage(
                image: NetworkImage(widget.ad.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // Полупрозрачный фон
                if (widget.ad.id.isNotEmpty) Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4), // Начальный цвет (черный с прозрачностью)
                        Colors.black.withOpacity(0.9), // Начальный цвет (черный с прозрачностью)
                      ],
                    ), // Здесь можно настроить уровень прозрачности и цвет фона
                    borderRadius: BorderRadius.circular(15), // настройте радиус скругления углов для фона
                  ),
                ),

                if (widget.ad.id.isNotEmpty) const Positioned(
                  top: 10.0,
                  left: 10.0,
                  child: IconAndTextInTransparentSurfaceWidget(
                      text: "Реклама",
                      iconColor: AppColors.greyOnBackground,
                      textColor: AppColors.greyOnBackground,
                      side: true,
                      backgroundColor: AppColors.brandColor
                  ),
                ),
                // Дочерний элемент
                if (widget.ad.id.isNotEmpty) Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text.rich(
                        TextSpan(
                          text: widget.ad.headline,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        maxLines: 2, // Установите желаемое количество строк
                        overflow: TextOverflow.ellipsis, // Определяет, что делать с текстом, который не помещается в виджет
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
