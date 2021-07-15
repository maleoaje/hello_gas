/*
This is about page

install plugin in pubspec.yaml
- package_info (https://pub.dev/packages/package_info)

Don't forget to add all images and sound used in this pages at the pubspec.yaml
 */

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hello_gas/config/constants.dart';
import 'package:hello_gas/config/global_style.dart';
import 'package:hello_gas/network/network_handler.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class TransferPage extends StatefulWidget {
  @override
  _TransferPageState createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  String amount = '';
  TextEditingController _etAmount = TextEditingController();
  TextEditingController _etPin = TextEditingController();
  TextEditingController _etNara = TextEditingController();
  NetworkHandler networkHandler = NetworkHandler();
  bool circular = false;
  bool circularBal = false;
  double depositAmount = 0;
  final storage = new FlutterSecureStorage();
  String checkOutURL = '';
  String payRefernce = '';
  bool circulare = false;
  String reciever = '';
  String recieverWallet = '';
  String name = '';
  String email = '';
  String walletID = '';

  void fetchBalance() async {
    String walletId = (await storage.read(key: 'walletId'))!;
    var response = await networkHandler
        .get('/api/Usermanagement/GetWalletBalance?WalletId=$walletId');
    setState(() {
      amount = response['data']['walletBalance'];
    });
  }

  @override
  void initState() {
    super.initState();
    fetchBalance();
    fetchData();
  }

  void fetchData() async {
    String firstName = (await storage.read(key: 'firstName'))!;
    String mail = (await storage.read(key: 'email'))!;
    String walletId = (await storage.read(key: 'walletId'))!;
    setState(() {
      name = firstName;
      email = mail;
      walletID = walletId;
      circular = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: PRIMARY_COLOR, //change your color here
        ),
        elevation: 0,
        brightness: Brightness.light,
        title: Text(
          'Transfer Funds',
          style: GlobalStyle.appBarTitle,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        bottom: PreferredSize(
            child: Container(
              color: Colors.grey[100],
              height: 1.0,
            ),
            preferredSize: Size.fromHeight(1.0)),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            alignment: Alignment.center,
            image: AssetImage("assets/images/acct.jpg"),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[100],
          boxShadow: [
            BoxShadow(
                color: Color(0x10000000),
                blurRadius: 10,
                spreadRadius: 4,
                offset: Offset(0.0, 8.0))
          ],
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _getBalance(),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.only(top: 4, left: 20, right: 20),
                    child: TextFormField(
                      controller: _etAmount,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: PRIMARY_COLOR, width: 2.0)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffb3e5fc)),
                        ),
                        labelText: 'Enter Amount',
                        labelStyle: TextStyle(color: PRIMARY_COLOR),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Reciever\'s wallet Id ',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: PRIMARY_COLOR),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 20, right: 20),
                    child: PinCodeTextField(
                      validator: (v) {
                        if (v!.length < 9) {
                          return "Check wallet ID";
                        } else {
                          return null;
                        }
                      },
                      obscureText: false,
                      keyboardType: TextInputType.number,
                      appContext: context,
                      cursorColor: PRIMARY_COLOR,
                      length: 9,
                      pinTheme: PinTheme(
                        fieldHeight: 50,
                        fieldWidth: 20,
                        borderWidth: 0,
                      ),
                      textStyle: TextStyle(fontSize: 16, color: PRIMARY_COLOR),
                      onChanged: (value) {
                        print(value);
                      },
                      onCompleted: (v) async {
                        setState(() {
                          circulare = true;
                          recieverWallet = v;
                        });
                        Map<String, dynamic> data = {
                          "walletId": v,
                        };
                        print(data);
                        var response = await networkHandler.post(
                            '/api/Usermanagement/WalletNameEnquiry', data);
                        Map<String, dynamic> output =
                            json.decode(response.body);
                        print(output);
                        if (response.statusCode == 200) {
                          //Map<String, dynamic> output = json.decode(response.body);
                          print(output);
                          if (output['code'] == '00') {
                            Fluttertoast.showToast(
                                backgroundColor: Colors.green,
                                msg: output['message'],
                                toastLength: Toast.LENGTH_LONG);
                            setState(() {
                              circulare = false;
                              reciever = output['data']['firstName'] +
                                  ' ' +
                                  output['data']['lastName'];
                            });
                          } else if (output['code'] != '00') {
                            Fluttertoast.showToast(
                                backgroundColor: Colors.green,
                                msg: output['message'],
                                toastLength: Toast.LENGTH_LONG);
                            setState(() {
                              circulare = false;
                              reciever = output['message'];
                            });
                          }
                        } else if (response.statusCode != 200) {
                          Fluttertoast.showToast(
                              backgroundColor: Colors.green,
                              msg: 'Please input reciever wallet ID',
                              toastLength: Toast.LENGTH_LONG);
                          setState(() {
                            circulare = false;
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 3),
                  Container(
                    height: 20,
                    width: 20,
                    margin: EdgeInsets.only(right: 230, left: 10),
                    child: Text(
                      '$reciever',
                      style: TextStyle(fontSize: 14, color: PRIMARY_COLOR),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.only(top: 4, left: 20, right: 20),
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) return "Enter Pin";
                        if (value.length != 4) return "Check Pin";
                        return null;
                      },
                      inputFormatters: [
                        new LengthLimitingTextInputFormatter(4),
                      ],
                      controller: _etPin,
                      obscureText: true,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: PRIMARY_COLOR, width: 2.0)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffb3e5fc)),
                        ),
                        labelText: 'Enter Pin',
                        labelStyle: TextStyle(color: PRIMARY_COLOR),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.only(top: 4, left: 20, right: 20),
                    child: TextField(
                      controller: _etNara,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: PRIMARY_COLOR, width: 2.0)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffb3e5fc)),
                        ),
                        labelText: 'Narration',
                        labelStyle: TextStyle(color: PRIMARY_COLOR),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        circular = true;
                      });
                      String walletPin = (await storage.read(key: 'walletId'))!;
                      print(_etAmount);
                      Map<String, String> pin = {
                        "senderWalletId": walletPin,
                        "amount": _etAmount.text,
                        "transactionPin": _etPin.text,
                        "receiverWalletId": recieverWallet,
                        "narration": _etNara.text
                      };
                      print(pin);
                      var response = await networkHandler.post(
                          '/api/Usermanagement/TransferWalletToWallet', pin);
                      Map<String, dynamic> transfer =
                          json.decode(response.body);
                      print(transfer);
                      if (response.statusCode == 400) {
                        Fluttertoast.showToast(
                            backgroundColor: Colors.red,
                            msg: 'Fill in all fields',
                            toastLength: Toast.LENGTH_LONG);
                        circular = false;
                      }

                      if (transfer['code'] != '00') {
                        Fluttertoast.showToast(
                            backgroundColor: Colors.red,
                            msg: transfer['message'],
                            toastLength: Toast.LENGTH_LONG);
                        setState(() {
                          circular = false;
                        });
                      } else if (transfer['code'] == '00') {
                        showLoading('Transfer of ₦' +
                            transfer['data']['amount'].toString() +
                            ' to: ' +
                            transfer['data']['receiverFullName'] +
                            ' Successful');
                        setState(() {
                          circular = false;
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.only(top: 4, left: 50, right: 50),
                      height: 50,
                      width: 0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Container(
                          height: 50,
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: PRIMARY_COLOR,
                          ),
                          child: Center(
                            child: circular
                                ? SizedBox(
                                    child: CircularProgressIndicator(
                                      backgroundColor: ASSENT_COLOR,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                    width: 20,
                                    height: 20)
                                : Text(
                                    'Transfer',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void showLoading(String textMessage) {
    _progressDialog(context);
    Timer(Duration(seconds: 2), () {
      Navigator.pop(context);
      FocusScope.of(context).unfocus();
      _buildShowDialog(context, textMessage);
    });
  }

  Future _progressDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(null);
            },
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }

  Future _buildShowDialog(BuildContext context, String textMessage) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(null);
            },
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)), //this right here
              child: Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.fromLTRB(40, 20, 40, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      textMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: BorderSide(color: ASSENT_COLOR)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                        color: Theme.of(context).accentColor,
                        textColor: Colors.white,
                        child: Text(
                          'Continue',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _getBalance() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        setState(() {
          circularBal = true;
        });
        String walletId = (await storage.read(key: 'walletId'))!;
        var response = await networkHandler
            .get('/api/Usermanagement/GetWalletBalance?WalletId=$walletId');
        setState(() {
          amount = response['data']['walletBalance'];
          circularBal = false;
        });
      },
      child: Container(
        height: 100,
        width: 250,
        decoration: BoxDecoration(
          image: DecorationImage(
            alignment: Alignment.center,
            image: AssetImage("assets/images/currentB.jpg"),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[100],
          boxShadow: [
            BoxShadow(
                color: Color(0x10000000),
                blurRadius: 10,
                spreadRadius: 4,
                offset: Offset(0.0, 8.0))
          ],
        ),
        child: Stack(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(120, 0, 0, 0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: "\nCurrent Balance\n",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        TextSpan(
                            text: "\₦ ",
                            style:
                                TextStyle(color: Colors.white, fontSize: 20)),
                        TextSpan(
                            text: '$amount \n',
                            style:
                                TextStyle(color: ASSENT_COLOR, fontSize: 25)),
                        TextSpan(
                            text: "Wallet ID: $walletID ",
                            style:
                                TextStyle(color: Colors.white, fontSize: 17)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
