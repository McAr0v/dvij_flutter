import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../cities/city_class.dart';
import '../../places/place_class.dart';
import '../../places/places_elements/place_widget_in_view_screen_in_event_and_promo.dart';
import '../../places/places_screen/place_view_screen.dart';
import '../../themes/app_colors.dart';
import '../text_widgets/headline_and_desc.dart';

class PlaceOrLocationWidget extends StatefulWidget {
  final double horizontalPadding;
  final double verticalPadding;
  final Color backgroundColor;
  final City city;
  final String street;
  final String headline;
  final String desc;
  final String house;
  final Place? place;


  const PlaceOrLocationWidget({super.key,
    this.horizontalPadding = 20,
    this.verticalPadding = 20,
    this.backgroundColor = AppColors.greyOnBackground,
    required this.city,
    required this.desc,
    required this.headline,
    required this.house,
    required this.street,
    this.place
  });

  @override
  PlaceOrLocationWidgetState createState() => PlaceOrLocationWidgetState();
}

class PlaceOrLocationWidgetState extends State<PlaceOrLocationWidget> {
  bool openSchedule = false;

  @override
  Widget build(BuildContext context) {


    return GestureDetector(
      onTap: (){
        setState(() {
          openSchedule = !openSchedule;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: widget.verticalPadding, horizontal: widget.horizontalPadding),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(widget.headline, style: Theme.of(context).textTheme.titleMedium,),
                                      const SizedBox(height: 5,),
                                      Text(widget.desc, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.greyText),),
                                    ],
                                  )
                              ),

                              const SizedBox(width: 10,),

                              IconButton(
                                  onPressed: (){
                                    setState(() {
                                      openSchedule = !openSchedule;
                                    });

                                  },
                                  icon: Icon(openSchedule == false ? FontAwesomeIcons.chevronRight : FontAwesomeIcons.chevronDown, size: 20,)
                              )
                            ],
                          ),

                          if (openSchedule) const SizedBox(height: 15,),

                          if (widget.street != '' && widget.place!.id == '' && openSchedule) HeadlineAndDesc(
                              headline: '${widget.city.name}, ${widget.street} ${widget.house} ',
                              description: 'Место проведения'
                          ),

                          if (widget.place!.id != '' && widget.place != null && openSchedule) PlaceWidgetInViewScreenInEventAndPromoScreen(
                            // TODO Сделать обновление иконки избранного и счетчика при возврате из экрана просмотра заведения
                            place: widget.place!,
                            onTapMethod: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlaceViewScreen(placeId: widget.place!.id),
                                ),
                              );
                            },
                          ),

                        ],
                      )
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}