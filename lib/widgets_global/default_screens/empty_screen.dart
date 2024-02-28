import 'package:flutter/material.dart';

class EmptyScreenWidget extends StatelessWidget {
  final String messageText;

  const EmptyScreenWidget({
    this.messageText = 'Пусто',
    super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(messageText, style: Theme.of(context).textTheme.bodyMedium,),
    );
  }

}