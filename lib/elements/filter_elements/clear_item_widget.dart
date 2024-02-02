import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../themes/app_colors.dart';

class ClearItemWidget extends StatelessWidget {
  final bool showButton;
  final Color buttonColor;
  final Color iconColor;
  final Widget widget;
  final IconData icon;
  final VoidCallback onButtonPressed;

  ClearItemWidget({super.key,
    required this.showButton,
    required this.widget,
    required this.onButtonPressed,
    this.buttonColor = AppColors.attentionRed,
    this.iconColor = AppColors.greyOnBackground,
    this.icon = Icons.close
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: widget
        ),
        if (showButton) Card(
          color: buttonColor,
          child: IconButton(
            onPressed: onButtonPressed,
            icon: Icon(
              icon,
              color: iconColor
            ),
          ),
        )
      ],
    );
  }
}