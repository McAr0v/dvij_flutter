
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../methods/date_functions.dart';
import '../../themes/app_colors.dart';
import '../data_picker.dart';

class RegularTypeDateTimePickerWidget extends StatelessWidget {
  //final String title;
  final String startTimeLabelText;
  final String endTimeLabelText;
  final String mondayStartTime;
  final String mondayFinishTime;
  final String tuesdayStartTime;
  final String tuesdayFinishTime;
  final String wednesdayStartTime;
  final String wednesdayFinishTime;
  final String thursdayStartTime;
  final String thursdayFinishTime;
  final String fridayStartTime;
  final String fridayFinishTime;
  final String saturdayStartTime;
  final String saturdayFinishTime;
  final String sundayStartTime;
  final String sundayFinishTime;
  final Function(String?) onMondayStartTimeChanged;
  final Function(String?) onMondayEndTimeChanged;
  final Function(String?) onTuesdayStartTimeChanged;
  final Function(String?) onTuesdayEndTimeChanged;
  final Function(String?) onWednesdayStartTimeChanged;
  final Function(String?) onWednesdayEndTimeChanged;
  final Function(String?) onThursdayStartTimeChanged;
  final Function(String?) onThursdayEndTimeChanged;
  final Function(String?) onFridayStartTimeChanged;
  final Function(String?) onFridayEndTimeChanged;
  final Function(String?) onSaturdayStartTimeChanged;
  final Function(String?) onSaturdayEndTimeChanged;
  final Function(String?) onSundayStartTimeChanged;
  final Function(String?) onSundayEndTimeChanged;

