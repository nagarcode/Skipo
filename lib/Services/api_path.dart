class APIPath {
  static String questionsFile(String cardType) =>
      'assets/Questions/$cardType.txt';

  static String answersFile(String cardType) => 'assets/Answers/$cardType.txt';

  static String cardImage(String cardType) => 'assets/CardImages/$cardType.jpg';

  static String questionImage(String questionNumber, String prefix) =>
      'assets/Questions/Images/$prefix/$prefix$questionNumber.jpg';

  static String correctAnswer() => 'assets/Icons/v1.png';

  static String wronAnswer() => 'assets/Icons/x1.jpg';

  static questionMark() => 'assets/Icons/questionMark.jpg';

  static signsText(String typeString) => 'assets/Signs/Text/$typeString.txt';

  static signsImage(String typeString, String index) =>
      'assets/Signs/Images/$typeString/$index.jpg';

  static paidVersion() => 'isPaidVersion';

  static answeredQuestions() => 'answeredQuestionsCounter';

  static testsCounter() => 'testCounter';

  static skipoLogo() => 'assets/Icons/skipo.png';
  static privacyPolicyURL() =>
      'https://nagarcode.github.io/Skipo/Privacy-Policy.html';
  static termsAndConditionsURL() =>
      'https://nagarcode.github.io/Skipo/Terms-And-Conditions.html';
}
