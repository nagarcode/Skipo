import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skippo/Home/Question_Pages/question.dart';
import 'package:skippo/Home/Signs/sign_tab.dart';
import 'package:skippo/Home/home_card.dart';
import 'package:skippo/IAP/updated_market_screen.dart';
import 'package:skippo/Services/api_path.dart';
import 'package:skippo/common_widgets/platform_alert_dialog.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

abstract class Database {
  Future<List<String>> getQuestionsWithAnswers(CardType cardType);

  Future<List<int>> getAnswerIndexes(CardType cardType);

  Future<Widget> getQuestionImage(CardType type, int questionIndex);

  Future<List<SignTab>> getSignTabs(CardType type);

  Future<void> saveAnswer(Question question, bool correct);

  Future<bool> getAnswer(Question question);

  Future<int> getAnsweredQuestionsCounter();

  Future<int> getTestsCounter();

  Future<void> incrementTestsCounter();

  Future<void> makePaid();

  Future<bool> didFinishTrial();

  Future<bool> checkTrialAndShowDialogue(BuildContext context,
      bool didBuy); // returns true if trial is over and user didnt buy
}

class LocalPersistance implements Database {
  @override
  Future<List<String>> getQuestionsWithAnswers(CardType cardType) async {
    final typeString = getTypeString(cardType);
    final path = APIPath.questionsFile(typeString);
    List<String> questionsWithAnswers = [];
    await rootBundle.loadString(path).then((q) {
      for (String str in LineSplitter().convert(q)) {
        var toAdd = str.substring(3);
        if (toAdd.startsWith('.')) toAdd = toAdd.substring(1);
        if (toAdd.endsWith('.')) toAdd = toAdd.substring(0, toAdd.length - 1);
        questionsWithAnswers.add(toAdd); // removing question/answer number
      }
    });
    return questionsWithAnswers;
  }

  String getTypeString(CardType cardType) => cardType.toString().substring(9);

  @override
  Future<List<int>> getAnswerIndexes(CardType cardType) async {
    final typeString = getTypeString(cardType);
    final path = APIPath.answersFile(typeString);
    List<int> answerIndexes = [];
    await rootBundle.loadString(path).then((a) {
      for (String str in LineSplitter().convert(a)) {
        answerIndexes.add(int.parse(str));
      }
    });
    return answerIndexes;
  }

  @override
  Future<Widget> getQuestionImage(CardType type, int questionIndex) async {
    final prefix = HomeCard.getPrefix(type);
    final path = APIPath.questionImage(questionIndex.toString(), prefix);
    debugPrint(path);
    Widget image;
    try {
      await rootBundle.load(path);
      image = Image.asset(path);
    } catch (e) {
      print('caught exception: no image');
      image = SizedBox.shrink();
    }
    return image;
  }

  @override
  Future<List<SignTab>> getSignTabs(CardType type) async {
    final typeString = getTypeString(type);
    final textPath = APIPath.signsText(typeString);
    List<SignTab> tabs = [];
    var index = 1;
    await rootBundle.loadString(textPath).then((t) async {
      for (String str in LineSplitter().convert(t)) {
        final image = await getSignImage(type, index);
        final tab = SignTab(image, str);
        tabs.add(tab);
        index++;
      }
    });
    return tabs;
  }

  getSignImage(CardType type, int index) async {
    final typeString = getTypeString(type);
    final path = APIPath.signsImage(typeString, index.toString());
    var image;
    try {
      await rootBundle.load(path);
      image = Image.asset(path);
    } catch (e) {
      print('caught exception: no image');
      image = SizedBox.shrink();
    }
    return image;
  }

  @override
  Future<void> saveAnswer(Question question, bool correct) async {
    final prefs = await StreamingSharedPreferences.instance;
    _incrementQuestionCounter();
    final path = question.getLocalPath();
    prefs.setBool(path, correct);
  }

  _incrementQuestionCounter() async {
    final prefs = await StreamingSharedPreferences.instance;
    final answersPath = APIPath.answeredQuestions();
    final preCount = await getAnsweredQuestionsCounter();
    prefs.setInt(answersPath, preCount + 1);
  }

  Future<int> getAnsweredQuestionsCounter() async {
    final prefs = await StreamingSharedPreferences.instance;
    final count = prefs.getInt(APIPath.answeredQuestions(), defaultValue: 0);
    return count.getValue();
  }

  Future<int> getTestsCounter() async {
    final prefs = await StreamingSharedPreferences.instance;
    final count = prefs.getInt(APIPath.testsCounter(), defaultValue: 0);
    return count.getValue();
  }

  @override
  Future<void> incrementTestsCounter() async {
    final prefs = await StreamingSharedPreferences.instance;
    final testCounterPath = APIPath.testsCounter();
    final preCount = await getTestsCounter();
    final newCount = preCount + 1;
    prefs.setInt(testCounterPath, newCount);
  }

  @override
  Future<bool> getAnswer(Question question) async {
    final path = question.getLocalPath();
    final prefs = await StreamingSharedPreferences.instance;
    return prefs.getBool(path, defaultValue: false).getValue();
  }

  @override
  Future<void> makePaid() async {
    final prefs = await StreamingSharedPreferences.instance;
    prefs.setBool(APIPath.paidVersion(), true);
  }

  @override
  Future<bool> didFinishTrial() async {
    final testCounter = await getTestsCounter();
    final questionCounter = await getAnsweredQuestionsCounter();
    final obligatory = testCounter > 3 || questionCounter > 50;
    return obligatory;
  }

  @override
  Future<bool> checkTrialAndShowDialogue(
      BuildContext context, bool didBuy) async {
    final finishedTrial = await didFinishTrial();
    final mustBuy = (!didBuy) && finishedTrial;
    var didRequestBuy;
    if (mustBuy) {
      final dialog = PlatformAlertDialog(
        title: 'סיימת את מכסת הנסיון',
        defaultActionText: 'חזור למסך הבית',
        content:
            'סיימת את מכסת המבחנים והשאלות החינמית. כדי להנות משימוש מלא עליך לרכוש את האפליקציה',
        cancelActionText: 'רכוש עכשיו',
      );
      print('showing dialog');
      didRequestBuy = !await dialog.show(context);
      if (!didRequestBuy)
        Navigator.of(context).popUntil((route) => route.isFirst);
      else
        UpdatedMarketScreen.show(context);
    }
    return !mustBuy;
  }
}
