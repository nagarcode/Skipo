import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:provider/provider.dart';
import 'package:skippo/Home/splash_screen.dart';
import 'package:skippo/Services/api_path.dart';
import 'package:skippo/Services/database.dart';
import 'package:skippo/common_widgets/platform_alert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

const oneTimePaymentProductID = 'full7';
const subscriptionProductID = 'sub4';

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
  final List<String> _productLists = Platform.isAndroid
      ? []
      : [oneTimePaymentProductID, subscriptionProductID];
  // final List<String> _subscriptionList = [subscriptionProductID, 'sub3'];
  List<IAPItem> _products = [];
  // List<IAPItem> _subscriptions = [];
  List<PurchasedItem> _purchases = [];
  IAPItem sub;
  IAPItem oneTimePayment;
  bool isLoading = true;
  bool smallWidgetIsLoading = false;

  @override
  void initState() {
    super.initState();
    initPlatformState().then((value) {
      _getProducts();
      // _getSubscription();
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
    if (isLoading || sub == null || oneTimePayment == null)
      return SplashScreen();
    else
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _logo(),
              _skipo(),
              // _buyWithArrow(),
              _currentPlan(),
              _otherPlanLayout(),
              _subscriptionPlanBox(),
              _subscriptionSmallPrint(),
            ],
          ),
        ),
      );
  }

  void _launchURL(String url) async {
    await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
  }

  _launchTermsOfUseURL() {
    _launchURL(APIPath.termsAndConditionsURL());
  }

  _launchPrivacyPolicyURL() {
    _launchURL(APIPath.privacyPolicyURL());
  }

  Widget _subscriptionSmallPrint() {
    final price = sub.price.padRight(4, '0');
    final text =
        'חיוב של $price שקלים באופן חודשי דרך חשבון האפל שלך החל מעכשיו ועד אשר תתקבל בקשה לביטול (ניתן לבטל בכל רגע, ללא התחייבות, דרך חשבון האפל שלך בהגדרות הטלפון). לעוד מידע ניתן לגשת ל';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(children: [
              TextSpan(
                  text: text,
                  style: TextStyle(color: Colors.grey, fontSize: 10)),
              TextSpan(
                  text: 'מדיניות הפרטיות ',
                  style: TextStyle(color: Colors.blue, fontSize: 10),
                  recognizer: TapGestureRecognizer()
                    ..onTap = _launchPrivacyPolicyURL),
              TextSpan(
                  text: 'או ל',
                  style: TextStyle(color: Colors.grey, fontSize: 10)),
              TextSpan(
                  text: 'תנאי השימוש',
                  style: TextStyle(color: Colors.blue, fontSize: 10),
                  recognizer: TapGestureRecognizer()
                    ..onTap = _launchTermsOfUseURL),
            ])),
      ),
    );
  }

  Future _getProducts() async {
    showPendingUI(true);
    List<IAPItem> items =
        await FlutterInappPurchase.instance.getProducts(_productLists);
    for (var item in items) {
      this._products.add(item);
      if (item.productId == oneTimePaymentProductID)
        this.oneTimePayment = item;
      else if (item.productId == subscriptionProductID) this.sub = item;
    }

    setState(() {
      this._products = items;
    });
    showPendingUI(false);
  }

  // Future _getSubscription() async {
  //   showPendingUI(true);
  //   IAPItem sub;
  //   List<IAPItem> subs =
  //       await FlutterInappPurchase.instance.getSubscriptions(_subscriptionList);
  //   for (var item in subs) {
  //     this._subscriptions.add(item);
  //     if (item.productId == subscriptionProductID) sub = item;
  //   }
  //   setState(() {
  //     this._subscriptions = subs;
  //     this.sub = sub;
  //   });
  //   showPendingUI(false);
  // }

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
      // final skippoUpgradeId =
      //     _products.isNotEmpty ? _products.first.productId : null;
      final offeredItemsIDs = _getOfferedItemsIDS();
      if (offeredItemsIDs.contains(purchasedItem.productId)) {
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

  List<String> _getOfferedItemsIDS() {
    List<String> ids = [];
    for (IAPItem product in _products) {
      ids.add(product.productId);
    }
    return ids;
  }

  bool _shouldMakePaid(List<PurchasedItem> purchases) {
    final offeredItemsIDs = _getOfferedItemsIDS();
    for (PurchasedItem purchasedItem in purchases) {
      if (offeredItemsIDs.contains(purchasedItem.productId)) return true;
    }
    return false;
  }

  Future _getPurchases() async {
    showTinyPendingUI(true);
    List<PurchasedItem> clientPurchases =
        await FlutterInappPurchase.instance.getAvailablePurchases();
    for (var item in clientPurchases) {
      this._purchases.add(item);
      if (_shouldMakePaid(clientPurchases)) {
        widget.database.makePaid();
        _showThankyouDialogue();
      }
    }
    setState(() {
      this._purchases = clientPurchases;
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
          _oneTimePaymentBox(),
          SizedBox(width: MediaQuery.of(context).size.width * 0.03),
          _resotorePrevPurchaseBox()
        ],
      ),
    );
  }

  Widget _subscriptionPlanBox() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _otherPlansLabel(),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            // splashColor: Colors.redAccent[100],
            highlightColor: Colors.white,
            onTap: () {
              _requestPurchase(sub);
            },
            child: Container(
              height: MediaQuery.of(context).size.width * 0.3,
              width: MediaQuery.of(context).size.width * 0.35,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.only(left: 5, top: 10, bottom: 10),
              child: smallWidgetIsLoading
                  ? CircularProgressIndicator.adaptive()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        _buildPlanLabel(sub.title),
                        _buildPlanPrice(sub.price.padRight(4, '0') + '₪'),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: _buildFeatureLabel(
                              'לחודש באופן זמני, ניתן לבטל בכל רגע'),
                        ),
                        _callToActionText(),
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
      ],
    );
  }

  Widget _payText() {
    return AutoSizeText(
      'קדימה',
      style: TextStyle(
          letterSpacing: 0.5,
          color: Colors.black,
          fontWeight: FontWeight.w800,
          fontSize: 13),
      textAlign: TextAlign.center,
    );
  }

  Widget _callToActionText() {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _payText(),
          Icon(
            CupertinoIcons.forward,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  ///Standard plan box
  Widget _oneTimePaymentBox() {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.04),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          // splashColor: Colors.redAccent[100],
          highlightColor: Colors.white,
          onTap: () {
            _requestPurchase(oneTimePayment);
          },
          child: Container(
            height: MediaQuery.of(context).size.width * 0.35,
            width: MediaQuery.of(context).size.width * 0.35,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.only(left: 5, top: 10, bottom: 10),
            child: smallWidgetIsLoading
                ? CircularProgressIndicator.adaptive()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _buildPlanLabel('גישה לתמיד'),
                      _buildPlanPrice(oneTimePayment.price + '₪'),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: _buildFeatureLabel(
                            'תשלום חד פעמי המקנה גישה לתמיד'),
                      ),
                      _callToActionText()
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
  Widget _resotorePrevPurchaseBox() {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.04),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          // splashColor: Colors.redAccent[100],
          highlightColor: Colors.white,
          onTap: () {
            _getPurchases();
          },
          child: Container(
            height: MediaQuery.of(context).size.width * 0.35,
            width: MediaQuery.of(context).size.width * 0.35,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.only(left: 5, top: 10, bottom: 10),
            child: smallWidgetIsLoading
                ? CircularProgressIndicator.adaptive()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _buildPlanLabel('שחזר קניה קיימת'),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: _buildFeatureLabel(
                            'קנית את סקיפו בעבר? לחץ כאן לשחזור הקניה בחינם'),
                      ),
                      _callToActionText(),
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

  // Widget _buyWithArrow() {
  //   return Padding(
  //     padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: <Widget>[
  //         Text(
  //           'לתשלום',
  //           style: TextStyle(
  //               letterSpacing: 0.5,
  //               color: Colors.black,
  //               fontWeight: FontWeight.w800,
  //               fontSize: 14),
  //           textAlign: TextAlign.center,
  //         ),
  //         SizedBox(width: MediaQuery.of(context).size.width * 0.02),
  //         Icon(
  //           CupertinoIcons.forward,
  //           color: Colors.black,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _infoBox() {
  //   return Center(
  //     child: Padding(
  //       padding: EdgeInsets.symmetric(
  //           horizontal: MediaQuery.of(context).size.width * 0.08),
  //       child: Container(
  //         width: MediaQuery.of(context).size.width,
  //         margin:
  //             EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
  //         padding: EdgeInsets.all(15),
  //         decoration: BoxDecoration(
  //           color: Colors.grey[100],
  //           border: Border.all(color: Colors.grey[300]),
  //           borderRadius: BorderRadius.circular(5),
  //         ),
  //         child: Text(
  //           'תוכנית נוכחית: **מחיר** לחודש, ניתן לבטל בכל רגע',
  //           style: TextStyle(
  //               letterSpacing: 1,
  //               color: Colors.black,
  //               fontWeight: FontWeight.w400,
  //               fontSize: 12),
  //           textAlign: TextAlign.center,
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.02),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("תאוריה ימית",
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _logo() {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
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
}