  RegularTypeDateTimePickerWidget({
    //required this.title,
    required this.startTimeLabelText,
    required this.endTimeLabelText,
    required this.mondayStartTime,
    required this.mondayFinishTime,
    required this.tuesdayStartTime,
    required this.tuesdayFinishTime,
    required this.wednesdayStartTime,
    required this.wednesdayFinishTime,
    required this.thursdayStartTime,
    required this.thursdayFinishTime,
    required this.fridayStartTime,
    required this.fridayFinishTime,
    required this.saturdayStartTime,
    required this.saturdayFinishTime,
    required this.sundayStartTime,
    required this.sundayFinishTime,
    required this.onMondayStartTimeChanged,
    required this.onMondayEndTimeChanged,
    required this.onTuesdayStartTimeChanged,
    required this.onTuesdayEndTimeChanged,
    required this.onWednesdayStartTimeChanged,
    required this.onWednesdayEndTimeChanged,
    required this.onThursdayStartTimeChanged,
    required this.onThursdayEndTimeChanged,
    required this.onFridayStartTimeChanged,
    required this.onFridayEndTimeChanged,
    required this.onSaturdayStartTimeChanged,
    required this.onSaturdayEndTimeChanged,
    required this.onSundayStartTimeChanged,
    required this.onSundayEndTimeChanged,

  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.greyOnBackground,
      surfaceTintColor: AppColors.greyOnBackground.withOpacity(0),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          children: [

            /*Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.1),
            ),

            SizedBox(height: 20,),*/

            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('ПН:', style: Theme.of(context).textTheme.bodyMedium,),
                SizedBox(width: 20.0),
                _buildTimeDropdown(
                    startTimeLabelText,
                    mondayStartTime,
                    onMondayStartTimeChanged,
                    context
                ),

                const SizedBox(width: 30,),

                _buildTimeDropdown(
                    endTimeLabelText,
                    mondayFinishTime,
                    onMondayEndTimeChanged,
                    context
                ),
              ],
            ),

            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('ВТ:', style: Theme.of(context).textTheme.bodyMedium,),
                SizedBox(width: 20.0),
                _buildTimeDropdown(
                    startTimeLabelText,
                    tuesdayStartTime,
                    onTuesdayStartTimeChanged,
                    context
                ),

                const SizedBox(width: 30,),

                _buildTimeDropdown(
                    endTimeLabelText,
                    tuesdayFinishTime,
                    onTuesdayEndTimeChanged,
                    context
                ),
              ],
            ),

            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('СР:', style: Theme.of(context).textTheme.bodyMedium,),
                SizedBox(width: 20.0),
                _buildTimeDropdown(
                    startTimeLabelText,
                    wednesdayStartTime,
                    onWednesdayStartTimeChanged,
                    context
                ),

                const SizedBox(width: 30,),

                _buildTimeDropdown(
                    endTimeLabelText,
                    wednesdayFinishTime,
                    onWednesdayEndTimeChanged,
                    context
                ),
              ],
            ),

            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('ЧТ:', style: Theme.of(context).textTheme.bodyMedium,),
                SizedBox(width: 20.0),
                _buildTimeDropdown(
                    startTimeLabelText,
                    thursdayStartTime,
                    onThursdayStartTimeChanged,
                    context
                ),

                const SizedBox(width: 30,),

                _buildTimeDropdown(
                    endTimeLabelText,
                    thursdayFinishTime,
                    onThursdayEndTimeChanged,
                    context
                ),
              ],
            ),

            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('ПТ:', style: Theme.of(context).textTheme.bodyMedium,),
                SizedBox(width: 20.0),
                _buildTimeDropdown(
                    startTimeLabelText,
                    fridayStartTime,
                    onFridayStartTimeChanged,
                    context
                ),

                const SizedBox(width: 30,),

                _buildTimeDropdown(
                    endTimeLabelText,
                    fridayFinishTime,
                    onFridayEndTimeChanged,
                    context
                ),
              ],
            ),

            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('ПН:', style: Theme.of(context).textTheme.bodyMedium,),
                SizedBox(width: 20.0),
                _buildTimeDropdown(
                    startTimeLabelText,
                    saturdayStartTime,
                    onSaturdayStartTimeChanged,
                    context
                ),

                const SizedBox(width: 30,),

                _buildTimeDropdown(
                    endTimeLabelText,
                    saturdayFinishTime,
                    onSaturdayEndTimeChanged,
                    context
                ),
              ],
            ),

            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('ВС:', style: Theme.of(context).textTheme.bodyMedium,),
                SizedBox(width: 20.0),
                _buildTimeDropdown(
                    startTimeLabelText,
                    sundayStartTime,
                    onSundayStartTimeChanged,
                    context
                ),

                const SizedBox(width: 30,),

                _buildTimeDropdown(
                    endTimeLabelText,
                    sundayFinishTime,
                    onSundayEndTimeChanged,
                    context
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildTimeDropdown(
      String label, String selectedTime, void Function(String?) onChanged, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<String>(
          value: selectedTime,
          onChanged: onChanged,
          items: _timeList.map((String time) {
            return DropdownMenuItem<String>(
              value: time,
              child: Text(time),
            );
          }).toList(),
        ),
        Text(label, style: Theme.of(context).textTheme.labelMedium,),
      ],
    );
  }

  final List<String> _timeList = [
    "00:00",
    "00:30",
    "01:00",
    "01:30",
    "02:00",
    "02:30",
    "03:00",
    "03:30",
    "04:00",
    "04:30",
    "05:00",
    "05:30",
    "06:00",
    "06:30",
    "07:00",
    "07:30",
    "08:00",
    "08:30",
    "09:00",
    "09:30",
    "10:00",
    "10:30",
    "11:00",
    "11:30",
    "12:00",
    "12:30",
    "13:00",
    "13:30",
    "14:00",
    "14:30",
    "15:00",
    "15:30",
    "16:00",
    "16:30",
    "17:00",
    "17:30",
    "18:00",
    "18:30",
    "19:00",
    "19:30",
    "20:00",
    "20:30",
    "21:00",
    "21:30",
    "22:00",
    "22:30",
    "23:00",
    "23:30",
    // Добавьте необходимые значения времени
  ];

}