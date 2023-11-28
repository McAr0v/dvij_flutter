import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileElementLoggedUser extends StatelessWidget {
  final String imageUrl; // Передаваемая переменная
  final String name; // Передаваемая переменная
  final String email; // Передаваемая переменная
  final double widthPercentage;

  const ProfileElementLoggedUser({super.key, this.imageUrl = '', this.name = '', this.email = '', this.widthPercentage = 0.75});

  // --- ВИДЖЕТ ОТОБРАЖЕНИЯ ПОЛЬЗОВАТЕЛЯ В DRAWER -----
  // --- СОСТОЯНИЕ ЗАЛОГИНЕВШЕГОСЯ ПОЛЬЗОВАТЕЛЯ -----

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Ширина блока в зависимости от ширины Drawer
      width: MediaQuery.of(context).size.width * widthPercentage,

      child:Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Аватарка
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.background,
                radius: 30,
                backgroundImage: NetworkImage(imageUrl),
              ),

              const SizedBox(width: 15.0),

              // Имя и Email
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 14.0),
                  ),
                ],
              ),

              const SizedBox(width: 15.0),
            ],
          ),

          // Иконка
          const Icon(Icons.chevron_right),
        ],
      ) ,
    );
  }
}