import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:grocery_checkout/api.dart';
import 'package:grocery_checkout/menu.dart';
import 'package:grocery_checkout/userdata.dart';
import 'package:intl/intl.dart';
// import 'dart:ui' as ui;

class Checkout extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CheckOut App',
      theme: ThemeData(
        primaryColor: ColorData.headerColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CheckoutPage(),
    );
  }
}

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<TextEditingController> _controllers = new List();
  // final _formKey = GlobalKey<FormState>();
  final barcodeController = TextEditingController();
  // final _focusNode = FocusNode();
  int charlength = 0;
  bool viewSpinkit = true;
  String barcode = '';
  String packType = '';
  bool tranCheckOut = false;
  String stat = '';
  Timer timer1;

  // String _scanBarcode = '';

  final String date =
      DateFormat("yyyy-MM-dd H:mm:ss").format(new DateTime.now());

  List _packList = [];

  void initState() {
    super.initState();
    GlobalVariables.noConnection = false;
    loadPackage();
    timer1 = Timer.periodic(Duration(seconds: 1), (Timer t) => changeStatus());
  }

  loadPackage() async {
    int x = 0;
    var getP = await getPackCount(TranData.receipt, TranData.mop);
    if (!mounted) return;
    _packList = getP;
    // print(_packList);
    setState(() {
      if (_packList.isNotEmpty) {
        viewSpinkit = false;
      }
      _packList.forEach((element) {
        if (packType == element['type']) {
          x = x + 1;
          element['no'] = x.toString();
        } else {
          x = 1;
          packType = element['type'];
          element['no'] = x.toString();
        }
        // print(_packList);
      });
    });
  }

  checkPackList() {
    tranCheckOut = true;
    print(_packList);
    _packList.forEach((element) {
      setState(() {
        if (element['status'] == 'Paid') {
          tranCheckOut = false;
        }
        print(element['status']);
      });
    });
  }

  checkBarcode(bcode) {
    String s = 'NOT FOUND';
    print(bcode);
    _packList.forEach((element) {
      setState(() {
        if (element['barcode'] == bcode && element['status'] == 'Paid') {
          element['status'] = 'Paid and Released';
          s = 'SCANNED';
          // print(_packList);
        } else if (element['barcode'] == bcode &&
            element['status'] == 'Paid and Released') {
          s = 'ALREADY SCANNED';
        }
      });
    });
    stat = s;
  }

  changeTransactionStatus() async {
    print('NISUD');
    print(TranData.receipt);
    print(date);
    print(UserData.id);
    print(TranData.tran);
    print(TranData.mop);
    var x = await changeTranStat(
        TranData.receipt, UserData.id, TranData.tran, TranData.mop);
    print(x);

    if (x == 'STATUS CHANGED') {
      GlobalVariables.noConnection = false;
      timer1.cancel();
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => ScanAlertDialog(
              title: 'Transaction Checked Out!',
              description: 'Barcode Found.'));
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Menu();
      }));
    } else {
      setState(() {
        GlobalVariables.noConnection = true;
      });

      print('------------------ERRORRRRRR-----------------');
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => ConnectServerBox());
    }
  }

  changeStatus() async {
    if (GlobalVariables.noConnection == true) {
      GlobalVariables.pop = false;
      print('-----------------CONNECTING TO SERVER---------------------');
      var x = await changeTranStat(
          TranData.receipt, UserData.id, TranData.tran, TranData.mop);

      if (x == 'STATUS CHANGED') {
        timer1.cancel();
        GlobalVariables.noConnection = false;

        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => ScanAlertDialog(
                title: 'Transaction Checked Out!',
                description: 'Barcode Found.'));
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Menu();
        }));
      }
    }
  }

  Future<void> scanBarcodeNormal(temp) async {
    String barcodeScanRes = '';
    String tempBarcode = temp;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {
      if (tempBarcode.toString() == barcodeScanRes.toString()) {
        setState(() {
          stat = 'FOUND';
        });
      }

      // _controllers[index] = _scanBarcode;
      // print('SCAN RESULT:' + _scanBarcode);
      // checkReceiptCode();
    });
  }

  @override
  void dispose() {
    timer1.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Transaction',
          ),
        ),
        body: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  // mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    buildCloseButton(),
                    SizedBox(
                      height: 10,
                    ),
                    buildTranHeaderCont(),
                    SizedBox(
                      height: 10,
                    ),
                    buildBarcodeField(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  buildCloseButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40,
      // color: Colors.grey,
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: () {
            showDialog(context: context, builder: (context) => ConfirmDialog());
          },
          child: Icon(
            Icons.highlight_off,
            color: ColorData.themeColor,
            size: 36,
          ),
        ),
      ),
    );
  }

  buildTranHeaderCont() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 180,
      color: ColorData.themeColor2,
      margin: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Text(
                  'ORDER # : ',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: ColorData.fontLightColor),
                ),
                Text(
                  TranData.tran,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorData.fontLightColor),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Text(
                  'CUSTOMER NAME : ',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: ColorData.fontLightColor),
                ),
                Text(
                  TranData.name,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorData.fontLightColor),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Text(
                  'NO. OF PACKS : ',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: ColorData.fontLightColor),
                ),
                Container(
                  color: Colors.white,
                  width: 40,
                  height: 25,
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          TranData.packNo,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ColorData.fontDarkColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Text(
                  'MODE OF ORDER : ',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: ColorData.fontLightColor),
                ),
                Text(
                  TranData.mop,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorData.fontLightColor,
                      decoration: TextDecoration.underline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  buildBarcodeField() {
    if (viewSpinkit == true) {
      return Container(
        height: 620,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: SpinKitFadingCircle(
            color: Colors.deepOrange,
            size: 50,
          ),
        ),
      );
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 310,
      color: Colors.white,
      child: ListView.builder(
          padding: const EdgeInsets.all(0),
          itemCount: _packList.length,
          itemBuilder: (context, index) {
            int x = _packList.length;
            print(x);
            bool scanned = false;
            if (_packList[index]['status'] == 'Paid and Released') {
              scanned = true;
            }
            if (GlobalVariables.clearText == true &&
                _packList[index]['status'] == 'Unfound') {
              _controllers[index].selection = TextSelection(
                  baseOffset: 0, extentOffset: _controllers[index].text.length);
            }
            _controllers.add(new TextEditingController());
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 30, top: 0),
                    child: Text(
                      _packList[index]['type'] +
                          // _packList[index]['barcode'] +
                          ' ' +
                          _packList[index]['no'] +
                          ' :',
                      style: TextStyle(
                          fontSize: 18,
                          color: ColorData.fontDarkColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  AbsorbPointer(
                    absorbing: scanned,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      /*curve: Curves.easeInOutBack,*/
                      height: 100,
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                      // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      child: Column(
                        children: <Widget>[
                          Column(children: <Widget>[
                            TextFormField(
                              style: TextStyle(
                                  fontSize: scanned ? 18 : 28,
                                  fontWeight: scanned
                                      ? FontWeight.bold
                                      : FontWeight.w400,
                                  color: scanned
                                      ? ColorData.secondColor
                                      : ColorData.fontDarkColor),
                              autofocus: true,
                              textAlign: TextAlign.center,
                              onTap: () async {
                                stat = 'NOT FOUND';
                                print(int.parse(_packList[index]['barcode']
                                    .length
                                    .toString()));
                                _controllers[index].text = '';
                                if (GlobalVariables.phonePressed == true) {
                                  await scanBarcodeNormal(
                                      _packList[index]['barcode']);
                                  if (stat == 'FOUND') {
                                    _controllers[index].text = 'SCANNED';
                                    _packList[index]['status'] =
                                        'Paid and Released';
                                    checkPackList();
                                    if (tranCheckOut == true) {
                                      print(
                                          '-------------------------------------NISUD');
                                      changeTransactionStatus();
                                    } else {
                                      FocusScope.of(context).nextFocus();
                                    }
                                  } else {
                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) => NotFoundDialog(
                                            title: 'Not Found!',
                                            description: 'Barcode Found.'));
                                    setState(() {
                                      _packList[index]['status'] = 'Unfound';
                                      if (GlobalVariables.clearText == true) {
                                        _controllers[index].selection =
                                            TextSelection(
                                                baseOffset: 0,
                                                extentOffset:
                                                    _controllers[index]
                                                        .text
                                                        .length);
                                      }
                                    });
                                  }
                                }
                              },
                              onChanged: (value) {
                                if (GlobalVariables.scannerPressed == true) {
                                  if (int.parse(_controllers[index]
                                          .text
                                          .length
                                          .toString()) ==
                                      int.parse(_packList[index]['barcode']
                                          .length
                                          .toString())) {
                                    if (!tranCheckOut) {
                                      if (_controllers[index].text ==
                                          _packList[index]['barcode']) {
                                        setState(() async {
                                          _controllers[index].text = 'SCANNED';
                                          _packList[index]['status'] =
                                              'Paid and Released';
                                          checkPackList();
                                          if (tranCheckOut == true) {
                                            // setState(() {
                                            changeTransactionStatus();
                                            // var x = await changeTranStat(
                                            //     TranData.receipt,
                                            //     date,
                                            //     UserData.id,
                                            //     TranData.tran);
                                            // print(x);
                                            // showDialog(
                                            //     barrierDismissible: false,
                                            //     context: context,
                                            //     builder: (context) =>
                                            //         ScanAlertDialog(
                                            //             title:
                                            //                 'Transaction Checked Out!',
                                            //             description:
                                            //                 'Barcode Found.'));
                                            // Navigator.push(context,
                                            //     MaterialPageRoute(
                                            //         builder: (context) {
                                            //   return Menu();
                                            // }));
                                            // });
                                          } else {
                                            print('NEXT FOCUS!!!!!!!!!!!!!!!');
                                            FocusScope.of(context).nextFocus();
                                          }
                                        });
                                      } else {
                                        showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (context) =>
                                                NotFoundDialog(
                                                    title: 'Not Found!',
                                                    description:
                                                        'Barcode Found.'));
                                        setState(() {
                                          _packList[index]['status'] =
                                              'Unfound';
                                          if (GlobalVariables.clearText ==
                                              true) {
                                            _controllers[index].selection =
                                                TextSelection(
                                                    baseOffset: 0,
                                                    extentOffset:
                                                        _controllers[index]
                                                            .text
                                                            .length);
                                          }
                                        });
                                      }
                                    }
                                  }
                                  // else {
                                  //   if (int.parse(_controllers[index]
                                  //           .text
                                  //           .length
                                  //           .toString()) ==
                                  //       int.parse(BarcodeData.barcodeLength
                                  //           .toString())) {
                                  //     if (!tranCheckOut) {
                                  //       if (_controllers[index].text ==
                                  //           _packList[index]['barcode']) {
                                  //         setState(() {
                                  //           _controllers[index].text =
                                  //               'SCANNED';
                                  //           _packList[index]['status'] =
                                  //               'Paid and Released';
                                  //           checkPackList();
                                  //           if (tranCheckOut == true) {
                                  //             setState(() {
                                  //               changeTranStat(
                                  //                   TranData.receipt,
                                  //                   date,
                                  //                   UserData.id,
                                  //                   TranData.tran);
                                  //               showDialog(
                                  //                   barrierDismissible: false,
                                  //                   context: context,
                                  //                   builder: (context) =>
                                  //                       ScanAlertDialog(
                                  //                           title:
                                  //                               'Transaction Checked Out!',
                                  //                           description:
                                  //                               'Barcode Found.'));
                                  //               Navigator.push(context,
                                  //                   MaterialPageRoute(
                                  //                       builder: (context) {
                                  //                 return Menu();
                                  //               }));
                                  //             });
                                  //           } else {
                                  //             FocusScope.of(context)
                                  //                 .nextFocus();
                                  //           }
                                  //         });
                                  //       } else {
                                  //         showDialog(
                                  //             barrierDismissible: false,
                                  //             context: context,
                                  //             builder: (context) =>
                                  //                 NotFoundDialog(
                                  //                     title: 'Not Found!',
                                  //                     description:
                                  //                         'Barcode Found.'));
                                  //         setState(() {
                                  //           _packList[index]['status'] =
                                  //               'Unfound';
                                  //           if (GlobalVariables.clearText ==
                                  //               true) {
                                  //             _controllers[index].selection =
                                  //                 TextSelection(
                                  //                     baseOffset: 0,
                                  //                     extentOffset:
                                  //                         _controllers[index]
                                  //                             .text
                                  //                             .length);
                                  //           }
                                  //         });
                                  //       }
                                  //     }
                                  //   }
                                  // }
                                }
                              },
                              controller: _controllers[index],
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ColorData.themeColor, width: 2),
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
                                  hintText: ''),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

class ScanAlertDialog extends StatefulWidget {
  final String title, description;

  ScanAlertDialog({this.title, this.description});
  @override
  _ScanAlertDialogState createState() => _ScanAlertDialogState();
}

class _ScanAlertDialogState extends State<ScanAlertDialog> {
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                onPressed: () {
                  GlobalVariables.pop = true;
                  Navigator.pop(context);
                  // Navigator.push(context, MaterialPageRoute(builder: (context) {
                  //   return Checkout();
                  // })),
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
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Stack(
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  onPressed: () {
                    setState(() {
                      GlobalVariables.clearText = true;
                      // print('TRUEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE');
                    });
                    Navigator.pop(context);
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
      ),
    );
  }
}

class ConfirmDialog extends StatefulWidget {
  @override
  _ConfirmDialogState createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      // child: confirmContent(context),
      child: confirmContent(context),
    );
  }

  confirmContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          // color: Colors.grey,
          padding: EdgeInsets.only(top: 70, bottom: 10, right: 5, left: 5),
          // margin: EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
              color: Colors.grey[50],
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
            children: <Widget>[
              Container(
                // height: 280,
                margin: EdgeInsets.only(bottom: 5),
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                // decoration: BoxDecoration(),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            // color: Colors.grey,
                            width: MediaQuery.of(context).size.width / 2,
                            margin: EdgeInsets.only(left: 10),
                            child: Center(
                              child: Text(
                                'Are you sure you want to close this transaction?',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                                // overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                // color: Colors.grey,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.deepOrange,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 12),
                            ),
                            onPressed: () => {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return Menu();
                              })),
                            },
                            child: Text(
                              'Okay',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.deepOrange,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 12),
                            ),
                            onPressed: () => {
                              Navigator.pop(context),
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 10),
          height: 60,
          width: MediaQuery.of(context).size.width,
          // color: Colors.deepOrange,
          decoration: BoxDecoration(
              color: ColorData.headerColor,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Confirmation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ConnectServerBox extends StatefulWidget {
  @override
  _ConnectServerBoxState createState() => _ConnectServerBoxState();
}

class _ConnectServerBoxState extends State<ConnectServerBox> {
  Timer timer3;

  void initState() {
    timer3 = Timer.periodic(Duration(seconds: 1), (Timer t) => popDialog());
    super.initState();
  }

  popDialog() {
    if (!GlobalVariables.noConnection && GlobalVariables.pop == true) {
      Navigator.pop(context);
      // GlobalVariables.pop = true;
      timer3.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        // child: confirmContent(context),
        child: loadingContent(context),
      ),
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
                borderRadius: BorderRadius.circular(0),
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
                  'Connecting to Server...',
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
