import 'package:flutter/material.dart';

class CheckboxWithText extends StatelessWidget {
  final bool value;
  final double verticalPadding;
  final String label;
  final String description;
  final Function(bool?) onChanged;

  const CheckboxWithText({super.key,
    required this.value,
    this.verticalPadding = 0,
    required this.label,
    required this.description,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.start,
                  softWrap: true,
                ),
                if (description != '') Text(
                  description,
                  style: Theme.of(context).textTheme.labelMedium,
                  textAlign: TextAlign.start,
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}