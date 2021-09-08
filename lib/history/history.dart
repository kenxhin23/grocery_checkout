import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:grocery_checkout/api.dart';
// import 'package:grocery_checkout/home.dart';
import 'package:grocery_checkout/userdata.dart';
import 'package:intl/intl.dart';

// void main() {
//   runApp(History());
// }

// class History extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'CheckOut App',
//       theme: ThemeData(
//         primaryColor: ColorData.headerColor,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: MyHistoryPage(),
//     );
//   }
// }

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  String date = '';
  String newDate = '';
  String time = '';
  String newTime = '';
  String _searchController = "";
  List _tranList = [];
  bool viewSpinkit = true;
  bool emptyTranHistory = false;
  bool searchEmpty = false;

  void initState() {
    super.initState();
    // print(UserData.id);
    loadHistoryApi();
  }

  loadHistoryApi() async {
    var fpn = await loadHistory(UserData.id);
    if (!mounted) return;
    setState(() {
      _tranList = fpn;
      viewSpinkit = false;

      if (_tranList.isEmpty) {
        emptyTranHistory = true;
      }
      _tranList.forEach((element) {
        print(element['updated_at'].toString());
      });
    });
  }

  searchCustomers() async {
    var getC = await searchCust(UserData.id, _searchController);
    if (!mounted) return;
    setState(() {
      _tranList = getC;

      if (_tranList.isEmpty) {
        searchEmpty = true;
      } else {
        searchEmpty = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        backgroundColor: ColorData.headerColor,
        automaticallyImplyLeading: false,
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
                    height: 30,
                  ),
                  buildSearchField(),
                  SizedBox(
                    height: 10,
                  ),
                  buildTranCont(),
                ],
              ),
            ),
          )
        ],
      ),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Container buildSearchField() {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(left: 10),
      child: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  // width: MediaQuery.of(context).size.width - 130,
                  width: MediaQuery.of(context).size.width - 20,
                  height: 40,
                  child: TextFormField(
                    // controller: searchController,
                    onChanged: (String str) {
                      setState(() {
                        _searchController = str;
                        searchCustomers();
                      });
                    },
                    decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black87),
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        hintText: 'Search Customer'),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container buildTranCont() {
    if (viewSpinkit == true) {
      return Container(
        height: MediaQuery.of(context).size.height / 2 + 100,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: SpinKitFadingCircle(
            color: Colors.deepOrange,
            size: 50,
          ),
        ),
      );
    }
    if (emptyTranHistory == true) {
      return Container(
        padding: EdgeInsets.all(50),
        margin: EdgeInsets.only(top: 50),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        // color: Colors.deepOrange,
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.event_busy,
              size: 100,
              color: Colors.grey[500],
            ),
            Text(
              'You have no transaction history.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            )
          ],
        ),
      );
    }
    if (searchEmpty == true) {
      return Container(
        padding: EdgeInsets.all(50),
        margin: EdgeInsets.only(top: 50),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        // color: Colors.deepOrange,
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.event_busy,
              size: 100,
              color: Colors.grey[500],
            ),
            Text(
              'No results found',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            )
          ],
        ),
      );
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 230,
      // color: Colors.white,
      child: ListView.builder(
          padding: const EdgeInsets.all(0),
          itemCount: _tranList.length,
          itemBuilder: (context, index) {
            if (_tranList[index]['mop'] == null) {
              _tranList[index]['mop'] = 'Pick-up';
            }
            date = _tranList[index]['updated_at'];
            DateTime e = DateTime.parse(date);
            newDate = DateFormat("MMM. dd, yyyy").format(e);
            time = _tranList[index]['updated_at'];
            DateTime z = DateTime.parse(time);
            newTime = DateFormat.jm().format(z);

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 6 - 15,
                    margin: EdgeInsets.only(left: 20, top: 10, right: 20),
                    padding: EdgeInsets.all(10),
                    color: ColorData.themeColor,
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _tranList[index]['ticket_id'].toString(),
                                style: TextStyle(
                                    fontSize: 16,
                                    color: ColorData.fontLightColor,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(height: 5),
                              Text(
                                _tranList[index]['customer'].toString(),
                                style: TextStyle(
                                    fontSize: 18,
                                    color: ColorData.fontLightColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Number of packs: ' +
                                    _tranList[index]['total_quantity']
                                        .toString(),
                                style: TextStyle(
                                    fontSize: 15,
                                    color: ColorData.fontLightColor,
                                    fontWeight: FontWeight.w400),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Mode of Order: ' +
                                    _tranList[index]['mop'].toString(),
                                style: TextStyle(
                                    fontSize: 15,
                                    color: ColorData.fontLightColor,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          // width: MediaQuery.of(context).size.width / 2 - 50,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Checkout Date',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: ColorData.fontLightColor,
                                    fontWeight: FontWeight.w400),
                              ),
                              SizedBox(height: 5),
                              Text(
                                newDate,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: ColorData.fontLightColor,
                                    fontWeight: FontWeight.w400),
                              ),
                              SizedBox(height: 5),
                              Text(
                                newTime,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: ColorData.fontLightColor,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
