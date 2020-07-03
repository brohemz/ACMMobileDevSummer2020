import 'package:flutter/material.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;

class PickerWidget extends StatefulWidget {
  final rangeLow, rangeHigh;
  const PickerWidget(this.rangeLow, this.rangeHigh);
  @override
  _PickerWidgetState createState() => _PickerWidgetState(rangeLow, rangeHigh);
}


class _PickerWidgetState extends State<PickerWidget> {
  final rangeLow, rangeHigh;
  _PickerWidgetState(this.rangeLow, this.rangeHigh);
  
  List<DateTime> selectedDates = [DateTime.now(), DateTime.now().add(Duration(days: 7))];

  // TODO: Issues with initialFirstDate and initialLastDate
  // Source: https://pub.dev/packages/date_range_picker
  Future<Null> _selectDate(BuildContext context) async {
    final List<DateTime> picked = await DateRangePicker.showDatePicker(
      context: context,
      initialFirstDate: selectedDates.first,
      initialLastDate: selectedDates.first.add(Duration(days: 7)),
      firstDate: DateTime(2020, 06),
      lastDate: DateTime(2020, 07));

    if(picked != null && picked.length >= 2){ 
      setState(() => selectedDates = picked);
    }

  }

  @override
  Widget build(BuildContext context){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("${selectedDates.first.toLocal()}".split(' ')[0] + " | " + "${selectedDates.last.toLocal()}".split(' ')[0]),
        MaterialButton(
          onPressed: () => _selectDate(context),
          child: Text("Show Picker"),
        ),
      ]
    );
  }


}