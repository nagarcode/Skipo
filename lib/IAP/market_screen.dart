import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:provider/provider.dart';
import 'package:skippo/Services/database.dart';
import 'package:skippo/common_widgets/platform_alert_dialog.dart';

const skippoFullVersionProductID = 'full7';

class MarketScreen extends StatefulWidget {
  final Database database;

  const MarketScreen({@required this.database});
  @override
  _MarketScreenState createState() => new _MarketScreenState();
  static show(BuildContext context) async {
    final database = Provider.of<Database>(context, listen: false);
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MarketScreen(database: database),
            fullscreenDialog: true));
  }
}

class _MarketScreenState extends State<MarketScreen> {
  StreamSubscription _purchaseUpdatedSubscription;
  StreamSubscription _purchaseErrorSubscription;
  StreamSubscription _conectionSubscription;
  final List<String> _productLists =
      Platform.isAndroid ? [] : [skippoFullVersionProductID];

  List<IAPItem> _products = [];
  List<PurchasedItem> _purchases = [];
  bool isLoading = true;
  bool smallWidgetIsLoading = false;

  @override
  void initState() {
    super.initState();
    initPlatformState().then((value) {
      _getProduct();
      // _getPurchaseHistory();
      // _getPurchases();
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_conectionSubscription != null) {
      _conectionSubscription.cancel();
      _conectionSubscription = null;
    }
    _endConnections();
  }

  _endConnections() async {
    await FlutterInappPurchase.instance.endConnection;
    if (_purchaseUpdatedSubscription != null) {
      _purchaseUpdatedSubscription.cancel();
      _purchaseUpdatedSubscription = null;
    }
    if (_purchaseErrorSubscription != null) {
      _purchaseErrorSubscription.cancel();
      _purchaseErrorSubscription = null;
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // prepare
    var result = await FlutterInappPurchase.instance.initConnection;
    print('result: $result');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    // setState(() {
    //   _platformVersion = platformVersion;
    // });

    // refresh items for android
    // try {
    //   String msg = await FlutterInappPurchase.instance.consumeAllItems;
    //   print('consumeAllItems: $msg');
    // } catch (err) {
    //   print('consumeAllItems error: $err');
    // }

    _conectionSubscription =
        FlutterInappPurchase.connectionUpdated.listen((connected) {
      print('connected: $connected');
    });

    _purchaseUpdatedSubscription =
        FlutterInappPurchase.purchaseUpdated.listen((purchasedItem) {
      final skippoUpgradeId =
          _products.isNotEmpty ? _products.first.productId : null;
      if (skippoUpgradeId == purchasedItem.productId) {
        widget.database.makePaid();
        _showThankyouDialogue();
      }
      setState(() {
        _purchases.add(purchasedItem);
      });
    });

    _purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen((purchaseError) {
      print('purchase-error: $purchaseError');
      showTinyPendingUI(false);
      showPendingUI(false);
    });
  }

  Future<void> _requestPurchase(IAPItem item) async {
    showTinyPendingUI(true);
    await FlutterInappPurchase.instance.requestPurchase(item.productId);
    showTinyPendingUI(false);
  }

  Future _getProduct() async {
    showPendingUI(true);
    List<IAPItem> items =
        await FlutterInappPurchase.instance.getProducts(_productLists);
    for (var item in items) {
      this._products.add(item);
    }

    setState(() {
      this._products = items;
    });
    showPendingUI(false);
  }

  Future _getPurchases() async {
    showTinyPendingUI(true);
    List<PurchasedItem> items =
        await FlutterInappPurchase.instance.getAvailablePurchases();
    for (var item in items) {
      this._purchases.add(item);
      if (item.productId == skippoFullVersionProductID) {
        widget.database.makePaid();
        _showThankyouDialogue();
      }
    }
    setState(() {
      this._purchases = items;
    });
    showTinyPendingUI(false);
  }

  void showPendingUI(bool shouldShowIndicator) {
    setState(() {
      isLoading = shouldShowIndicator;
    });
  }

  void showTinyPendingUI(bool shouldShowIndicator) {
    setState(() {
      smallWidgetIsLoading = shouldShowIndicator;
    });
  }

  Card _buildProductList() {
    if (isLoading) {
      return Card(
          child: (ListTile(
              leading: CircularProgressIndicator(), title: Text('טוען...'))));
    }
    final ListTile productHeader =
        ListTile(title: Text('בחר את השדרוג הרצוי(לבחירה לחץ על המחיר)'));
    List<ListTile> productList = <ListTile>[];

    productList.addAll(
      _products.map(
        (IAPItem item) {
          final previousPurchaseExists =
              _purchases.any((element) => element.productId == item.productId);
          return ListTile(
            title: Text(
              item.title,
            ),
            subtitle: Text(
              item.description,
            ),
            trailing: previousPurchaseExists
                ? Icon(Icons.check)
                : smallWidgetIsLoading
                    ? CircularProgressIndicator()
                    :
                    // Container(
                    //     child:
                    CupertinoButton(
                        child: AutoSizeText(item.price + '₪'),
                        color: Colors.lightBlue[800],
                        onPressed: () {
                          _requestPurchase(item);
                        },
                      ),
            // ),
          );
        },
      ),
    );
    productList.add(_restoreListTile());

    return Card(
        child:
            Column(children: <Widget>[productHeader, Divider()] + productList));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // padding: EdgeInsets.all(10.0),
        appBar: AppBar(
          title: Text(
            'סקיפו',
            style: TextStyle(fontSize: 25, fontFamily: 'amaticaRegular'),
          ),
        ),
        body: Container(
          child: ListView(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _buildProductList(),
                ],
              ),
            ],
          ),
        ));
  }

  _showThankyouDialogue() async {
    final dialogue = PlatformAlertDialog(
        content: 'כעת תוכל להנות מכמות בלתי מוגבלת של מבחנים ושאלות. בהצלחה!',
        defaultActionText: 'סגור',
        title: 'ההגבלות הוסרו');
    await dialogue.show(context);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  ListTile _restoreListTile() {
    return ListTile(
      title: Text(
        'שחזור קניה קיימת',
      ),
      subtitle: Text(
        'לחץ לשחזור קניה קיימת',
      ),
      trailing: smallWidgetIsLoading
          ? CircularProgressIndicator()
          :
          // Container(
          //     child:
          CupertinoButton(
              child: AutoSizeText('Restore'),
              color: Colors.lightBlue[800],
              onPressed: () {
                _getPurchases();
              },
            ),
      // ),
    );
  }
}
