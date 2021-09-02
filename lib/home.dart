import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:grocery_checkout/api.dart';
import 'package:grocery_checkout/home/checkout.dart';
// import 'package:grocery_checkout/menu.dart';
import 'package:grocery_checkout/userdata.dart';
// import 'dart:ui' as ui;

class Home extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CheckOut App',
      theme: ThemeData(
        primaryColor: ColorData.headerColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final transactionController = TextEditingController();
  List _pickList = [];
  List _delList = [];
  List temp = [];
  int charlength = 0;
  String forPickup = '';
  String _scanBarcode = 'Click to Scan';
  bool spinKit = false;
  Timer timer;

  void initState() {
    refreshList();
    timer =
        Timer.periodic(Duration(seconds: 1), (Timer t) => loadForPickupNo());
    super.initState();
  }

  loadForPickupNo() async {
    var fpn = await loadForPickup(UserData.buCode);
    _pickList = fpn;
    var fpn2 = await loadForDelivery(UserData.buCode);
    _delList = fpn2;
    setState(() {
      forPickup = (int.parse(_pickList.length.toString()) +
              int.parse(_delList.length.toString()))
          .toString();
    });
  }

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 1));
    loadForPickupNo();
  }

  checkReceiptCode() async {
    var rsp = await getTransaction(_scanBarcode);

    if (rsp != '') {
      setState(() {
        spinKit = false;
      });

      if (rsp == "NOT FOUND!") {
        print('BARCODE NOT FOUND!');
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => NotFoundDialog(
                title: 'Transaction not Found!', description: ''));
        transactionController.text = '';
      } else {
        TranData.tran = rsp['ticket_id'].toString();
        TranData.receipt = rsp['receipt'].toString();
        TranData.date = rsp['created_at'].toString();
        TranData.name = rsp['customer'].toString();
        TranData.packNo = rsp['total_quantity'].toString();
        TranData.mop = rsp['mop'].toString();
        if (rsp['mop'] == null) {
          TranData.mop = 'Pick-up';
        }
        print('SCAN SUCCESSFUL');
        timer.cancel();
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) =>
                ScanSuccessful(title: 'Transaction Found!', description: ''));
      }
    }
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;
    setState(() {
      _scanBarcode = barcodeScanRes;
      // transactionController.text = _scanBarcode;
      print('SCAN RESULT:' + _scanBarcode);
      spinKit = true;
      checkReceiptCode();
    });
  }

  unloadSpinkit() async {
    spinKit = false;
    print('Unload Spinkit');
  }

  @override
  void dispose() {
    timer?.cancel();
    transactionController.dispose();
    print('Timer Disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Transaction'),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            // color: Colors.grey[400],
            child: SingleChildScrollView(
              // padding: EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 5),
              child: Column(
                children: [
                  buildPickupCont(),
                  SizedBox(
                    height: 30,
                  ),
                  buildScanCustCont(),
                  buildScanOptionCont(),
                  buildScanCodeCont(),
                  buildNoteCont(),
                ],
              ),
            ),
          ),
          // Container(
          //   height: 100,
          //   width: MediaQuery.of(context).size.width,
          //   color: Colors.red,
          // )
        ],
      ),
    );
  }

  buildScanCodeCont() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      /*curve: Curves.easeInOutBack,*/
      // height: 250,
      // color: Colors.grey,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(left: 20, right: 20, top: 10),
      // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: SingleChildScrollView(
        child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                spinKit
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        height: 90,
                        // color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SpinKitCircle(
                              color: Colors.deepOrange,
                              size: 36,
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                            // color: ColorData.trans,
                            borderRadius: BorderRadius.circular(0),
                            border: Border.all(
                              width: 2,
                              color: ColorData.themeColor,
                            )),
                      )
                    : TextFormField(
                        style: TextStyle(
                          fontSize: 40,
                        ),
                        textAlign: TextAlign.center,
                        controller: transactionController,
                        keyboardType: TextInputType.text,
                        onTap: () {
                          if (GlobalVariables.phonePressed == true) {
                            scanBarcodeNormal();
                          }
                          if (GlobalVariables.scannerPressed == true) {
                            print('Scanner');
                          }
                        },
                        onChanged: (String value) {
                          if (GlobalVariables.scannerPressed == true) {
                            if (transactionController.text.length ==
                                BarcodeData.receiptLength) {
                              spinKit = true;
                              _scanBarcode = transactionController.text;
                              checkReceiptCode();
                            }
                          }
                        },
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorData.themeColor,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: ColorData.themeColor2, width: 2),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(0)),
                            ),
                            hintText: 'Press & Scan',
                            hintStyle: TextStyle(color: Colors.grey[300])),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Transaction cannot be empty';
                          }
                          return null;
                        },
                      ),
              ],
            )),
      ),
    );
  }

  buildPickupCont() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.only(left: 10),
      width: MediaQuery.of(context).size.width,
      height: 90,
      color: ColorData.themeColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            'READY FOR PICKUP ITEM:',
            style: TextStyle(fontSize: 18, color: ColorData.fontLightColor),
          ),
          Container(
            // color: Colors.grey,
            width: 50,
            height: 50,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    // margin: EdgeInsets.only(top: 2),
                    padding: EdgeInsets.only(top: 5),
                    width: 35,
                    height: 30,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorData.fontLightColor),
                    child: Text(
                      forPickup,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColorData.fontDarkColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  buildScanCustCont() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 100,
      color: ColorData.themeColor2,
      margin: EdgeInsets.only(left: 20, right: 20),
      child: Center(
        child: Text(
          'SCAN CUSTOMER TRANSACTION #',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: ColorData.fontLightColor),
        ),
      ),
    );
  }

  Container buildScanOptionCont() {
    return Container(
      height: 100,
      width: 400,
      margin: EdgeInsets.only(top: 0, bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new SizedBox(
            width: 100,
            height: 80,
            child: InkWell(
              onTap: () {
                setState(() {
                  GlobalVariables.scannerPressed = false;
                  GlobalVariables.phonePressed = true;
                });
              },
              child: new Container(
                // color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                    // color: ColorData.trans,
                    borderRadius: BorderRadius.circular(0),
                    border: Border.all(
                      width: 2,
                      color: GlobalVariables.phonePressed
                          ? ColorData.themeColor
                          : Colors.grey,
                    )),
                child: Image(
                  image: AssetImage('assets/images/scan1.png'),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 2,
          ),
          new SizedBox(
            width: 100,
            height: 80,
            child: InkWell(
              onTap: () {
                setState(() {
                  GlobalVariables.phonePressed = false;
                  GlobalVariables.scannerPressed = true;
                });
              },
              child: new Container(
                // color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                    // color: ColorData.trans,
                    borderRadius: BorderRadius.circular(0),
                    border: Border.all(
                      width: 2,
                      color: GlobalVariables.scannerPressed
                          ? ColorData.themeColor
                          : Colors.grey,
                    )),
                child: Image(
                  image: AssetImage('assets/images/scan2.png'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container buildNoteCont() {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      // color: Colors.grey,
      margin: EdgeInsets.all(20),
      child: GlobalVariables.phonePressed
          ? Container(
              child: Text(
                "Note: Please clear the rear camera and scan in a good lighting area.",
                style: TextStyle(
                  color: ColorData.themeColor,
                  fontSize: 12,
                ),
              ),
            )
          : Container(
              child: Text(
                "Note: Please connect the barcode scanner.",
                style: TextStyle(
                  color: ColorData.themeColor,
                  fontSize: 12,
                ),
              ),
            ),
    );
  }
}

class ScanSuccessful extends StatefulWidget {
  final String title, description;

  ScanSuccessful({this.title, this.description});
  @override
  _ScanSuccessfulState createState() => _ScanSuccessfulState();
}

class _ScanSuccessfulState extends State<ScanSuccessful> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        // child: confirmContent(context),
        child: successContent(context),
      ),
    );
  }

  successContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width / 2 + 100,
          padding: EdgeInsets.only(top: 0, bottom: 16, right: 5, left: 5),
          margin: EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Container(
                child: Icon(
                  Icons.check_circle_outline,
                  color: ColorData.secondColor,
                  size: 70,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Text(
                  widget.title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                color: Colors.deepOrange,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                onPressed: () {
                  // loadFavorites(),

                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Checkout();
                  }));
                },
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class NotFoundDialog extends StatefulWidget {
  final String title, description;

  NotFoundDialog({this.title, this.description});
  @override
  _NotFoundDialogState createState() => _NotFoundDialogState();
}

class _NotFoundDialogState extends State<NotFoundDialog> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        // child: confirmContent(context),
        child: content(context),
      ),
    );
  }

  content(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width / 2 + 100,
          padding: EdgeInsets.only(top: 0, bottom: 16, right: 5, left: 5),
          margin: EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Container(
                child: Icon(
                  Icons.not_interested,
                  color: Colors.redAccent,
                  size: 70,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Text(
                  widget.title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                color: Colors.deepOrange,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                onPressed: () => {
                  // loadFavorites(),
                  Navigator.pop(context),
                },
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LoadingSpinkit extends StatefulWidget {
  @override
  _LoadingSpinkitState createState() => _LoadingSpinkitState();
}

class _LoadingSpinkitState extends State<LoadingSpinkit> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      // child: confirmContent(context),
      child: loadingContent(context),
    );
  }

  loadingContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
            // width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 50, bottom: 16, right: 5, left: 5),
            margin: EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.transparent,
                    // blurRadius: 10.0,
                    // offset: Offset(0.0, 10.0),
                  ),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Searching Barcode......',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Colors.white),
                ),
                SpinKitCircle(
                  color: Colors.deepOrange,
                ),
              ],
            )),
      ],
    );
  }
}
