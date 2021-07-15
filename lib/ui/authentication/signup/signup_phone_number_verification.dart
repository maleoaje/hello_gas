/*
This is signup phone number verification page

include file in reuseable/global_function.dart to call function from GlobalFunction

install plugin in pubspec.yaml
- pin_code_fields => to create input field for code verification (https://pub.dev/packages/pin_code_fields)

Don't forget to add all images and sound used in this pages at the pubspec.yaml
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hello_gas/config/constants.dart';
import 'package:hello_gas/config/global_style.dart';
import 'package:hello_gas/network/network_handler.dart';
import 'package:hello_gas/ui/authentication/signin/signin_email.dart';
import 'package:hello_gas/ui/authentication/signup/signup_phone_number.dart';
import 'package:hello_gas/ui/reuseable/app_localizations.dart';
import 'package:hello_gas/ui/reuseable/global_function.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class SignupPhoneNumberVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String email;
  final String firstname;

  const SignupPhoneNumberVerificationPage(
      {Key? key, this.phoneNumber = '', this.email = '', this.firstname = ''})
      : super(key: key);
  @override
  _SignupPhoneNumberVerificationPageState createState() =>
      _SignupPhoneNumberVerificationPageState();
}

class _SignupPhoneNumberVerificationPageState
    extends State<SignupPhoneNumberVerificationPage> {
  // initialize global function
  final _globalFunction = GlobalFunction();
  bool _buttonDisabled = true;
  String _verificationCode = '';
  String errorText = '';
  bool circular = false;
  NetworkHandler networkHandler = NetworkHandler();

  @override
  void initState() {
    super.initState();
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
          SizedBox(height: 20),
          Center(
              child: Text(
                  AppLocalizations.of(context)!
                      .translate('enter_verification_code')!,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white))),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 40,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: PinCodeTextField(
              autoFocus: true,
              appContext: context,
              keyboardType: TextInputType.number,
              length: 6,
              showCursor: false,
              obscureText: false,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
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
                  if (value.length == 6) {
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
          Center(
              child: Text(
            '$errorText',
            style: TextStyle(color: Colors.red, fontSize: 12),
          )),
          SizedBox(
            height: 10,
          ),
          Container(
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
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
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
                      "email": widget.email,
                      "activationcode": _verificationCode,
                    };
                    print(data);
                    var response = await networkHandler.post(
                        '/api/Usermanagement/Validate_activationcode', data);
                    Map<String, dynamic> output = json.decode(response.body);
                    print(output);
                    if (output['code'] == '00') {
                      print(output);
                      setState(() {
                        circular = false;
                      });
                      Fluttertoast.showToast(
                          msg: output['message'],
                          toastLength: Toast.LENGTH_LONG);

                      FocusScope.of(context).unfocus();
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => SigninEmailPage()),
                          (Route<dynamic> route) => false);
                      FocusScope.of(context).unfocus();
                    } else if (response.statusCode == 400) {
                      setState(() {
                        circular = false;
                      });
                    } else if (output['code'] == '02') {
                      setState(() {
                        circular = false;
                        errorText = output['message'];
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
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                              width: 20,
                              height: 20),
                        )
                      : Text(
                          AppLocalizations.of(context)!.translate('verify')!,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _buttonDisabled
                                  ? Colors.grey[600]
                                  : Colors.white),
                          textAlign: TextAlign.center,
                        ),
                )),
          ),
          SizedBox(
            height: 40,
          ),
        ],
      ),
    ));
  }
}
