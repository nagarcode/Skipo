import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skippo/Home/home_card.dart';
import 'package:skippo/Home/home_page_stateful.dart';
import 'package:skippo/Services/api_path.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class LandingScreen extends StatelessWidget {
  final StreamingSharedPreferences streamingSharedPrefs;
  const LandingScreen({this.streamingSharedPrefs});
  @override
  Widget build(BuildContext context) {
    final List<HomeCard> cards = [
      HomeCard(type: CardType.skipper, imageFilename: 'skipper'),
      HomeCard(type: CardType.jetski, imageFilename: 'jetski'),
      HomeCard(type: CardType.boatA, imageFilename: 'boat_a'),
      HomeCard(type: CardType.boatB, imageFilename: 'boat_b'),
    ];

    return PreferenceBuilder(
        preference: _payStream(),
        builder: (context, bool snapshot) {
          final bool didPay = false;
          // final bool didPay = snapshot; //TODO: change
          return Provider<bool>.value(
            value: didPay,
            child: HomePageStateful(
              cards: cards,
              didPay: didPay,
            ),
          );
        });
  }

  Preference<bool> _payStream() {
    final path = APIPath.paidVersion();
    return streamingSharedPrefs.getBool(path, defaultValue: false);
  }
}
