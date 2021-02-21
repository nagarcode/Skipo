import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skippo/Home/Menu/secondary_menu.dart';
import 'package:skippo/Home/Signs/signs_screen.dart';
import 'package:skippo/Home/home_card.dart';
import 'package:skippo/Services/api_path.dart';
import 'package:skippo/Services/database.dart';

class HomePageStateful extends StatefulWidget {
  final List<HomeCard> cards;
  final bool didPay;

  static create(BuildContext context, List<HomeCard> cards, bool didPay,
      Database database) async {
    final ok = await database.checkTrialAndShowDialogue(context, didPay);
    if (ok)
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePageStateful(
            cards: cards,
            didPay: didPay,
          ),
        ),
      );
  }

  HomePageStateful({@required this.cards, @required this.didPay});

  @override
  _HomePageStatefulState createState() => _HomePageStatefulState();
}

class _HomePageStatefulState extends State<HomePageStateful> {
  @override
  Widget build(BuildContext context) {
    print('did buy: ' + widget.didPay.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'סקיפו',
          style: TextStyle(fontSize: 25, fontFamily: 'amaticaRegular'),
        ),
      ),
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: widget.cards.length,
        itemBuilder: (_, index) => InkWell(
          onTap: () => cardTapped(widget.cards[index].type),
          child: Card(
            margin: EdgeInsets.all(0),
            child: Image.asset(
              APIPath.cardImage(widget.cards[index].imageFilename),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }

  void cardTapped(CardType type) {
    switch (type) {
      case CardType.skipper:
        skipperPressed();
        break;
      case CardType.daySignals:
        _createSignTabs(type);
        break;
      case CardType.flagSignals:
        _createSignTabs(type);
        break;
      case CardType.lightSignals:
        _createSignTabs(type);
        break;
      case CardType.soundSignals:
        _createSignTabs(type);
        break;
      case CardType.sosSignals:
        _createSignTabs(type);
        break;

      default:
        launchSecondaryMenu(type);
    }
  }

  _createSignTabs(CardType type) async {
    final database = Provider.of<Database>(context, listen: false);
    final tabs = await database.getSignTabs(type);
    SignsPage.create(context, type, tabs);
  }

  void launchSecondaryMenu(CardType type) async {
    final database = Provider.of<Database>(context, listen: false);
    final isObligatory = await database.didFinishTrial();
    // Navigator.push(context,
    //     MaterialPageRoute(builder: (context) => SecondaryMenu(type: type)));
    SecondaryMenu.create(context, type, widget.didPay, isObligatory);
  }

  void skipperPressed() {
    final database = Provider.of<Database>(context, listen: false);
    final List<HomeCard> cards = [
      HomeCard(type: CardType.yamaotC, imageFilename: 'yamaotC'),
      HomeCard(type: CardType.machinary, imageFilename: 'machinary'),
      HomeCard(type: CardType.navigationB, imageFilename: 'navigationB'),
    ];
    HomePageStateful.create(context, cards, widget.didPay, database);
  }
}
