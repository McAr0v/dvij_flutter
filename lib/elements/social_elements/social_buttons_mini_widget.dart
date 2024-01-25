import 'package:dvij_flutter/go_to_url/openUrlPage.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialButtonsMiniWidget extends StatelessWidget {
  final String? instagramUsername;
  final String? telegramUsername;
  final String? whatsappUsername;
  final String? phoneNumber;

  const SocialButtonsMiniWidget({
    Key? key,
    this.instagramUsername,
    this.telegramUsername,
    this.whatsappUsername,
    this.phoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: AppColors.greyOnBackground, // Цвет фона
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8), // Отступы
      decoration: BoxDecoration(
        color: AppColors.greyBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        //mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          //if (phoneNumber != null && phoneNumber != '') const SizedBox(width: 15,),

          if (phoneNumber != null && phoneNumber != '')
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.phone,
                size: 20,
              ),
              onPressed: () => openSocialProfile(phoneNumber!, 'phone'),
            ),

          if (instagramUsername != null && instagramUsername != '')
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.instagram,
                size: 25,
              ),
              onPressed: () => openSocialProfile(instagramUsername!, 'instagram'),
            ),

          //if (instagramUsername != null && instagramUsername != '') const SizedBox(width: 15,),

          if (telegramUsername != null && telegramUsername != '')
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.telegram,
                size: 25,
              ),
              onPressed: () => openSocialProfile(telegramUsername!, 'telegram'),
            ),

          //if (telegramUsername != null && telegramUsername != '') const SizedBox(width: 15,),

          if (whatsappUsername != null && whatsappUsername != '')
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.whatsapp,
                size: 25,
              ),
              onPressed: () => openSocialProfile(whatsappUsername!, 'whatsapp'),
            ),
        ],
      ),
    );
  }
}