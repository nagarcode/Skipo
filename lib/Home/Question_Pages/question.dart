import 'package:flutter/material.dart';
import 'package:skippo/Home/home_card.dart';

class Question {
  final String question;
  final List<String> possibleAnswers;
  final int correctAnswerIndex;
  final Widget image;
  final int questionIndex;
  final CardType cardType;
  Question(
      {@required this.correctAnswerIndex,
      @required this.possibleAnswers,
      @required this.question,
      @required this.image,
      @required this.questionIndex,
      @required this.cardType});

  @override
  String toString() {
    return 'Question: ' +
        question +
        '\n' +
        'Answer 1: ' +
        possibleAnswers[0] +
        '\n' +
        'Answer 2: ' +
        possibleAnswers[1] +
        '\n' +
        'Answer 3: ' +
        possibleAnswers[2] +
        '\n' +
        'Answer 4: ' +
        possibleAnswers[3] +
        '\n' +
        'Correct answer index: ' +
        correctAnswerIndex.toString() +
        '\n' +
        'Image: ' +
        image.toString();
  }

  String getLocalPath() {
    final index = questionIndex.toString();
    return cardType.toString().substring(9) + index;
  }
}
