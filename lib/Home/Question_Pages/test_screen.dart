import 'package:auto_size_text/auto_size_text.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skippo/Home/Question_Pages/feedback_screen.dart';
import 'package:skippo/Home/Question_Pages/flat_button.dart';
import 'package:skippo/Home/Question_Pages/question.dart';
import 'package:skippo/Home/home_card.dart';
import 'package:skippo/Services/database.dart';
import 'package:skippo/common_widgets/platform_alert_dialog.dart';

class TestPage extends StatefulWidget {
  List<Question> questions;
  final CardType type;
  final TextStyle textStyle = TextStyle(fontSize: 18);

  final List<Question> answeredCorrectly = [];
  final Map<Question, int> wrongAnsweres = Map<Question, int>();
  bool didFailMandatory = false;
  List<Question> mandatoryQuestions;

  TestPage({@required this.type, @required this.questions}) {
    if (_hasMandatory(type)) {
      List<Question> mandatory = _getMandatoryQuestions(type, questions);
      // print('mandatory: ' + mandatory.length.toString());
      for (var question in mandatory) {
        questions.remove(question);
      }
      questions.shuffle();
      questions = questions.sublist(0, 45);
      mandatory.shuffle();
      mandatory = mandatory.sublist(0, 5);
      questions.addAll(mandatory);
      questions.shuffle();
      mandatoryQuestions = mandatory;
      // print('questions: ' + questions.length.toString());
    } else {
      questions.shuffle();
      questions = questions.sublist(0, 50);
      mandatoryQuestions = [];
    }
  }

  static create(
      BuildContext context, CardType type, List<Question> questions) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => TestPage(
                  type: type,
                  questions: questions,
                )));
  }

  @override
  _TestPageState createState() => _TestPageState();
}

bool _hasMandatory(CardType type) {
  if (type == CardType.boatA ||
      type == CardType.boatB ||
      type == CardType.yamaotC ||
      type == CardType.jetski)
    return true;
  else
    return false;
}

List<Question> _getMandatoryQuestions(CardType type, List<Question> questions) {
  final indexes = getMandatoryIndexes(type);
  final List<Question> mandatoryQuestions = [];
  for (var index in indexes) {
    mandatoryQuestions.add(questions[index -
        1]); // decrementing indexes from question index to index in list.
  }
  return mandatoryQuestions;
}

List<int> getMandatoryIndexes(CardType type) {
  final List<int> indexes = [];
  switch (type) {
    case CardType.boatA:
      for (int i = 72; i < 81; i++) if (i != 77 && i != 78) indexes.add(i);
      for (int i = 158; i <= 172; i++) indexes.add(i);
      for (int i = 260; i <= 270; i++) if (i != 265 && i != 266) indexes.add(i);
      return indexes;
      break;
    case CardType.boatB:
      for (int i = 150; i <= 154; i++) indexes.add(i);
      for (int i = 41; i <= 44; i++) indexes.add(i);
      return indexes;
      break;
    case CardType.yamaotC:
      for (int i = 207; i <= 227; i++) indexes.add(i);
      for (int i = 318; i <= 336; i++) indexes.add(i);
      return indexes;
      break;
    case CardType.jetski:
      for (int i = 1; i <= 25; i++) indexes.add(i);
      return indexes;
      break;
    default:
      return indexes;
  }
}

class _TestPageState extends State<TestPage> {
  int index;
  get testLength => 50;
  initState() {
    super.initState();
    index = 0;
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
          ],
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _timer(),
          Text(testLength.toString() + ' / ' + (index + 1).toString(),
              style: TextStyle(fontSize: 20)),
          _endButton(),
        ],
      ),
    );
  }

  _timer() {
    return CircularCountDownTimer(
      width: 100,
      height: 100,
      duration: 5400,
      fillColor: Colors.grey[800],
      color: Colors.white,
      isReverse: true,
    );
  }

  _endButton() {
    final answered =
        widget.answeredCorrectly.length + widget.wrongAnsweres.length;
    final unAnswered = testLength - answered;
    return TextButton(
      style: TextButton.styleFrom(
        primary: Colors.black,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(color: Colors.black)),
      ),
      // color: Colors.white,
      onPressed: () async {
        final didRequestEnd = await PlatformAlertDialog(
          content: unAnswered == 0
              ? 'האם אתה בטוח שברצונך לסיים את המבחן?'
              : 'טרם ענית על $unAnswered שאלות. האם אתה בטוח שברצונך להגיש את המבחן?',
          defaultActionText: 'הגש',
          title: 'הגש מבחן',
          cancelActionText: 'ביטול',
        ).show(context);
        if (didRequestEnd) _navigateToFeedback();
        // FeedbackPage.create(
        //   didFailMandatory: widget.didFailMandatory,
        //   context: context,
        //   isTest: true,
        //   wrongAnswers: widget.wrongAnsweres,
        //   answeredCorrectly: widget.answeredCorrectly,
        // );
      },
      child: Text(
        'הגש מבחן',
        style: TextStyle(fontSize: 22),
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
                      _applyAnswer(1);
                    },
                    backgroundColor: Colors.white,
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
                      _applyAnswer(2);
                    },
                    backgroundColor: Colors.white,
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
                      _applyAnswer(3);
                    },
                    backgroundColor: Colors.white,
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
                      _applyAnswer(4);
                    },
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _applyAnswer(int answerIndex) {
    if (widget.questions[index].correctAnswerIndex == answerIndex)
      _applyCorrectAnswer();
    else
      _applyWrondAnswer(answerIndex);
  }

  _applyWrondAnswer(int answerIndex) async {
    final database = Provider.of<Database>(context, listen: false);
    final currentQuestion = widget.questions[index];
    database.saveAnswer(currentQuestion, false);
    widget.wrongAnsweres[currentQuestion] = answerIndex;
    if (widget.mandatoryQuestions.contains(currentQuestion))
      widget.didFailMandatory = true;

    _nextQuestion();
  }

  _applyCorrectAnswer() async {
    final currentQuestion = widget.questions[index];
    final database = Provider.of<Database>(context, listen: false);
    database.saveAnswer(currentQuestion, true);
    widget.answeredCorrectly.add(currentQuestion);
    _nextQuestion();
  }

  _nextQuestion() {
    if (index < testLength - 1)
      setState(() {
        index++;
      });
    else
      _navigateToFeedback();
  }

  _navigateToFeedback() {
    final database = Provider.of<Database>(context, listen: false);
    database.incrementTestsCounter();
    FeedbackPage.create(
        didFailMandatory: widget.didFailMandatory,
        answeredCorrectly: widget.answeredCorrectly,
        context: context,
        isTest: true,
        wrongAnswers: widget.wrongAnsweres);
  }
}
