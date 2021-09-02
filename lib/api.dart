import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:grocery_checkout/url.dart';

Future loginUser(String username, String password) async {
  String url = UrlAddress.url + '/userlogin';
  final response = await http.post(url,
      headers: {"Accept": "Application/json"},
      body: {'username': username, 'password2': password});
  var convertedDatatoJson = jsonDecode(response.body);
  return convertedDatatoJson;
}

Future getTransaction(String bcode) async {
  String url = UrlAddress.url + '/gettransaction';
  final response = await http.post(url,
      headers: {"Accept": "Application/json"}, body: {'receipt': bcode});
  var convertedDatatoJson = jsonDecode(response.body);
  return convertedDatatoJson;
}

Future loadForPickup(String bucode) async {
  String url = UrlAddress.url + '/loadforpickup';
  final response = await http.post(url,
      headers: {"Accept": "Application/json"}, body: {'bunit_code': bucode});
  var convertedDatatoJson = jsonDecode(response.body);
  return convertedDatatoJson;
}

Future loadForDelivery(String bucode) async {
  String url = UrlAddress.url + '/loadfordelivery';
  final response = await http.post(url,
      headers: {"Accept": "Application/json"}, body: {'bunit_code': bucode});
  var convertedDatatoJson = jsonDecode(response.body);
  return convertedDatatoJson;
}

Future getPackCount(String tran, String mop) async {
  String url = UrlAddress.url + '/getpackno';
  final response = await http.post(url,
      headers: {"Accept": "Application/json"},
      body: {'receipt': tran, 'mop': mop});
  var convertedDatatoJson = jsonDecode(response.body);
  return convertedDatatoJson;
}

Future scanBarcode(String tran, String bcode) async {
  String url = UrlAddress.url + '/searchbarcode';
  final response = await http.post(url,
      headers: {"Accept": "Application/json"},
      body: {'receipt': tran, 'barcode': bcode});
  var convertedDatatoJson = jsonDecode(response.body);
  return convertedDatatoJson;
}

Future changeTranStat(
    String tran, String user, String ticket, String mop) async {
  try {
    String url = UrlAddress.url + '/changestat';
    final response = await http.post(url, headers: {
      "Accept": "Application/json"
    }, body: {
      'receipt': tran,
      'user_id': user,
      'ticket_id': ticket,
      'mop': mop
    });
    var convertedDatatoJson = jsonDecode(response.body);
    return convertedDatatoJson;
  } on SocketException {
    return "ERROR";
  } on HttpException {
    return "ERROR";
  } on FormatException {
    return "ERROR";
  }
}

Future loadHistory(String uid) async {
  String url = UrlAddress.url + '/loadhistory';
  final response = await http.post(url,
      headers: {"Accept": "Application/json"}, body: {'user_id': uid});
  var convertedDatatoJson = jsonDecode(response.body);
  return convertedDatatoJson;
}

Future changeUserPassword(String id, String pass) async {
  String url = UrlAddress.url + '/changeuserpassword';
  final response = await http.post(url,
      headers: {"Accept": "Application/json"},
      body: {'emp_id': id, 'password2': pass});
  var convertedDatatoJson = jsonDecode(response.body);
  return convertedDatatoJson;
}

Future searchCust(String id, String name) async {
  String url = UrlAddress.url + '/searchhistory';
  final response = await http.post(url,
      headers: {"Accept": "Application/json"},
      body: {'user_id': id, 'customer': name});
  var convertedDatatoJson = jsonDecode(response.body);
  return convertedDatatoJson;
}
