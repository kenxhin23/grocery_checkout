import 'dart:async';
// import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:grocery_checkout/api.dart';
import 'package:grocery_checkout/menu.dart';
import 'package:grocery_checkout/userdata.dart';
// import 'package:retry/retry.dart';

class MyLoginPage extends StatefulWidget {
  @override
  _MyLoginPageState createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscureText = true;
  bool viewSpinkit = true;
  String message = '';

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  // checkConnection() async {
  //   final client = HttpClient();

  //   try {
  //     // Get statusCode by retrying a function
  //     final r = RetryOptions(maxAttempts: 8);
  //     final statusCode = await retry(
  //       () async {
  //         // Make a HTTP request and return the status code.
  //         final request = await client
  //             .getUrl(Uri.parse('http://172.16.161.41:8005/'))
  //             .timeout(Duration(seconds: 5));
  //         final response = await request.close().timeout(Duration(seconds: 5));
  //         await response.drain();
  //         return response.statusCode;
  //       },
  //       // Retry on SocketException or TimeoutException
  //       retryIf: (e) => e is SocketException || e is TimeoutException,
  //     );

  //     // Print result from status code
  //     if (statusCode == 200) {
  //       print('google.com is running');
  //     } else {
  //       print('google.com is not availble...');
  //     }
  //   } finally {
  //     // Always close an HttpClient from dart:io, to close TCP connections in the
  //     // connection pool. Many servers has keep-alive to reduce round-trip time
  //     // for additional requests and avoid that clients run out of port and
  //     // end up in WAIT_TIME unpleasantries...
  //     client.close();
  //   }
  // }

  // void _toggle2() {
  //   setState(() {
  //     obscureText = true;
  //   });
  // }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 30, bottom: 20),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 24),
                      width: MediaQuery.of(context).size.width / 2 + 100,
                      height: MediaQuery.of(context).size.height / 3 - 50,
                      // color: Colors.grey,
                      child: Center(
                        child: Image(
                          image: AssetImage('assets/images/icon.png'),
                        ),
                      ),
                    ),
                    Text(
                      "Releasing Checker Login",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      /*curve: Curves.easeInOutBack,*/
                      height: 250,
                      width: 350,
                      // width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(top: 10),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      child: SingleChildScrollView(
                        child: buildSignInTextField(),
                      ),
                    ),
                    buildSignInButton(),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                width: MediaQuery.of(context).size.width,
                // height: 30,
                // color: Colors.grey,
                child: Text(
                  'E-COMMERCE(GROCERY_CHECKOUT APP) V1.' +
                      GlobalVariables.appVersion +
                      ' COPYRIGHT 2020',
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Container buildSignInButton() {
    return Container(
      margin: EdgeInsets.only(top: 0),
      // width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorData.themeColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
              padding:  EdgeInsets.symmetric(horizontal: 60, vertical: 12),
              elevation: 10,
            ),
            onPressed: () async {
              // checkConnection();
              if (viewSpinkit == true) {
                if (_formKey.currentState.validate()) {
                  var username = usernameController.text;
                  var password = passwordController.text;

                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => ConnectServerBox());

                  var rsp = await loginUser(username, password);
                  print(rsp);
                  if (rsp != '') {
                    Navigator.pop(context);
                  }
                  if (rsp == 'failed username') {
                    print("Invalid username or Password");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          backgroundColor: Colors.red,
                          content: Text("Invalid username or Password")),
                    );
                  } else if (rsp == 'failed password') {
                    print("Invalid username or Password");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          backgroundColor: Colors.red,
                          content: Text("Invalid username or Password")),
                    );
                  } else {
                    if (rsp['status'] == '0') {
                      showDialog(
                          context: context,
                          builder: (context) => ConfirmBox(
                                title: 'Invalid',
                                description:
                                    'Your account has been disabled. Please contact Administrator.',
                                buttonText: 'Okay',
                              ));
                    } else {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => LoggingInBox());
                      UserData.id = rsp['emp_id'];
                      UserData.name = rsp['name'];
                      // UserData.lastname = rsp['lastname'];
                      // UserData.department = rsp['department'];
                      UserData.position = rsp['usertype'];
                      // UserData.contact = rsp['mobile'];
                      UserData.buCode = rsp['bunit_code'];
                      UserData.username = rsp['username'];

                      // var getP = await getProcessed(UserData.id);

                      print("Login Successful!");
                      viewSpinkit = false;
                      if (viewSpinkit == false) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return Menu();
                        }));
                      }
                    }
                  }
                }
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  "LOGIN",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 60,
          ),
          Text(message),
        ],
      ),
    );
  }

  Column buildSignInTextField() {
    return Column(children: [
      Form(
          key: _formKey,
          child: Column(children: <Widget>[
            TextFormField(
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              controller: usernameController,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87),
                    borderRadius: BorderRadius.all(Radius.circular(0)),
                  ),
                  hintText: 'Username'),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Username cannot be empty';
                }
                return null;
              },
            ),
            SizedBox(
              height: 25,
            ),
            Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    TextFormField(
                      obscureText: _obscureText,
                      controller: passwordController,
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                              size: 30,
                            ),
                            onPressed: () {
                              _toggle();
                            },
                          ),
                          hintText: 'Password'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Password cannot be empty';
                        }
                        return null;
                      },
                    ),
                  ],
                )
              ],
            )
          ]))
    ]);
  }
}

class ConfirmBox extends StatefulWidget {
  final String title, description, buttonText;

  ConfirmBox({this.title, this.description, this.buttonText});

  @override
  _ConfirmBoxState createState() => _ConfirmBoxState();
}

class _ConfirmBoxState extends State<ConfirmBox> {
  final String changeStat = 'Delivered';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: confirmContent(context),
    );
  }

  confirmContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 50, bottom: 16, right: 5, left: 5),
          margin: EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(0),
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
              Container(
                margin: EdgeInsets.only(bottom: 5),
                height: 70,
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                // decoration: BoxDecoration(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Text(
                        widget.description,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.deepOrange,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      ),
                      onPressed: () => {
                        Navigator.pop(context),
                      },
                      child: Text(
                        widget.buttonText,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 10),
          height: 40,
          width: MediaQuery.of(context).size.width,
          // color: Colors.deepOrange,
          decoration: BoxDecoration(
              color: Colors.deepOrange,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0), topRight: Radius.circular(0))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.title,
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

// void initSignIn() {}
class LoggingInBox extends StatefulWidget {
  @override
  _LoggingInBoxState createState() => _LoggingInBoxState();
}

class _LoggingInBoxState extends State<LoggingInBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
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
                  'Logging in as Releasing Checker...',
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

class ConnectServerBox extends StatefulWidget {
  @override
  _ConnectServerBoxState createState() => _ConnectServerBoxState();
}

class _ConnectServerBoxState extends State<ConnectServerBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
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
