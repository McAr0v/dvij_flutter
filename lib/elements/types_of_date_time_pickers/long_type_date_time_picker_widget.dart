import 'package:flutter/material.dart';
import '../../dates/date_mixin.dart';
import '../date_elements/data_picker.dart';

class LongTypeDateTimePickerWidget extends StatelessWidget {
  //final String title;
  final String startDateLabelText;
  final String endDateLabelText;
  final String startTimeLabelText;
  final String endTimeLabelText;
  final DateTime selectedStartDate;
  final DateTime selectedEndDate;
  final String startTime;
  final String endTime;
  final VoidCallback onStartDateActionPressed;
  final VoidCallback onStartDateActionPressedWithChosenDate;
  final VoidCallback onEndDateActionPressed;
  final VoidCallback onEndDateActionPressedWithChosenDate;
  final Function(String?) onStartTimeChanged;
  final Function(String?) onEndTimeChanged;

  LongTypeDateTimePickerWidget({super.key,
    required this.startDateLabelText,
    required this.endDateLabelText,
    required this.startTimeLabelText,
    required this.endTimeLabelText,
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.startTime,
    required this.endTime,
    required this.onStartDateActionPressed,
    required this.onStartDateActionPressedWithChosenDate,
    required this.onEndDateActionPressed,
    required this.onEndDateActionPressedWithChosenDate,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        if (selectedStartDate == DateTime(2100))
          DataPickerCustom(
            onActionPressed: onStartDateActionPressed,
            date: 'Дата начала не выбрана',
            labelText: startDateLabelText,
          )

        else DataPickerCustom(
            onActionPressed: onStartDateActionPressedWithChosenDate,
            date: DateMixin.getHumanDate('${selectedStartDate.year}-${selectedStartDate.month}-${selectedStartDate.day}', '-'),
            labelText: startDateLabelText
        ),

        const SizedBox(height: 10,),

        if (selectedEndDate == DateTime(2100))
          DataPickerCustom(
            onActionPressed: onEndDateActionPressed,
            date: 'Дата завершения не выбрана',
            labelText: endDateLabelText,
          )

        else DataPickerCustom(
            onActionPressed: onEndDateActionPressedWithChosenDate,
            date: DateMixin.getHumanDate('${selectedEndDate.year}-${selectedEndDate.month}-${selectedEndDate.day}', '-'),
            labelText: endDateLabelText
        ),

        const SizedBox(height: 10,),

        Row(
          children: [
            _buildTimeDropdown(
                startTimeLabelText,
                startTime,
                onStartTimeChanged,
                context
            ),

            const SizedBox(width: 30,),

            _buildTimeDropdown(
                endTimeLabelText,
                endTime,
                onEndTimeChanged,
                context
            ),
          ],
        ),

      ],
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
              child: Text(time, style: Theme.of(context).textTheme.bodyMedium,),
            );
          }).toList(),
        ),
        Text(label, style: Theme.of(context).textTheme.labelMedium,),
      ],
    );
  }

  final List<String> _timeList = [
    "Не выбрано",
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