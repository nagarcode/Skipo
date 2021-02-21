import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skippo/Home/Question_Pages/question.dart';
import 'package:skippo/Services/api_path.dart';

class ArchivePage extends StatelessWidget {
  final List<Question> questions;
  final SharedPreferences prefs;

  const ArchivePage({@required this.questions, @required this.prefs});

  static create(BuildContext context, List<Question> questions) async {
    final prefs = await SharedPreferences.getInstance();
    await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => ArchivePage(
                  questions: questions,
                  prefs: prefs,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'סקיפו',
          style: TextStyle(fontSize: 25, fontFamily: 'amaticaRegular'),
        ),
      ),
      body: ListView.separated(
        itemBuilder: (_, index) => ListTile(
          title: Text(questions[index].question),
          trailing: _vOrXImage(questions[index]),
        ),
        separatorBuilder: (context, index) => Divider(),
        itemCount: questions.length,
      ),
    );
  }

  _vOrXImage(Question question) {
    final bool answeredCorrectly = prefs.getBool(question.getLocalPath());
    return Image.asset(
      answeredCorrectly == null
          ? APIPath.questionMark()
          : answeredCorrectly
              ? APIPath.correctAnswer()
              : APIPath.wronAnswer(),
      height: 25,
      width: 25,
    );
  }
}
