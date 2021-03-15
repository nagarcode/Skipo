import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:provider/provider.dart';
import 'package:skippo/Services/api_path.dart';
import 'package:skippo/Services/database.dart';
import 'package:skippo/common_widgets/platform_alert_dialog.dart';

const skippoFullVersionProductID = 'full7';
const subscriptionProductID = 'sub1';

class UpdatedMarketScreen extends StatefulWidget {
  final Database database;

  const UpdatedMarketScreen({@required this.database});
  @override
  _UpdatedMarketScreenState createState() => new _UpdatedMarketScreenState();
  static show(BuildContext context) async {
    final database = Provider.of<Database>(context, listen: false);
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UpdatedMarketScreen(database: database),
            fullscreenDialog: true));
  }
}

class _UpdatedMarketScreenState extends State<UpdatedMarketScreen> {
  StreamSubscription _purchaseUpdatedSubscription;
  StreamSubscription _purchaseErrorSubscription;
  StreamSubscription _conectionSubscription;
  final List<String> _productLists =
      Platform.isAndroid ? [] : [skippoFullVersionProductID];
  final List<String> _subscriptionList = [subscriptionProductID];
  List<IAPItem> _products = [];
  List<IAPItem> _subscriptions = [];
  List<PurchasedItem> _purchases = [];
  bool isLoading = true;
  bool smallWidgetIsLoading = false;

  @override
  void initState() {
    super.initState();
    initPlatformState().then((value) {
      _getProduct();
      _getSubscription();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // centerTitle: false,
        leading: IconButton(
          iconSize: 30,
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(CupertinoIcons.xmark),
          color: Colors.black,
        ),
        title: Text(
          'ברוכים הבאים לגרסא המלאה',
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _logo(),
            _skipo(),
            _currentPlan(),
            // _infoBox(),
            _subscriptionPlanBox('3.90'), //TODO: change price
            // _buyWithArrow(),
            Expanded(child: _otherPlanLayout()),
          ],
        ),
      ),
    );
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

  Future _getSubscription() async {
    showPendingUI(true);
    List<IAPItem> subs =
        await FlutterInappPurchase.instance.getSubscriptions(_subscriptionList);
    for (var item in subs) {
      this._subscriptions.add(item);
    }
    setState(() {
      this._subscriptions = subs;
    });
    showPendingUI(false);
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

  ///other plan layouts
  Widget _otherPlanLayout() {
    return Padding(
      padding: EdgeInsets.only(
          right: MediaQuery.of(context).size.width * 0.1,
          left: MediaQuery.of(context).size.width * 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          _otherPlansLabel(),
          _planRow(),
        ],
      ),
    );
  }

  Widget _planRow() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _standardPlanBox(),
          SizedBox(width: MediaQuery.of(context).size.width * 0.03),
          _premiumPlanBox()
        ],
      ),
    );
  }

  Widget _subscriptionPlanBox(String price) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        splashColor: Colors.redAccent[100],
        highlightColor: Colors.white,
        onTap: () => {print('Tapped')},
        child: Container(
          height: MediaQuery.of(context).size.width * 0.3,
          width: MediaQuery.of(context).size.width * 0.35,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.only(left: 5, top: 10, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildPlanLabel('מנוי מוזל'),
              _buildPlanPrice('$price₪'),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: _buildFeatureLabel('לכל חודש, ניתן לבטל בכל רגע'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _payText(), //TODO: add conditional - if paid show checkmark
                    Icon(
                      CupertinoIcons.forward,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(top: 5.0),
              //   child: _buildFeatureLabel(
              //       '-Simultaneous viewing\n up to 2 people'),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _payText() {
    return AutoSizeText(
      'לתשלום',
      style: TextStyle(
          letterSpacing: 0.5,
          color: Colors.black,
          fontWeight: FontWeight.w800,
          fontSize: 13),
      textAlign: TextAlign.center,
    );
  }

  ///Standard plan box
  Widget _standardPlanBox() {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.04),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          splashColor: Colors.redAccent[100],
          highlightColor: Colors.white,
          onTap: () => {print('Tapped')},
          child: Container(
            height: MediaQuery.of(context).size.width * 0.35,
            width: MediaQuery.of(context).size.width * 0.35,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.only(left: 5, top: 10, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildPlanLabel('קנה לתמיד'),
                _buildPlanPrice('מחיר...'),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: _buildFeatureLabel('תשלום חד פעמי המקנה גישה לתמיד'),
                ),
                // Padding(
                //   padding: const EdgeInsets.only(top: 5.0),
                //   child: _buildFeatureLabel(
                //       '-Simultaneous viewing\n up to 2 people'),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///Premium plan box
  Widget _premiumPlanBox() {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.04),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          splashColor: Colors.redAccent[100],
          highlightColor: Colors.white,
          onTap: () => {print('Tapped')},
          child: Container(
            height: MediaQuery.of(context).size.width * 0.35,
            width: MediaQuery.of(context).size.width * 0.35,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.only(left: 5, top: 10, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildPlanLabel('שחזר קניה קיימת'),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: _buildFeatureLabel(
                      'קנית את סקיפו בעבר? לחץ כאן לשחזור הקניה בחינם'),
                ),
                // Padding(
                //   padding: const EdgeInsets.only(
                //     top: 5.0,
                //   ),
                //   child: _buildFeatureLabel(
                //       '-Simultaneous viewing\n up to 4 people'),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///build price
  Widget _buildPlanPrice(String price) {
    return Text(
      price,
      style: TextStyle(
          color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14),
      textAlign: TextAlign.center,
    );
  }

  ///build feature row label
  Widget _buildFeatureLabel(String label) {
    return Text(
      label,
      style: TextStyle(
          letterSpacing: 0.2,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
          fontSize: 10),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPlanLabel(String label) {
    return Text(
      label,
      style: TextStyle(
          letterSpacing: 0.1,
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 12),
      textAlign: TextAlign.center,
    );
  }

  ///other plan label at bottom
  Widget _otherPlansLabel() {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.06),
      child: Text(
        'אפשרויות אחרות',
        style: TextStyle(
            letterSpacing: 0.5,
            color: Colors.grey,
            fontWeight: FontWeight.w800,
            fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  ///Cancel subscription option
  Widget _buyWithArrow() {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'לתשלום',
            style: TextStyle(
                letterSpacing: 0.5,
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 14),
            textAlign: TextAlign.center,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          Icon(
            CupertinoIcons.forward,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  ///Subscription info box
  Widget _infoBox() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.08),
        child: Container(
          width: MediaQuery.of(context).size.width,
          margin:
              EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey[300]),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            'תוכנית נוכחית: **מחיר** לחודש, ניתן לבטל בכל רגע',
            style: TextStyle(
                letterSpacing: 1,
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  ///Netflix text
  Widget _skipo() {
    return Center(
      child: Padding(
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
        child: Text(
          'סקיפו',
          style: TextStyle(fontSize: 35, fontFamily: 'amaticaRegular'),
        ),
      ),
    );
  }

  Widget _currentPlan() {
    return Center(
      child: Padding(
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Text("9/חודש",
            //     style: TextStyle(
            //         fontSize: 16,
            //         color: Colors.black,
            //         fontWeight: FontWeight.bold)),
            // SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            Text("תאוריה ימית",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _logo() {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.09),
      width: MediaQuery.of(context).size.width * 0.3,
      height: MediaQuery.of(context).size.width * 0.3,
      decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black54.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 1))
          ]),
      child: Center(
          child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.black12,
        backgroundImage: AssetImage(APIPath.skipoLogo()),
      )),
    );
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
