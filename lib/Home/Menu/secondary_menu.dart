import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skippo/Home/Menu/archive_screen.dart';
import 'package:skippo/Home/Question_Pages/practice_screen.dart';
import 'package:skippo/Home/Question_Pages/question.dart';
import 'package:skippo/Home/Question_Pages/test_landing_screen.dart';
import 'package:skippo/Home/account_screen.dart';
import 'package:skippo/Home/home_card.dart';
import 'package:skippo/Home/home_page_stateful.dart';
import 'package:skippo/IAP/updated_market_screen.dart';

import 'package:skippo/Services/database.dart';
import 'package:skippo/common_widgets/platform_alert_dialog.dart';

enum PageType { practice, test, questionArchive, accountPage }

class SecondaryMenu extends StatefulWidget {
  final bool didPay;
  final CardType type;
  final TextStyle textStyle = TextStyle(
      fontFamily: 'amaticaRegular', color: Colors.white, fontSize: 50);
  final isObligatory;

  static create(BuildContext context, CardType type, bool didPay,
      bool isObligatory) async {
    final Database database = Provider.of<Database>(context, listen: false);
    final ok = await database.checkTrialAndShowDialogue(context, didPay);
    if (ok)
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SecondaryMenu(
                    type: type,
                    didPay: didPay,
                    isObligatory: isObligatory,
                  )));
  }

  SecondaryMenu(
      {@required this.type,
      @required this.didPay,
      @required this.isObligatory});
  @override
  _SecondaryMenuState createState() => _SecondaryMenuState();
}

class _SecondaryMenuState extends State<SecondaryMenu> {
  int testCounter;
  int questionCounter;
  bool isLoading;
  @override
  void initState() {
    super.initState();
    final obligatory = widget.isObligatory;

    if (!widget.didPay) {
      final dialog = PlatformAlertDialog(
        title: obligatory ? 'סיימת את מכסת הנסיון' : 'זוהי גרסת נסיון מוגבלת',
        defaultActionText: obligatory ? 'חזור למסך הבית' : 'עדיין לא',
        content:
            'זוהי גרסא חינמית לזמן מוגבל. כדי להנות משימוש מלא עליך לרכוש את האפליקציה',
        cancelActionText: 'רכוש עכשיו',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final didRequestBuy = !await dialog.show(context);
        if (didRequestBuy)
          _buyFullVersion();
        else if (obligatory)
          Navigator.of(context).popUntil((route) => route.isFirst);
      });
    }
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/menuBackground.jpeg'),
            fit: BoxFit.fitHeight),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'סקיפו',
            style: TextStyle(fontSize: 25, fontFamily: 'amaticaRegular'),
          ),
        ),
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _placeHolder(),
                  InkWell(
                    child: Text('תרגול', style: widget.textStyle),
                    onTap: isLoading
                        ? null
                        : () => _loadQuestionsAndGo(PageType.practice),
                  ),
                  _secondaryText('תרגל שאלות בסדר אקראי וללא הגבלת זמן'),
                ],
              ),
              Row(
                children: [
                  _placeHolder(),
                  InkWell(
                    child: Text('מבחן', style: widget.textStyle),
                    onTap: isLoading
                        ? null
                        : () => _loadQuestionsAndGo(PageType.test),
                  ),
                  _secondaryText('אותה מתכונת כמו מבחן תאוריה אמיתי'),
                ],
              ),
              Row(
                children: [
                  _placeHolder(),
                  InkWell(
                    child: Text('מאגר השאלות', style: widget.textStyle),
                    onTap: isLoading
                        ? null
                        : () => _loadQuestionsAndGo(PageType.questionArchive),
                  ),
                  _secondaryText('רשימת שאלות מלאה'),
                ],
              ),
              Row(
                children: [
                  _placeHolder(),
                  InkWell(
                    child: Text('פירוש סימנים', style: widget.textStyle),
                    onTap: isLoading ? null : _signsPressed,
                  ),
                  _secondaryText('דגלים, אורות, סימנים, אותות'),
                ],
              ),
              Row(
                children: [
                  _placeHolder(),
                  InkWell(
                    child: Text('איזור אישי', style: widget.textStyle),
                    onTap: isLoading
                        ? null
                        : () => _loadQuestionsAndGo(PageType.accountPage),
                  ),
                  _secondaryText('סטטיסטיקת שאלות'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _secondaryText(String txt) => Expanded(
        child: Container(
          child: AutoSizeText(
            txt,
            style: TextStyle(color: Colors.white30, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ),
      );

  _placeHolder() => Expanded(
        child: Container(
          child: AutoSizeText(
            '',
            textAlign: TextAlign.center,
          ),
        ),
      );

  _signsPressed() {
    final database = Provider.of<Database>(context, listen: false);
    final cards = [
      HomeCard(type: CardType.daySignals, imageFilename: 'daySignals'),
      HomeCard(type: CardType.flagSignals, imageFilename: 'flagSignals'),
      HomeCard(type: CardType.lightSignals, imageFilename: 'lightSignals'),
      HomeCard(type: CardType.soundSignals, imageFilename: 'soundSignals'),
      HomeCard(type: CardType.sosSignals, imageFilename: 'sosSignals'),
    ];
    HomePageStateful.create(context, cards, widget.didPay, database);
  }

  _loadQuestionsAndGo(PageType pageType) async {
    setState(() {
      isLoading = true;
    });
    final database = Provider.of<Database>(context, listen: false);
    final questionsAnswers = await _loadQuestionsAndAnswers(database);
    final correctAnswersIndexes = await _loadCorrectAnswersIndexes(database);
    final List<Question> questions = [];
    var answerIndex = 0, questionIndex = 1;
    for (int i = 0; i < questionsAnswers.length; i += 5) {
      final List<String> possibleAnswers = [];
      final image = await database.getQuestionImage(widget.type, questionIndex);
      for (int j = i + 1; j < i + 5; j++)
        possibleAnswers.add(questionsAnswers[j]);
      final q = Question(
          cardType: widget.type,
          questionIndex: questionIndex,
          question: questionsAnswers[i],
          possibleAnswers: possibleAnswers,
          correctAnswerIndex: correctAnswersIndexes[answerIndex],
          image: image);
      questions.add(q);
      answerIndex++;
      questionIndex++;
    }
    switch (pageType) {
      case PageType.practice:
        PracticePage.create(context, widget.type, questions);
        break;
      case PageType.test:
        TestLandingPage.create(context, widget.type, questions);
        break;
      case PageType.questionArchive:
        ArchivePage.create(context, questions);
        break;
      case PageType.accountPage:
        AccountPage.create(context: context, questions: questions);
        break;
      default:
        return;
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<List<String>> _loadQuestionsAndAnswers(Database database) async {
    List<String> questionsAnswers =
        await database.getQuestionsWithAnswers(widget.type);
    return questionsAnswers;
  }

  _loadCorrectAnswersIndexes(Database database) async {
    List<int> answerIndexes = await database.getAnswerIndexes(widget.type);
    return answerIndexes;
  }

  Future<void> _buyFullVersion() async {
    UpdatedMarketScreen.show(context);
    // await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         fullscreenDialog: true, builder: (context) => MyApp()));
  }
}
