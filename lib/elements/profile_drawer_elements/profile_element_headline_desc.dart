import 'package:flutter/material.dart';

class ProfileElementHeadlineDesc extends StatelessWidget {
  final double widthPercentage;
  final String headline;
  final String description;
  final Icon icon;

  ProfileElementHeadlineDesc({this.widthPercentage = 0.7, this.headline = '', this.description = '', this.icon = const Icon (Icons.edit)});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * widthPercentage,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(
                      softWrap: true,
                      headline,
                      style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 10.0),

                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(
                      softWrap: true,
                      description,
                      style: const TextStyle(fontSize: 14.0),
                    ),
                  ),

                ],
              ),

              const SizedBox(width: 15.0),
            ],
          ),

          icon,

        ],
      )
    );
  }
}