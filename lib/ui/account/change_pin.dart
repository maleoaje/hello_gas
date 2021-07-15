/*
This is signup with email page

Don't forget to add all images and sound used in this pages at the pubspec.yaml
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hello_gas/config/constants.dart';
import 'package:hello_gas/config/global_style.dart';
import 'package:hello_gas/network/network_handler.dart';

class ChangePinPage extends StatefulWidget {
  final String email;

  const ChangePinPage({this.email = ''});

  @override
  _ChangePinPageState createState() => _ChangePinPageState();
}

class _ChangePinPageState extends State<ChangePinPage> {
  TextEditingController _etOldPin = TextEditingController();
  TextEditingController _etNewPin = TextEditingController();
  late String errorText;
  bool validate = false;
  bool circular = false;
  bool circularA = true;
  String memberType = '';
  String memberId = '';
  String name = '';
  String email = '';
  String qrCode = '';
  late String profilePic;

  FlutterSecureStorage storage = FlutterSecureStorage();
  NetworkHandler networkHandler = NetworkHandler();

  final _globalkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchData();
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
    _etOldPin.dispose();
    _etNewPin.dispose();
    super.dispose();
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Change Pin')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Pin Changed Successfully'),
                Text('Thank you'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Continue'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: PRIMARY_COLOR, //change your color here
        ),
        elevation: 0,
        title: Text(
          'Change Pin',
          style: GlobalStyle.appBarTitle,
        ),
        backgroundColor: Colors.transparent,
        bottom: PreferredSize(
            child: Container(
              color: Colors.grey[100],
              height: 1.0,
            ),
            preferredSize: Size.fromHeight(1.0)),
      ),
      body: circularA
          ? SizedBox(
              child: CircularProgressIndicator(
                backgroundColor: PRIMARY_COLOR,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              width: 50,
              height: 50)
          : Container(
              //height: size.height * .35,
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
              child: Form(
                key: _globalkey,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(30, 30, 30, 30),
                  children: <Widget>[
                    //current password field

                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.only(top: 4, left: 50, right: 50),
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) return "Enter Current Pin";
                          if (value.length != 4) return "Check Pin";
                          return null;
                        },
                        inputFormatters: [
                          new LengthLimitingTextInputFormatter(4),
                        ],
                        controller: _etOldPin,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: PRIMARY_COLOR, width: 2.0)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFCCCCCC)),
                          ),
                          labelText: 'Current Pin',
                          labelStyle: TextStyle(color: PRIMARY_COLOR),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 5,
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.only(top: 4, left: 50, right: 50),
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) return "Enter New Pin";
                          if (value.length != 4) return "Check Pin";
                          return null;
                        },
                        inputFormatters: [
                          new LengthLimitingTextInputFormatter(4),
                        ],
                        controller: _etNewPin,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: PRIMARY_COLOR, width: 2.0)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFCCCCCC)),
                          ),
                          labelText: 'New Pin',
                          labelStyle: TextStyle(color: PRIMARY_COLOR),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: SizedBox(
                          //width: double.maxFinite,
                          child: RaisedButton(
                        elevation: 2,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(3.0),
                            side: BorderSide(color: PRIMARY_COLOR)),
                        onPressed: () async {
                          setState(() {
                            circular = true;
                          });
                          if (_globalkey.currentState!.validate()) {
                            String walletId =
                                (await storage.read(key: 'walletId'))!;
                            Map<String, String> pinChange = {
                              "walletId": walletId,
                              "old_TransactionPin": _etOldPin.text,
                              "new_TransactionPin": _etNewPin.text,
                            };
                            print(pinChange);
                            var response = await networkHandler.post(
                                '/api/Usermanagement/ChangeTransactionpin',
                                pinChange);
                            Map<String, dynamic> pass =
                                json.decode(response.body);
                            print(pass);
                            if (pass['code'] == '00') {
                              Navigator.pop(context);
                              _showMyDialog();
                              setState(() {
                                circular = false;
                              });
                            } else if (pass['code'] == '02') {
                              {
                                setState(() {
                                  circular = false;
                                });
                                Fluttertoast.showToast(
                                    msg: pass['message'],
                                    toastLength: Toast.LENGTH_LONG);
                              }
                            }
                          } else {
                            setState(() {
                              circular = false;
                            });
                          }
                        },
                        padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                        color: PRIMARY_COLOR,
                        child: circular
                            ? SizedBox(
                                child: CircularProgressIndicator(
                                  backgroundColor: PRIMARY_COLOR,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                                width: 20,
                                height: 20)
                            : Text(
                                'Change Pin',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                      )),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
