import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skippo/Home/Question_Pages/question.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class AccountPage extends StatefulWidget {
  final List<Question> questions;
  final SharedPreferences prefs;
  final wrongAnswers;
  final correctAnswers;
  final didNotAnswer;
  final totalQuestions;

  const AccountPage(
      {@required this.questions,
      @required this.prefs,
      @required this.correctAnswers,
      @required this.didNotAnswer,
      @required this.totalQuestions,
      @required this.wrongAnswers});
  @override
  _AccountPageState createState() => _AccountPageState();

  static didAnswerCorrectly(Question question, SharedPreferences prefs) {
    // if no answer is recorded - returns null;
    final bool answeredCorrectly = prefs.getBool(question.getLocalPath());
    return answeredCorrectly;
  }

  static create({
    @required BuildContext context,
    @required List<Question> questions,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    var wrongAnswers = 0;
    var correctAnswers = 0;
    var didNotAnswer = 0;
    var totalQuestions = questions.length;
    for (var question in questions) {
      final didAnswerCorrectly =
          AccountPage.didAnswerCorrectly(question, prefs);
      if (didAnswerCorrectly == true) correctAnswers++;
      if (didAnswerCorrectly == false) wrongAnswers++;
      if (didAnswerCorrectly == null) didNotAnswer++;
    }
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AccountPage(
                  prefs: prefs,
                  questions: questions,
                  correctAnswers: correctAnswers,
                  didNotAnswer: didNotAnswer,
                  totalQuestions: totalQuestions,
                  wrongAnswers: wrongAnswers,
                )));
  }
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    final correct = ChartAnswer('תשובות נכונות', widget.correctAnswers);
    final wrong = ChartAnswer('תשובות שגויות', widget.wrongAnswers);
    final notAnswered =
        ChartAnswer('שאלות שעליהן לא ענית', widget.didNotAnswer);
    final answered = widget.totalQuestions - widget.didNotAnswer;
    final answeredQuestions = ChartAnswer('שאלות שעליהן כן ענית', answered);
    final correctWrongData = [correct, wrong];
    final correctWrongChart = _getChart(correctWrongData);
    final answeredNotAnsweredData = [answeredQuestions, notAnswered];
    final answeredNotAnsweredChart = _getChart(answeredNotAnsweredData);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'סקיפו',
          style: TextStyle(fontSize: 25, fontFamily: 'amaticaRegular'),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Flexible(
              child: Container(child: correctWrongChart),
            ),
            Divider(),
            Expanded(
              child: Card(
                child: answeredNotAnsweredChart,
              ),
            )
          ],
        ),
      ),
    );
  }

  _getChart(List<ChartAnswer> data) {
    return charts.PieChart(
      [
        charts.Series<ChartAnswer, String>(
            id: 'Answers',
            domainFn: (ChartAnswer answer, _) => answer.answerType,
            measureFn: (ChartAnswer answer, _) => answer.amount,
            data: data)
      ],
      animate: true,
      animationDuration: Duration(seconds: 1),
      behaviors: [charts.DatumLegend()],
    );
  }
}

class ChartAnswer {
  final String answerType;
  final int amount;

  ChartAnswer(this.answerType, this.amount);
}
