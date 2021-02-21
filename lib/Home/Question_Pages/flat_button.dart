import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class QuestionFlatButton extends StatelessWidget {
  final String child;
  final VoidCallback onPressed;
  final Color backgroundColor;

  QuestionFlatButton(
      {@required this.child,
      @required this.onPressed,
      @required this.backgroundColor});
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: backgroundColor,
      padding: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: BorderSide(color: Colors.black)),
      onPressed: onPressed,
      child: AutoSizeText(
        child,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
