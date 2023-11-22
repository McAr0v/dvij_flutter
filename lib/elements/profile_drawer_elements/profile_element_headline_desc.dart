import 'package:flutter/material.dart';

class ProfileElementHeadlineDesc extends StatelessWidget {
  final double widthPercentage;
  final String headline;
  final String description;
  final Icon icon;

  ProfileElementHeadlineDesc({this.widthPercentage = 0.7, this.headline = '', this.description = '', this.icon = const Icon (Icons.edit)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * widthPercentage,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(
                      softWrap: true,
                      headline,
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),

                  SizedBox(height: 10.0),

                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(
                      softWrap: true,
                      description,
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ),

                ],
              ),

              SizedBox(width: 15.0),
            ],
          ),

          icon,

        ],
      )
    );
  }
}