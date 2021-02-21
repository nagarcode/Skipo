import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skippo/Home/Question_Pages/flat_button.dart';
import 'package:skippo/Home/Question_Pages/question.dart';

class WrongAnswerPage extends StatelessWidget {
  final Question question;
  final int wrongIndex;
  final TextStyle textStyle = TextStyle(fontSize: 18);

  WrongAnswerPage({this.question, this.wrongIndex});

  static create(BuildContext context, Question question, int wrongIndex) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => WrongAnswerPage(
                  question: question,
                  wrongIndex: wrongIndex,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(flex: 3, fit: FlexFit.loose, child: _questionCard()),
            Expanded(flex: 7, child: _answersCard()),
            Expanded(flex: 4, child: _imageCard()),
            Spacer(flex: 2)
          ],
        ),
      ),
    );
  }

  _imageCard() {
    var toReturn;
    try {
      toReturn = Card(
        elevation: 0,
        child: Center(
          child: question.image,
        ),
      );
    } on PlatformException {
      print('caught exception');
      toReturn = Card();
    }
    return toReturn;
  }

  _questionCard() {
    return Card(
      elevation: 0,
      child: Center(
        child: AutoSizeText(
          question.question,
          textAlign: TextAlign.center,
          style: textStyle,
        ),
      ),
    );
  }

  _answersCard() {
    final correctIndex = question.correctAnswerIndex;
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  child: QuestionFlatButton(
                    child: question.possibleAnswers[0],
                    onPressed: () {},
                    backgroundColor: wrongIndex == 1
                        ? Colors.red
                        : correctIndex == 1
                            ? Colors.green
                            : Colors.white,
                  ),
                ),
              ),
            ),
            // Spacer(),
            Flexible(
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  child: QuestionFlatButton(
                    child: question.possibleAnswers[1],
                    onPressed: () {},
                    backgroundColor: wrongIndex == 2
                        ? Colors.red
                        : correctIndex == 2
                            ? Colors.green
                            : Colors.white,
                  ),
                ),
              ),
            ),
            // Spacer(),
            Flexible(
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  child: QuestionFlatButton(
                    child: question.possibleAnswers[2],
                    onPressed: () {},
                    backgroundColor: wrongIndex == 3
                        ? Colors.red
                        : correctIndex == 3
                            ? Colors.green
                            : Colors.white,
                  ),
                ),
              ),
            ),
            // Spacer(),
            Flexible(
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  child: QuestionFlatButton(
                    child: question.possibleAnswers[3],
                    onPressed: () {},
                    backgroundColor: wrongIndex == 4
                        ? Colors.red
                        : correctIndex == 4
                            ? Colors.green
                            : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
