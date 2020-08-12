
import 'package:flutter/material.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;

class PickerWidget extends StatefulWidget {
  final callback;
  final List<DateTime> selectedDates;
  const PickerWidget({this.callback, this.selectedDates});

  @override
  _PickerWidgetState createState() => _PickerWidgetState();
}


class _PickerWidgetState extends State<PickerWidget> {
  _PickerWidgetState();

  List<DateTime> selectedDates;

  bool showGivenTimes = true;
  
  initState(){
    super.initState();
    if(widget.selectedDates == null){
      setState((){
        selectedDates = [DateTime.now(), DateTime.now().add(Duration(days: 7))];
      });
    }
  }

  



  // TODO: Issues with intialFirstDate and LastDate
  // TODO: Doesn't display picked state on subsequent clicks
  // Source: https://pub.dev/packages/date_range_picker
  Future<Null> _selectDate(BuildContext context) async {
    final List<DateTime> picked = await DateRangePicker.showDatePicker(
      context: context,
      initialFirstDate: selectedDates.first,
      initialLastDate: selectedDates.first.add(Duration(days: 7)),
      firstDate: DateTime(2020, 07),
      lastDate: DateTime(2020, 09));

    if(picked != null && picked.length >= 2){ 
      setState((){
        selectedDates = picked;
        widget.callback(selectedDates.first.toLocal(), selectedDates.last.toLocal());
        showGivenTimes = false;
      });
    }

  }

  @override
  Widget build(BuildContext context){
    final switchDates = widget.selectedDates != null && showGivenTimes;

    print(widget.selectedDates);
    print(selectedDates);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("${switchDates ? widget.selectedDates.first.toLocal() :selectedDates.first.toLocal()}".split(' ')[0] + " | " + "${switchDates ? widget.selectedDates.last.toLocal(): selectedDates.last.toLocal()}".split(' ')[0]),
        MaterialButton(
          onPressed: () => _selectDate(context),
          child: Text("Show Picker"),
        ),
      ]
    );
  }


}