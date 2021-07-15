/*
This is signin phone number verification page

include file in reuseable/global_function.dart to call function from GlobalFunction

install plugin in pubspec.yaml
- pin_code_fields => to create input field for code verification (https://pub.dev/packages/pin_code_fields)

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
import 'package:hello_gas/ui/bottom_navigation_bar.dart';
import 'package:hello_gas/ui/reuseable/global_function.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class SigninPhoneNumberVerificationPage extends StatefulWidget {
  final String verificationType;
  final String phoneNumber;

  const SigninPhoneNumberVerificationPage(
      {Key? key, this.verificationType = 'sms', this.phoneNumber = ''})
      : super(key: key);

  @override
  _SigninPhoneNumberVerificationPageState createState() =>
      _SigninPhoneNumberVerificationPageState();
}

class _SigninPhoneNumberVerificationPageState
    extends State<SigninPhoneNumberVerificationPage> {
  // initialize global function
  bool _buttonDisabled = true;
  String _verificationCode = '';
  NetworkHandler networkHandler = NetworkHandler();
  final storage = new FlutterSecureStorage();
  bool circular = false;
  String walletID = ' ';
  String email = ' ';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    String walletId = (await storage.read(key: 'walletId'))!;
    String emaila = (await storage.read(key: 'email'))!;
    setState(() {
      walletID = walletId;

      email = emaila;
      circular = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/backg.png'), fit: BoxFit.cover)),
      child: ListView(
        padding: EdgeInsets.fromLTRB(30, 120, 30, 30),
        children: <Widget>[
          Center(child: Icon(Icons.lock, color: PRIMARY_COLOR, size: 50)),
          SizedBox(height: 20),
          Center(
              child: Text(
            'Setup Transaction Pin',
            style: GlobalStyle.chooseVerificationTitle,
          )),
          SizedBox(
            height: 40,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 50),
            child: PinCodeTextField(
              autoFocus: true,
              appContext: context,
              keyboardType: TextInputType.number,
              length: 4,
              showCursor: false,
              obscureText: true,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                  activeFillColor: Colors.white,
                  shape: PinCodeFieldShape.underline,
                  fieldHeight: 50,
                  fieldWidth: 40,
                  inactiveColor: SOFT_GREY,
                  activeColor: PRIMARY_COLOR,
                  selectedColor: PRIMARY_COLOR),
              animationDuration: Duration(milliseconds: 300),
              backgroundColor: Colors.transparent,
              onChanged: (value) {
                setState(() {
                  if (value.length == 4) {
                    _buttonDisabled = false;
                  } else {
                    _buttonDisabled = true;
                  }
                  _verificationCode = value;
                });
              },
              beforeTextPaste: (text) {
                return false;
              },
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Container(
            child: SizedBox(
                width: double.maxFinite,
                child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) =>
                            states.contains(MaterialState.disabled)
                                ? Colors.grey[300]!
                                : _buttonDisabled
                                    ? Colors.grey[300]!
                                    : PRIMARY_COLOR,
                      ),
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.0),
                      )),
                    ),
                    onPressed: () async {
                      if (!_buttonDisabled) {
                        print(_verificationCode);
                        setState(() {
                          circular = true;
                        });
                        Map<String, String> data = {
                          "email": email,
                          "new_TransactionPin": _verificationCode,
                        };
                        print(data);
                        var response = await networkHandler.post(
                            '/api/Usermanagement/SetupTransactionpin', data);
                        Map<String, dynamic> output =
                            json.decode(response.body);
                        print(output);
                        if (output['code'] == '00') {
                          print(output);
                          setState(() {
                            circular = false;
                          });
                          Fluttertoast.showToast(
                              msg: output['message'],
                              toastLength: Toast.LENGTH_LONG);
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      BottomNavigationBarPage()),
                              (Route<dynamic> route) => false);
                          FocusScope.of(context).unfocus();
                        } else if (response.statusCode == 400) {
                          setState(() {
                            circular = false;
                          });
                        } else if (output['code'] == '02') {
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: circular
                          ? Center(
                              child: SizedBox(
                                  child: CircularProgressIndicator(
                                    backgroundColor: PRIMARY_COLOR,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                  width: 20,
                                  height: 20),
                            )
                          : Text(
                              'Setup Pin',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _buttonDisabled
                                      ? Colors.grey[600]
                                      : Colors.white),
                              textAlign: TextAlign.center,
                            ),
                    ))),
          ),
        ],
      ),
    ));
  }
}
