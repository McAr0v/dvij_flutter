import 'package:dvij_flutter/classes/priceTypeOptions.dart';
import 'package:dvij_flutter/widgets_global/social_widgets/social_buttons_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../themes/app_colors.dart';
import '../text_widgets/headline_and_desc.dart';

class CallbackWidget extends StatefulWidget {
  final double horizontalPadding;
  final double verticalPadding;
  final Color backgroundColor;
  final PriceTypeOption? priceType;
  final String? price;
  final String? phone;
  final String? telegram;
  final String? instagram;
  final String? whatsapp;


  const CallbackWidget({super.key,
    this.horizontalPadding = 20,
    this.verticalPadding = 20,
    this.backgroundColor = AppColors.greyOnBackground,
    this.priceType,
    this.price,
    this.phone,
    this.telegram,
    this.instagram,
    this.whatsapp,
  });

  @override
  CallbackWidgetState createState() => CallbackWidgetState();
}

class CallbackWidgetState extends State<CallbackWidget> {
  bool openSchedule = false;

  String switchHeadline(PriceTypeOption? priceType){
    switch (priceType) {
      case PriceTypeOption.free:
        return 'Подтвердить участие';
      case (PriceTypeOption.fixed || PriceTypeOption.range) :
        return 'Заказать билеты';
      case null:
        return 'Контакты';
    }
  }

  String switchDesc(PriceTypeOption? priceType){
    switch (priceType) {
      case PriceTypeOption.free:
        return 'Забронируйте участие, связавшись с организатором';
      case (PriceTypeOption.fixed || PriceTypeOption.range) :
        return 'Купите билеты у организаторов, связавшись с ними по контактам ниже';
      case null:
        return 'Узнайте все подробности, связавшись с администраторами';
    }
  }

  @override
  Widget build(BuildContext context) {


    return GestureDetector(
      onTap: (){
        setState(() {
          openSchedule = !openSchedule;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: widget.verticalPadding, horizontal: widget.horizontalPadding),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(switchHeadline(widget.priceType), style: Theme.of(context).textTheme.titleMedium,),
                                      const SizedBox(height: 5,),
                                      Text(switchDesc(widget.priceType), style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.greyText),),
                                      if (widget.price != null) const SizedBox(height: 15.0),
                                      if (widget.price != null) HeadlineAndDesc(headline: widget.price! != '' ? widget.price! : 'Вход бесплатный', description: 'Стоимость билетов'),
                                    ],
                                  )
                              ),

                              const SizedBox(width: 10,),

                              IconButton(
                                  onPressed: (){
                                    setState(() {
                                      openSchedule = !openSchedule;
                                    });

                                  },
                                  icon: Icon(openSchedule == false ? FontAwesomeIcons.chevronRight : FontAwesomeIcons.chevronDown, size: 20,)
                              )
                            ],
                          ),
                        ],
                      )
                  )
                ],
              ),
            ),
            if (openSchedule) SocialButtonsWidget(
              telegramUsername: widget.telegram,
              instagramUsername: widget.instagram,
              whatsappUsername: widget.whatsapp,
              phoneNumber: widget.phone,
              horizontalPadding: 18,
              verticalPadding: 0,
            ),
            if (openSchedule) const SizedBox(height: 18,)
          ],
        ),
      ),
    );
  }
}