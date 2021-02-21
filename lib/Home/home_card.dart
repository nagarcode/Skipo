enum CardType {
  skipper,
  motorbike,
  jetski,
  boatA,
  boatB,
  yamaotC,
  machinary,
  navigationB,
  daySignals,
  flagSignals,
  lightSignals,
  soundSignals,
  sosSignals,
}

class HomeCard {
  final CardType type;
  final String imageFilename;
  HomeCard({this.type, this.imageFilename});
  static String getPrefix(CardType type) {
    switch (type) {
      case CardType.navigationB:
        return 'sn';
        break;
      case CardType.yamaotC:
        return 'sk';
        break;
      case CardType.boatB:
        return 'ssb';
        break;
      case CardType.boatA:
        return 'sb';
        break;
      case CardType.jetski:
        return 'mb';
        break;
      // case CardType.daySignals:
      //   return 'day';
      //   break;
      // case CardType.flagSignals:
      //   return 'flag';
      //   break;
      // case CardType.lightSignals:
      //   return 'light';
      //   break;
      // case CardType.soundSignals:
      //   return 'sound';
      //   break;
      // case CardType.sosSignals:
      //   return 'sos';
      //   break;

      default:
        return null;
    }
  }
}
