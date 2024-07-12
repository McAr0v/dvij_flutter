import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

class CustomOnlyTextButton extends StatelessWidget {
  final String buttonText;
  final Function()? onTap;
  final Color textColor;
  final bool smallOrBig;

  const CustomOnlyTextButton({
    Key? key,
    required this.buttonText,
    this.onTap,
    this.textColor = AppColors.brandColor,
    this.smallOrBig = true
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          buttonText,
          style: smallOrBig ? Theme.of(context).textTheme.bodySmall?.copyWith(color: textColor) : Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
        ),
      ),
    );
  }
}