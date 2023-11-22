import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileElementLoggedUser extends StatelessWidget {
  final String imageUrl; // Передаваемая переменная
  final String name; // Передаваемая переменная
  final String email; // Передаваемая переменная
  final double widthPercentage;

  ProfileElementLoggedUser({this.imageUrl = '', this.name = '', this.email = '', this.widthPercentage = 0.75});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * widthPercentage,
      child:Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(imageUrl),
              ),

              SizedBox(width: 15.0),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    email,
                    style: TextStyle(fontSize: 14.0),
                  ),
                ],
              ),

              SizedBox(width: 15.0),
            ],
          ),

          Icon(Icons.edit),

        ],
      ) ,

    );
  }
}