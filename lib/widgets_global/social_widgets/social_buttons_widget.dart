import 'package:dvij_flutter/widgets_global/text_widgets/icon_and_text_widget.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:dvij_flutter/widgets_global/text_widgets/text_size_enum.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../url_methods/open_url_class.dart';
import '../../url_methods/url_path_enum.dart';

class SocialButtonsWidget extends StatelessWidget {
  final String? instagramUsername;
  final String? telegramUsername;
  final String? whatsappUsername;
  final String? phoneNumber;

  const SocialButtonsWidget({
    this.instagramUsername,
    this.telegramUsername,
    this.whatsappUsername,
    this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), // Отступы
      decoration: BoxDecoration(
        color: AppColors.greyOnBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (phoneNumber != null && phoneNumber != '')
            GestureDetector(
                onTap: () => OpenUrlClass.openUrl(phoneNumber!, UrlPathEnum.phone),
                child: Card(
                  color: AppColors.brandColor,
                  margin: const EdgeInsets.all(0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    child: IconAndTextWidget(
                      icon: FontAwesomeIcons.phone,
                      text: phoneNumber!,
                      textColor: AppColors.greyOnBackground,
                      iconColor: AppColors.greyOnBackground,
                      padding: 15,
                      textSize: TextSizeEnum.bodyMedium,
                    ),
                  ),
                )
            ),

          if (instagramUsername != null && instagramUsername != '')
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.instagram,
                size: 30,
              ),
              onPressed: () => OpenUrlClass.openUrl(instagramUsername!, UrlPathEnum.instagram),
            ),

          if (telegramUsername != null && telegramUsername != '')
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.telegram,
                size: 30,
              ),
              onPressed: () => OpenUrlClass.openUrl(telegramUsername!, UrlPathEnum.telegram),
            ),

          if (whatsappUsername != null && whatsappUsername != '')
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.whatsapp,
                size: 30,
              ),
              onPressed: () => OpenUrlClass.openUrl(whatsappUsername!, UrlPathEnum.whatsapp),
            ),
        ],
      ),
    );
  }
}