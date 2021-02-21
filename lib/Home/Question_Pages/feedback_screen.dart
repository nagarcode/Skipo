import 'package:flutter/material.dart';
import 'package:skippo/Home/Question_Pages/detailed_feedback_screen.dart';
import 'package:skippo/Home/Question_Pages/question.dart';

enum AnswerType { correct, wrong, notanswered, mandatoryFail }

class FeedbackPage extends StatelessWidget {
  final bool didFailMandatory;
  final bool isTestFeedback;
  final Map<Question, int> wrongAnswers;
  final List<Question> answeredCorrectly;
  final TextStyle textStyle =
      TextStyle(fontFamily: 'amaticaRegular', fontSize: 50);
  FeedbackPage(
      {@required this.isTestFeedback,
      @required this.answeredCorrectly,
      @required this.wrongAnswers,
      @required this.didFailMandatory});

  static create(
      {@required BuildContext context,
      @required bool isTest,
      @required Map<Question, int> wrongAnswers,
      @required List<Question> answeredCorrectly,
      @required bool didFailMandatory}) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FeedbackPage(
                  didFailMandatory: didFailMandatory,
                  isTestFeedback: isTest,
                  wrongAnswers: wrongAnswers,
                  answeredCorrectly: answeredCorrectly,
                )));
  }

  @override
  Widget build(BuildContext context) {
    final correctAnswers = answeredCorrectly.length;
    final wrongAnswersNum = wrongAnswers.length;
    final practicedQuestions = correctAnswers + wrongAnswersNum;
    final showWrong = wrongAnswersNum > 0;
    final showCorrect = correctAnswers > 0;
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
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Spacer(flex: 1),
            Flexible(
              fit: FlexFit.loose,
              flex: 3,
              child: _headline(practicedQuestions),
            ),
            Spacer(flex: 1),
            Expanded(
              flex: 10,
              child: Container(child: _answersColumn(showCorrect, showWrong)),
            ),
            Expanded(
              flex: 1,
              child: Card(
                child: _detailsButton(context),
              ),
            ),
            Flexible(
              fit: FlexFit.loose,
              flex: 2,
              child: returnHomeBtn(context),
            ),
            Flexible(
              flex: 1,
              fit: FlexFit.loose,
              child: _savedText(),
            )
          ],
        ),
      ),
    );
  }

  _savedText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Image.asset(
          'assets/Icons/memory2.png',
          height: 25,
          width: 25,
        ),
        // Spacer(),
        FittedBox(
          fit: BoxFit.contain,
          child: Text(
            'תשובותיך נשמרו במאגר השאלות',
            style: textStyle.copyWith(fontSize: 30),
          ),
        ),
        // Spacer(),
        Image.asset(
          'assets/Icons/memory1.png',
          height: 25,
          width: 25,
        ),
      ],
    );
  }

  _detailsButton(BuildContext context) {
    return FlatButton(
      onPressed: () {
        DetailedFeedbackPage.create(context, wrongAnswers, answeredCorrectly);
      },
      child: Text('פירוט תשובות'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7.0),
        side: BorderSide(color: Colors.black),
      ),
    );
  }

  _answersColumn(bool showCorrect, bool showWrong) {
    final unAnswered = 50 - (answeredCorrectly.length + wrongAnswers.length);
    final showUnAnswered = unAnswered > 0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
          child: showCorrect
              ? _answerLine(AnswerType.correct)
              : Container(width: 0, height: 0),
        ),
        Flexible(
          child: showWrong
              ? _answerLine(AnswerType.wrong)
              : Container(width: 0, height: 0),
        ),
        Flexible(
          child: isTestFeedback && showUnAnswered
              ? _answerLine(AnswerType.notanswered)
              : Container(width: 0, height: 0),
        ),
        Flexible(
          child: didFailMandatory
              ? _answerLine(AnswerType.mandatoryFail)
              : Container(width: 0, height: 0),
        ),
        Spacer(
          flex: 3,
        )
      ],
    );
  }

  _answerLine(AnswerType answerType) {
    final correctAnswers = answeredCorrectly.length;
    final wrongAnswersNum = wrongAnswers.length;
    final notAnswered = 50 - correctAnswers - wrongAnswersNum;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Image.asset(
            answerType == AnswerType.correct
                ? 'assets/Icons/v1.png'
                : answerType == AnswerType.wrong
                    ? 'assets/Icons/x1.jpg'
                    : answerType == AnswerType.notanswered
                        ? 'assets/Icons/questionMark.jpg'
                        : 'assets/Icons/mandatory.png',
            height: 30,
            width: 30,
          ),
        ),
        Expanded(
          child: Center(
            child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                    answerType == AnswerType.correct
                        ? 'תשובות נכונות: $correctAnswers'
                        : answerType == AnswerType.wrong
                            ? 'תשובות שגויות: $wrongAnswersNum'
                            : answerType == AnswerType.notanswered
                                ? 'שאלות שלא נענו: $notAnswered'
                                : 'טעית בשאלת חובה!',
                    style: textStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ))),
          ),
        ),
        Spacer()
      ],
    );
  }

  _headline(int practicedQuestions) {
    return FittedBox(
      fit: BoxFit.contain,
      child: !isTestFeedback
          ? Text(
              practicedQuestions == 1
                  ? 'תרגלת שאלה אחת'
                  : 'תרגלת $practicedQuestions שאלות',
              style: textStyle.copyWith(fontSize: 60),
            )
          : didFailMandatory || answeredCorrectly.length <= 45
              ? Text(
                  'נכשלת במבחן',
                  style: textStyle.copyWith(fontSize: 60, color: Colors.red),
                )
              : Text('עברת את המבחן בהצלחה',
                  style: textStyle.copyWith(fontSize: 60, color: Colors.green)),
    );
  }

  returnHomeBtn(BuildContext context) {
    final handler = () {
      Navigator.of(context).popUntil((route) => route.isFirst);
    };
    return Container(
      margin: EdgeInsets.all(6),
      decoration:
          BoxDecoration(border: Border.all(width: 1), shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(Icons.home),
        onPressed: handler,
        iconSize: 40.0,
        splashColor: Colors.blue,
      ),
    );
  }
}
