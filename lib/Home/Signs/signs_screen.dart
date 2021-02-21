import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:skippo/Home/Signs/sign_tab.dart';
import 'package:skippo/Home/home_card.dart';

class SignsPage extends StatelessWidget {
  final CardType type;
  final List<SignTab> signTabs;

  const SignsPage({@required this.type, @required this.signTabs});

  static create(
      BuildContext context, CardType type, List<SignTab> signTabs) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => SignsPage(type: type, signTabs: signTabs),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Skippo',
          style: TextStyle(fontSize: 25, fontFamily: 'amaticaRegular'),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Flexible(
              flex: 6,
              child: Container(
                child: AutoSizeText(
                  _title(),
                  style: TextStyle(
                      fontSize: 40,
                      fontFamily: 'amaticaRegular',
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Spacer(flex: 2),
            Flexible(
              flex: 100,
              fit: FlexFit.tight,
              child: Container(
                child: _tabList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  _tabList() {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(),
      itemCount: signTabs.length,
      itemBuilder: (_, index) => ListTile(
        title: Text(signTabs[index].text),
        trailing: signTabs[index].image,
      ),
    );
  }

  String _title() {
    String toReturn;
    switch (type) {
      case CardType.daySignals:
        toReturn = 'סימני יום';
        break;
      case CardType.flagSignals:
        toReturn = 'דגלים';
        break;
      case CardType.lightSignals:
        toReturn = 'אורות';
        break;
      case CardType.soundSignals:
        toReturn = 'אותות קוליים';
        break;
      case CardType.sosSignals:
        toReturn = 'סימני מצוקה';
        break;
      default:
        toReturn = '';
    }
    return toReturn;
  }
}
