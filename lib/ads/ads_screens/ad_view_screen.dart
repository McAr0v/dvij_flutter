import 'package:dvij_flutter/ads/ad_user_class.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/url_methods/url_path_enum.dart';
import 'package:dvij_flutter/widgets_global/text_widgets/for_cards_small_widget_with_icon_and_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../themes/app_colors.dart';
import '../../url_methods/open_url_class.dart';
import '../../widgets_global/images/image_with_placeholder.dart';

class AdViewScreen extends StatefulWidget {

  final AdUser ad;

  const AdViewScreen({required this.ad, Key? key}) : super(key: key);

  @override
  State<AdViewScreen> createState() => _AdViewScreenState();
}

class _AdViewScreenState extends State<AdViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ad.headline),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.chevronLeft, size: 18,),
          onPressed: () {
              Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [



          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                ImageWithPlaceHolderWidget(
                    imagePath: widget.ad.imageUrl,
                    height: 300,
                ),

                Padding(
                    padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(widget.ad.headline, style: Theme.of(context).textTheme.titleLarge,),



                      const SizedBox(height: 20,),

                      Text(widget.ad.desc, style: Theme.of(context).textTheme.bodyMedium,),

                      const SizedBox(height: 20,),

                      CustomButton(
                          buttonText: 'Подробнее',
                          onTapMethod: (){
                            OpenUrlClass.openUrl(widget.ad.url, UrlPathEnum.web );
                          }
                      ),
                    ],
                  ),
                )


              ],
            ),
          ),
          const Positioned(
            top: 20.0,
            left: 20.0,
            child: IconAndTextInTransparentSurfaceWidget(
                text: "Реклама",
                iconColor: AppColors.greyOnBackground,
                textColor: AppColors.greyOnBackground,
                side: true,
                backgroundColor: AppColors.brandColor
            ),
          ),
        ],
      ),
    );
  }
}
