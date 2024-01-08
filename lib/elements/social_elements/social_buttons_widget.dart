import 'package:dvij_flutter/go_to_url/openUrlPage.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialButtonsWidget extends StatelessWidget {
  final String? instagramUsername;
  final String? telegramUsername;
  final String? whatsappUsername;
  final String? phoneNumber;

  const SocialButtonsWidget({
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
      padding: EdgeInsets.all(8.0), // Отступы
      decoration: BoxDecoration(
        color: AppColors.greyOnBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        //mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (phoneNumber != null && phoneNumber != '')
            GestureDetector(
              onTap: () => openSocialProfile(phoneNumber!, 'phone'),
              child: Card(
                color: AppColors.brandColor,
                margin: EdgeInsets.all(0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const FaIcon(
                        FontAwesomeIcons.phone,
                        size: 20,
                        color: AppColors.greyOnBackground,
                      ),
                      onPressed: () => openSocialProfile(phoneNumber!, 'phone'),
                    ),
                    Text(
                      phoneNumber!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.greyOnBackground),
                    ),
                    SizedBox(width: 15,)
                  ],
                ),
              )
            ),

          //if (phoneNumber != null && phoneNumber != '') const SizedBox(width: 15,),

          if (instagramUsername != null && instagramUsername != '')
            IconButton(
              icon: const FaIcon(
                  FontAwesomeIcons.instagram,
                size: 30,
              ),
              onPressed: () => openSocialProfile(instagramUsername!, 'instagram'),
            ),

          //if (instagramUsername != null && instagramUsername != '') const SizedBox(width: 15,),

          if (telegramUsername != null && telegramUsername != '')
            IconButton(
              icon: const FaIcon(
                  FontAwesomeIcons.telegram,
                size: 30,
              ),
              onPressed: () => openSocialProfile(telegramUsername!, 'telegram'),
            ),

          //if (telegramUsername != null && telegramUsername != '') const SizedBox(width: 15,),

          if (whatsappUsername != null && whatsappUsername != '')
            IconButton(
              icon: const FaIcon(
                  FontAwesomeIcons.whatsapp,
                size: 30,
              ),
              onPressed: () => openSocialProfile(whatsappUsername!, 'whatsapp'),
            ),
        ],
      ),
    );
  }
}