import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../themes/app_colors.dart';

class AddManagersWidget extends StatelessWidget {
  final double horizontalPadding;
  final String headline;
  final String desc;
  final double verticalPadding;
  final Color backgroundColor;
  final VoidCallback onTapMethod;


  const AddManagersWidget({super.key,
    this.horizontalPadding = 20,
    this.verticalPadding = 20,
    required this.headline,
    required this.desc,
    this.backgroundColor = AppColors.greyOnBackground,
    required this.onTapMethod
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
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
                                Text(headline, style: Theme.of(context).textTheme.titleMedium,),
                                const SizedBox(height: 5,),
                                Text(desc, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.greyText),),
                              ],
                            )
                        ),

                        const SizedBox(width: 10,),

                        IconButton(
                            onPressed: (){onTapMethod();},
                            icon: const Icon(FontAwesomeIcons.chevronRight, size: 20,)
                        )

                      ],
                    ),
                  ],
                )
            )
          ],
        ),
      ),
    );
  }
}