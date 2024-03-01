import 'package:dvij_flutter/classes/priceTypeOptions.dart';
import 'package:dvij_flutter/classes/user_class.dart';
import 'package:dvij_flutter/widgets_global/social_widgets/social_buttons_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../elements/user_element_widget.dart';
import '../../themes/app_colors.dart';
import '../text_widgets/headline_and_desc.dart';

class CreatorWidget extends StatefulWidget {
  final double horizontalPadding;
  final double verticalPadding;
  final Color backgroundColor;
  final String headline;
  final String desc;
  final UserCustom user;


  const CreatorWidget({super.key,
    this.horizontalPadding = 20,
    this.verticalPadding = 20,
    this.backgroundColor = AppColors.greyOnBackground,
    required this.headline,
    required this.desc,
    required this.user,
  });

  @override
  CreatorWidgetState createState() => CreatorWidgetState();
}

class CreatorWidgetState extends State<CreatorWidget> {
  bool openSchedule = true;

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
                                      Text(widget.headline, style: Theme.of(context).textTheme.titleMedium,),
                                      const SizedBox(height: 5,),
                                      Text(widget.desc, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.greyText),),
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

                          if (openSchedule && widget.user.uid != '') const SizedBox(height: 16.0),

                          if (widget.user.uid != '' && openSchedule) UserElementWidget(user: widget.user),

                        ],


                      )
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}