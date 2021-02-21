import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:skippo/Home/Question_Pages/question.dart';
import 'package:skippo/Home/Question_Pages/test_screen.dart';
import 'package:skippo/Home/home_card.dart';

class TestLandingPage extends StatelessWidget {
  final CardType type;
  final List<Question> questions;

  const TestLandingPage({@required this.type, @required this.questions});

  static create(
      BuildContext context, CardType type, List<Question> questions) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TestLandingPage(
                  type: type,
                  questions: questions,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'סקיפו',
          style: TextStyle(
            fontFamily: 'amaticaRegular',
            fontSize: 25,
          ),
        ),
      ),
      body: Center(
          child: Column(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              child: _textColumn(),
            ),
          ),
          Flexible(flex: 1, child: _startButton(context))
        ],
      )),
    );
  }

  _startButton(BuildContext context) {
    return FlatButton(
      onPressed: () {
        TestPage.create(context, type, questions);
      },
      child: Text('התחל מבחן'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.black),
      ),
    );
  }

  _textColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AutoSizeText('הינך עומד/ת להתחיל מבחן ב'),
            AutoSizeText(
              _testTypeString() + '.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AutoSizeText('משך הבחינה הוא '),
            AutoSizeText(
              '90 דקות.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AutoSizeText('כמות הטעויות המותרת היא '),
            AutoSizeText('5 ', style: TextStyle(fontWeight: FontWeight.bold)),
            AutoSizeText('טעויות.'),
          ],
        ),
        AutoSizeText(
          'טעות בשאלה הגורמת להתנגשות או סיכון חיי אדם היא פסילה אוטומטית.',
          textAlign: TextAlign.center,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AutoSizeText('שים לב! שאלות שלא יענו יחשבו '),
            AutoSizeText(
              'כטעות.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  String _testTypeString() {
    var toReturn;
    switch (type) {
      case CardType.boatA:
        toReturn = 'סירה עוצמה א׳';
        break;
      case CardType.boatB:
        toReturn = 'סירה עוצמה ב׳';
        break;
      case CardType.jetski:
        toReturn = 'אופנוע ים';
        break;
      case CardType.machinary:
        toReturn = 'מכונאות';
        break;
      case CardType.navigationB:
        toReturn = 'ניווט ב׳';
        break;
      case CardType.yamaotC:
        toReturn = 'ימאות ג׳';
        break;
      default:
        toReturn = '';
    }
    return toReturn;
  }
}
