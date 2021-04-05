import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

class DecimalPickerDialog extends StatefulWidget {
  final num initialValue;
  final num min;
  final num max;
  num step = 1;
  num decimals = 1;
  num acceleration = 0.1;
  final EdgeInsets titlePadding;
  final Widget title;
  final Widget confirmWidget;
  final Widget cancelWidget;

  DecimalPickerDialog({
    @required this.initialValue,
    @required this.min,
    @required this.max,
    this.step,
    this.decimals,
    this.acceleration,
    this.title,
    this.titlePadding,
    Widget confirmWidget,
    Widget cancelWidget,
  })  : confirmWidget = confirmWidget ?? new Text('OK'),
        cancelWidget = cancelWidget ?? new Text('CANCEL');

  @override
  State<StatefulWidget> createState() => new _DecimalPickerDialogState(initialValue);
}

class _DecimalPickerDialogState extends State<DecimalPickerDialog> {
  num value;

  _DecimalPickerDialogState(num initialValue) {
    value = initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: widget.title,
      titlePadding: widget.titlePadding,
      content: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 200,
          child: SpinBox(
              min: widget.min,
              max: widget.max,
              value: value == null ? 0 : value,
              decimals: widget.decimals,
              step: widget.step,
              acceleration: widget.acceleration,
              onChanged: (value) {
                this.setState(() {
                  this.value = value;
                });
              }),
        ),
      ]),
      actions: [
        new TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: widget.cancelWidget,
        ),
        new TextButton(
          onPressed: () => Navigator.of(context).pop(value),
          child: widget.confirmWidget,
        ),
      ],
    );
  }
}
