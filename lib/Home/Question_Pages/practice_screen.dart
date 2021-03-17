import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skippo/Home/Question_Pages/feedback_screen.dart';
import 'package:skippo/Home/Question_Pages/flat_button.dart';
import 'package:skippo/Home/Question_Pages/question.dart';
import 'package:skippo/Home/home_card.dart';
import 'package:skippo/Services/database.dart';

class PracticePage extends StatefulWidget {
  final List<Question> questions;
  final CardType type;
  final TextStyle textStyle = TextStyle(fontSize: 18);

  final List<Question> answeredCorrectly = [];
  final Map<Question, int> wrongAnsweres = Map<Question, int>();
  final List<Color> answerColors = [
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
  ];

  PracticePage({@required this.questions, @required this.type}) {
    questions.shuffle();
  }

  static create(
      BuildContext context, CardType type, List<Question> questions) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) =>
                PracticePage(questions: questions, type: type)));
  }

  @override
  _PracticePageState createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  int index;
  bool isLoading;
  @override
  void initState() {
    isLoading = false;
    index = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: TextButton(
        style: TextButton.styleFrom(
          primary: Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide(color: Colors.black)),
        ),
        onPressed: _navigateToFeedback,
        child: Text(
          'סיום',
          style: TextStyle(fontSize: 20),
        ),
      ),
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

  _applyAnswer(int answerIndex) {
    if (widget.questions[index].correctAnswerIndex == answerIndex)
      _applyCorrectAnswer();
    else
      _applyWrongAnswer(answerIndex);
  }

  _applyWrongAnswer(int answerIndex) async {
    final database = Provider.of<Database>(context, listen: false);
    final currentQuestion = widget.questions[index];
    database.saveAnswer(currentQuestion, false);
    widget.wrongAnsweres[currentQuestion] = answerIndex;
    setState(() {
      isLoading = true;
      widget.answerColors[answerIndex - 1] = Colors.red;
      widget.answerColors[currentQuestion.correctAnswerIndex - 1] =
          Colors.green;
    });
    await Future.delayed(const Duration(milliseconds: 950), () {});
    setState(() {
      widget.answerColors[answerIndex - 1] = Colors.white;
      widget.answerColors[currentQuestion.correctAnswerIndex - 1] =
          Colors.white;
      isLoading = false;
    });

    _nextQuestion();
  }

  _applyCorrectAnswer() async {
    final database = Provider.of<Database>(context, listen: false);
    final currentQuestion = widget.questions[index];
    database.saveAnswer(currentQuestion, true);
    widget.answeredCorrectly.add(widget.questions[index]);
    setState(() {
      isLoading = true;
      widget.answerColors[currentQuestion.correctAnswerIndex - 1] =
          Colors.green;
    });
    await Future.delayed(const Duration(milliseconds: 500), () {});
    setState(() {
      widget.answerColors[currentQuestion.correctAnswerIndex - 1] =
          Colors.white;
      isLoading = false;
    });
    _nextQuestion();
  }

  _nextQuestion() {
    if (index < widget.questions.length - 1)
      setState(() {
        index++;
      });
    else
      _navigateToFeedback();
  }

  _questionCard() {
    return Card(
      elevation: 0,
      child: Center(
        child: AutoSizeText(
          widget.questions[index].question,
          textAlign: TextAlign.center,
          style: widget.textStyle,
        ),
      ),
    );
  }

  _answersCard() {
    final currentIndex = index;
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
                    child: widget.questions[currentIndex].possibleAnswers[0],
                    onPressed: () {
                      // ignore: unnecessary_statements
                      isLoading ? null : _applyAnswer(1);
                    },
                    backgroundColor: widget.answerColors[0],
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
                    child: widget.questions[currentIndex].possibleAnswers[1],
                    onPressed: () {
                      // ignore: unnecessary_statements
                      isLoading ? null : _applyAnswer(2);
                    },
                    backgroundColor: widget.answerColors[1],
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
                    child: widget.questions[currentIndex].possibleAnswers[2],
                    onPressed: () {
                      // ignore: unnecessary_statements
                      isLoading ? null : _applyAnswer(3);
                    },
                    backgroundColor: widget.answerColors[2],
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
                    child: widget.questions[currentIndex].possibleAnswers[3],
                    onPressed: () {
                      // ignore: unnecessary_statements
                      isLoading ? null : _applyAnswer(4);
                    },
                    backgroundColor: widget.answerColors[3],
                  ),
                ),
              ),
            ),
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
          child: widget.questions[index].image,
        ),
      );
    } on PlatformException {
      print('caught exception');
      toReturn = Card();
    }
    return toReturn;
  }

  _navigateToFeedback() {
    FeedbackPage.create(
        didFailMandatory: false,
        answeredCorrectly: widget.answeredCorrectly,
        context: context,
        isTest: false,
        wrongAnswers: widget.wrongAnsweres);
  }
}
