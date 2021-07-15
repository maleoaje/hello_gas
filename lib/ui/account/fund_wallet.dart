/*
This is account information page

include file in reuseable/global_function.dart to call function from GlobalFunction
include file in reuseable/cache_image_network.dart to use cache image network
 */

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hello_gas/config/constants.dart';
import 'package:hello_gas/config/global_style.dart';
import 'package:hello_gas/network/network_handler.dart';
//import 'package:url_launcher/url_launcher.dart';
import 'package:hello_gas/ui/bottom_navigation_bar.dart';

class FundWalletPage extends StatefulWidget {
  @override
  _FundWalletPageState createState() => _FundWalletPageState();
}

class _FundWalletPageState extends State<FundWalletPage> {
  final _globalkey = GlobalKey<FormState>();
  NetworkHandler networkHandler = NetworkHandler();
  FlutterSecureStorage storage = FlutterSecureStorage();
  late String errorText;
  bool validate = false;
  bool circular = false;
  bool circularA = true;
  bool circularBal = false;
  String memberType = '';
  String memberId = '';
  String name = '';
  String email = '';
  String amount = '';
  String walletID = '';
  TextEditingController _etAmount = TextEditingController();
  double depositAmount = 0;
  String checkOutURL = '';
  String payRefernce = '';
  String errortxt = '';
  bool button = false;
  @override
  void initState() {
    super.initState();
    fetchData();
    fetchBalance();
  }

  void fetchBalance() async {
    String walletId = (await storage.read(key: 'walletId'))!;
    var response = await networkHandler
        .get('/api/Usermanagement/GetWalletBalance?WalletId=$walletId');
    setState(() {
      amount = response['data']['walletBalance'];
    });
  }

  void fetchData() async {
    String mail = (await storage.read(key: 'email'))!;
    setState(() {
      email = mail;
      circularA = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: PRIMARY_COLOR, //change your color here
          ),
          elevation: 0,
          title: Text(
            'Fund Wallet',
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
          child: Center(
            child: circularA
                ? Center(
                    child: SizedBox(
                        child: CircularProgressIndicator(
                          backgroundColor: ASSENT_COLOR,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        width: 50,
                        height: 50),
                  )
                : Form(
                    key: _globalkey,
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(30, 10, 30, 30),
                      children: <Widget>[
                        _getBalance(),
                        SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: Text(
                            'Enter Amount',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 4, left: 50, right: 50),
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) return "Enter Amount";
                              return null;
                            },
                            controller: _etAmount,
                            keyboardType: TextInputType.phone,
                            /*decoration: InputDecoration(
                              prefixIcon: Icon(Icons.money, color: ASSENT_COLOR),
                            ),*/
                            decoration: InputDecoration(
                              prefixIcon:
                                  Icon(Icons.money, color: PRIMARY_COLOR),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: PRIMARY_COLOR, width: 2.0)),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xffb3e5fc)),
                              ),
                              labelText: 'Enter Amount',
                              labelStyle: TextStyle(color: PRIMARY_COLOR),
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            errortxt,
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () async {
                            setState(() {
                              circular = true;
                            });
                            if (_globalkey.currentState!.validate()) {
                              String walletPin =
                                  (await storage.read(key: 'walletId'))!;
                              print(_etAmount);
                              Map<String, String> pin = {
                                "walletId": walletPin,
                                "amount": _etAmount.text,
                              };
                              print(walletPin);
                              var response = await networkHandler.post(
                                  '/api/Usermanagement/Fundwallet', pin);
                              Map<String, dynamic> depo =
                                  json.decode(response.body);
                              print(depo);
                              await storage.write(
                                  key: 'checkfund',
                                  value: depo['data']['checkoutUrl']);
                              await storage.write(
                                  key: 'payreffund',
                                  value: depo['data']['paymentReference']);
                              String checkouturl =
                                  (await storage.read(key: 'checkfund'))!;
                              String payRef =
                                  (await storage.read(key: 'payreffund'))!;
                              setState(() {
                                payRefernce = payRef;
                                checkOutURL = checkouturl;
                              });

                              print(checkouturl);
                              print(payRef);
                              showLoading('Click ok to proceed to payment');

                              if (depo['code'] != '00') {
                                Fluttertoast.showToast(
                                    backgroundColor: Colors.green,
                                    msg: depo['message'],
                                    toastLength: Toast.LENGTH_LONG);
                                setState(() {
                                  circular = false;
                                });
                              } else {
                                Fluttertoast.showToast(
                                    backgroundColor: Colors.green,
                                    msg: depo['message'],
                                    toastLength: Toast.LENGTH_LONG);
                                setState(() {
                                  circular = false;
                                });
                              }
                            } else {
                              setState(() {
                                circular = false;
                              });
                            }
                          },
                          child: Container(
                            padding:
                                EdgeInsets.only(top: 4, left: 50, right: 50),
                            height: 50,
                            width: 0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Container(
                                height: 50,
                                width: 250,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1),
                                  color: PRIMARY_COLOR,
                                ),
                                child: Center(
                                  child: circular
                                      ? Center(
                                          child: SizedBox(
                                              child: CircularProgressIndicator(
                                                backgroundColor: PRIMARY_COLOR,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                              width: 20,
                                              height: 20),
                                        )
                                      : Text(
                                          'Deposit',
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
                      ],
                    ),
                  ),
          ),
        ));
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
              child: SizedBox(
                  child: CircularProgressIndicator(
                    backgroundColor: ASSENT_COLOR,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  width: 50,
                  height: 50),
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
                      style: TextStyle(fontSize: 17, color: Colors.black),
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
                          Navigator.of(context).pop();
                          // launch(checkOutURL);
                          showLoadingCheck('Click verify to verify payment');
                        },
                        padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
                        color: ASSENT_COLOR,
                        textColor: Colors.white,
                        child: Text(
                          'Proceed to payment',
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

  void showLoadingCheck(String textMessage) {
    _progressDialog(context);
    Timer(Duration(seconds: 2), () {
      Navigator.pop(context);
      FocusScope.of(context).unfocus();
      _buildShowDialogCheck(context, textMessage);
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

  Future _buildShowDialogCheck(BuildContext context, String textMessage) {
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
                      style: TextStyle(fontSize: 17, color: Colors.black),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: BorderSide(color: ASSENT_COLOR)),
                        onPressed: () async {
                          Map<String, String> sub = {
                            "paymentReference": payRefernce,
                          };
                          var response = await networkHandler.post(
                              '/api/Usermanagement/InitializeFundWallet', sub);
                          Map<String, dynamic> subStat =
                              json.decode(response.body);
                          print(subStat);
                          if (subStat['code'] == '99') {
                            showLoading(subStat['message']);
                          } else if (subStat['code'] == '00') {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        BottomNavigationBarPage()),
                                (Route<dynamic> route) => false);
                            Fluttertoast.showToast(
                                backgroundColor: Colors.green,
                                msg: subStat['message'],
                                toastLength: Toast.LENGTH_LONG);
                          }
                        },
                        padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                        color: ASSENT_COLOR,
                        textColor: Colors.black,
                        child: Text(
                          'Verify',
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

  void showLoading(String textMessage) {
    _progressDialog(context);
    Timer(Duration(seconds: 2), () {
      Navigator.pop(context);
      FocusScope.of(context).unfocus();
      _buildShowDialog(context, textMessage);
    });
  }
}
