import 'package:flutter/material.dart';
import 'package:skippo/Home/Question_Pages/question.dart';
import 'package:skippo/Home/Question_Pages/wrong_answer_screen.dart';
import 'package:skippo/Services/api_path.dart';

class DetailedFeedbackPage extends StatelessWidget {
  final Map<Question, int> wrongAnswers;
  final List<Question> answeredCorrectly;

  DetailedFeedbackPage(
      {@required this.wrongAnswers, @required this.answeredCorrectly});

  static create(BuildContext context, Map<Question, int> wrongAnswers,
      List<Question> answeredCorrectly) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => DetailedFeedbackPage(
                  wrongAnswers: wrongAnswers,
                  answeredCorrectly: answeredCorrectly,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'סקיפו',
            style: TextStyle(
              fontFamily: 'amaticaRegular',
              fontSize: 25,
            ),
          ),
          bottom: TabBar(tabs: [
            Tab(
              text: 'תשובות שגויות',
            ),
            Tab(
              text: 'תשובות נכונות',
            ),
          ]),
        ),
        body: TabBarView(children: [
          _answersColumn(context, false),
          _answersColumn(context, true)
        ]),
      ),
    );
  }

  _answersColumn(BuildContext context, bool correctOrWrong) {
    final answersTodisplay =
        correctOrWrong ? answeredCorrectly : wrongAnswers.keys.toList();
    return ListView.separated(
        itemBuilder: (context, index) =>
            _answerListTile(context, correctOrWrong, index, answersTodisplay),
        separatorBuilder: (context, index) => Divider(),
        itemCount: answersTodisplay.length);
  }

  _answerListTile(BuildContext context, bool correctOrWrong, int index,
      List<Question> answers) {
    final answer = answers[index];
    return ListTile(
      title: Text(answers[index].question),
      trailing: Image.asset(
        correctOrWrong ? APIPath.correctAnswer() : APIPath.wronAnswer(),
        height: 40,
        width: 40,
      ),
      onTap: () {
        WrongAnswerPage.create(context, answer, wrongAnswers[answer]);
      },
    );
  }
}
