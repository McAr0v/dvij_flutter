import 'package:flutter/material.dart';

class CheckboxWithText extends StatelessWidget {
  final bool value;
  final String label;
  final String description;
  final Function(bool?) onChanged;

  const CheckboxWithText({super.key,
    required this.value,
    required this.label,
    required this.description,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.start,
            ),
            Text(
              description,
              style: Theme.of(context).textTheme.labelMedium,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ],
    );
  }
}