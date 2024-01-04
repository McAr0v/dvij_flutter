import 'package:flutter/material.dart';

import '../../themes/app_colors.dart';

class CustomOnlyTextButton extends StatelessWidget {
  final String buttonText;
  final Function()? onTap;
  final Color textColor;

  const CustomOnlyTextButton({
    Key? key,
    required this.buttonText,
    this.onTap,
    this.textColor = AppColors.brandColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          buttonText,
          style: TextStyle(
            color: textColor,
              fontSize: 16,
              fontFamily: 'SfProDisplay',
              fontWeight: FontWeight.normal,
              height: 1.3
          ),
        ),
      ),
    );
  }
}