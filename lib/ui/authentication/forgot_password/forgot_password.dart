/*
This is forgot password page

install plugin in pubspec.yaml
- fluttertoast => to show toast (https://pub.dev/packages/fluttertoast)

Don't forget to add all images and sound used in this pages at the pubspec.yaml
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hello_gas/config/constants.dart';
import 'package:hello_gas/config/global_style.dart';
import 'package:hello_gas/network/network_handler.dart';
import 'package:hello_gas/ui/authentication/signin/signin_email.dart';
import 'package:hello_gas/ui/reuseable/app_localizations.dart';
import 'package:hello_gas/ui/reuseable/global_function.dart';

class ForgotPasswordPage extends StatefulWidget {
  final String email;

  const ForgotPasswordPage({Key? key, this.email = ''}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController _etEmail = TextEditingController();
  bool circular = false;
  NetworkHandler networkHandler = NetworkHandler();
  String errorText = '';
  bool validate = false;
  final storage = new FlutterSecureStorage();
  final _globalFunction = GlobalFunction();
  String _validate = '';
  bool _buttonDisabled = true;

  @override
  void initState() {
    _etEmail = TextEditingController(text: widget.email);

    super.initState();
  }

  @override
  void dispose() {
    _etEmail.dispose();
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
        padding: EdgeInsets.fromLTRB(30, 40, 30, 30),
        children: <Widget>[
          // Center(child: Image.asset('assets/images/logo_light.png', height: 50)),
          Text(
            'Forgot Password',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            enabled: true,
            keyboardType: TextInputType.emailAddress,
            controller: _etEmail,
            style: TextStyle(color: Colors.white),
            onChanged: (textValue) {
              setState(() {
                if (_globalFunction.validateEmail(textValue)) {
                  _buttonDisabled = false;
                  _validate = 'email';
                } else {
                  _buttonDisabled = true;
                }
              });
            },
            decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: PRIMARY_COLOR, width: 2.0)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue),
                ),
                labelText: AppLocalizations.of(context)!.translate('email')!,
                labelStyle: TextStyle(color: Colors.lightBlue)),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            AppLocalizations.of(context)!.translate('reset_password_message')!,
            style: GlobalStyle.resetPasswordNotes,
          ),
          SizedBox(
            height: 40,
          ),
          Container(
            child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) => PRIMARY_COLOR,
                  ),
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0),
                  )),
                ),
                onPressed: () async {
                  if (!_buttonDisabled) {
                    if (_validate == 'email') {
                      setState(() {
                        circular = true;
                      });
                      var response = await networkHandler.get(
                          '/api/Usermanagement/Restpassword?Email=' +
                              _etEmail.text);
                      if (response['message'] ==
                          'Reset password Successfully check your Mail') {
                        Fluttertoast.showToast(
                            msg: 'Successful, new password sent to: ' +
                                _etEmail.text,
                            toastLength: Toast.LENGTH_LONG);
                        setState(() {
                          circular = false;

                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => SigninEmailPage()),
                              (Route<dynamic> route) => false);
                        });
                      } else {
                        setState(() {
                          circular = false;
                        });
                        Fluttertoast.showToast(
                            msg: response['message'],
                            toastLength: Toast.LENGTH_LONG);
                      }
                      Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text('Network Error')));
                    }
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
                          AppLocalizations.of(context)!
                              .translate('reset_password')!,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                )),
          ),
          SizedBox(
            height: 50,
          ),
          // create sign in link
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GlobalStyle.iconBack,
                  Text(
                    AppLocalizations.of(context)!.translate('back_to_login')!,
                    style: GlobalStyle.back,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    ));
  }
}
