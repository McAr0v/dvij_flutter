import 'package:flutter/material.dart';
import '../../dates/date_mixin.dart';
import '../../themes/app_colors.dart';
import '../date_elements/data_picker.dart';

class IrregularTypeDateTimePickerWidget extends StatelessWidget {
  //final String title;
  final String dateLabelText;
  final String startTimeLabelText;
  final String endTimeLabelText;
  final DateTime selectedDate;
  final String startTime;
  final String endTime;
  final VoidCallback onDateActionPressed;
  final VoidCallback onDateActionPressedWithChosenDate;
  final Function(String?) onStartTimeChanged;
  final Function(String?) onEndTimeChanged;
  final VoidCallback onDeletePressed;

  IrregularTypeDateTimePickerWidget({super.key,
    //required this.title,
    required this.dateLabelText,
    required this.startTimeLabelText,
    required this.endTimeLabelText,
    required this.selectedDate,
    required this.startTime,
    required this.endTime,
    required this.onDateActionPressed,
    required this.onDateActionPressedWithChosenDate,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
      child: Column(
        children: [

          if (selectedDate == DateTime(2100))
            DataPickerCustom(
              onActionPressed: onDateActionPressed,
              date: 'Дата не выбрана',
              labelText: dateLabelText,
            )

          else DataPickerCustom(
            onActionPressed: onDateActionPressedWithChosenDate,
            date: DateMixin.getHumanDate('${selectedDate.year}-${selectedDate.month}-${selectedDate.day}', '-'),
            labelText: dateLabelText,
          ),

          const SizedBox(height: 10,),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeDropdown(
                  startTimeLabelText,
                  startTime,
                  onStartTimeChanged,
                  context
              ),

              _buildTimeDropdown(
                  endTimeLabelText,
                  endTime,
                  onEndTimeChanged,
                  context
              ),

              Card(
                color: AppColors.attentionRed,
                child: IconButton(
                  onPressed: onDeletePressed,
                  icon: const Icon(
                    Icons.delete,
                    color: AppColors.greyOnBackground,
                  ),
                ),
              ),

            ],
          ),

        ],
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
              child: Text(time, style: Theme.of(context).textTheme.bodyMedium,),
            );
          }).toList(),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
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