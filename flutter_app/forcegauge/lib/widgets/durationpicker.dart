import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class DurationPickerDialog extends StatefulWidget {
  final Duration initialDuration;
  final EdgeInsets titlePadding;
  final Widget title;
  final Widget confirmWidget;
  final Widget cancelWidget;

  DurationPickerDialog({
    @required this.initialDuration,
    this.title,
    this.titlePadding,
    Widget confirmWidget,
    Widget cancelWidget,
  })  : confirmWidget = confirmWidget ?? new Text('OK'),
        cancelWidget = cancelWidget ?? new Text('CANCEL');

  @override
  State<StatefulWidget> createState() => new _DurationPickerDialogState(initialDuration);
}

class _DurationPickerDialogState extends State<DurationPickerDialog> {
  int minutes;
  int seconds;

  _DurationPickerDialogState(Duration initialDuration) {
    minutes = initialDuration.inMinutes;
    seconds = initialDuration.inSeconds % Duration.secondsPerMinute;
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: widget.title,
      titlePadding: widget.titlePadding,
      content: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        NumberPicker(
          //listViewWidth: 65,
          //initialValue: minutes,
          minValue: 0,
          maxValue: 30,
          value: minutes,
          zeroPad: true,
          onChanged: (value) {
            this.setState(() {
              this.minutes = value;
            });
          },
        ),
        Text(
          ':',
          style: TextStyle(fontSize: 30),
        ),
        new NumberPicker(
            //listViewWidth: 65,
            //initialValue: seconds,
            value: seconds,
            minValue: 0,
            maxValue: 59,
            zeroPad: true,
            onChanged: (value) {
              this.setState(() {
                this.seconds = value;
              });
            }),
      ]),
      actions: [
        new TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: widget.cancelWidget,
        ),
        new TextButton(
          onPressed: () => Navigator.of(context).pop(new Duration(minutes: minutes, seconds: seconds)),
          child: widget.confirmWidget,
        ),
      ],
    );
  }
}
