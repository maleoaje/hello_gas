/*
This is signin with email page

install plugin in pubspec.yaml
- fluttertoast => to show toast (https://pub.dev/packages/fluttertoast)

Don't forget to add all images and sound used in this pages at the pubspec.yaml
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hello_gas/config/constants.dart';
import 'package:hello_gas/config/global_style.dart';
import 'package:hello_gas/network/network_handler.dart';
import 'package:hello_gas/ui/authentication/signin/signin_phone_number_verification.dart';
import 'package:hello_gas/ui/authentication/signup/signup_email.dart';
import 'package:hello_gas/ui/bottom_navigation_bar.dart';
import 'package:hello_gas/ui/authentication/forgot_password/forgot_password.dart';
import 'package:hello_gas/ui/reuseable/app_localizations.dart';

class SigninEmailPage extends StatefulWidget {
  final String email;

  const SigninEmailPage({Key? key, this.email = ''}) : super(key: key);

  @override
  _SigninEmailPageState createState() => _SigninEmailPageState();
}

class _SigninEmailPageState extends State<SigninEmailPage> {
  TextEditingController _etEmail = TextEditingController();
  TextEditingController _etPass = TextEditingController();
  bool _obscureText = true;
  IconData _iconVisible = Icons.visibility_off;
  bool circular = false;
  String errorText = '';
  bool validate = true;
  NetworkHandler networkHandler = NetworkHandler();
  final storage = new FlutterSecureStorage();
  final _globalkey = GlobalKey<FormState>();

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
      if (_obscureText == true) {
        _iconVisible = Icons.visibility_off;
      } else {
        _iconVisible = Icons.visibility;
      }
    });
  }

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
      child: Form(
        key: _globalkey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(70, 10, 70, 30),
          children: <Widget>[
            SizedBox(
              height: 80,
            ),
            Center(
              child: Text(AppLocalizations.of(context)!.translate('signin')!,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              validator: (value) {
                if (value!.isEmpty) return "Enter Email";
                if (!value.contains('@')) return "Email is invalid";
                return null;
              },
              enabled: true,
              keyboardType: TextInputType.emailAddress,
              controller: _etEmail,
              style: TextStyle(color: Colors.white),
              onChanged: (textValue) {
                setState(() {});
              },
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.pinkAccent, width: 2.0)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightBlue),
                  ),
                  labelText: AppLocalizations.of(context)!.translate('email')!,
                  labelStyle: TextStyle(color: Colors.white),
                  fillColor: Colors.white),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              validator: (value) {
                if (value!.isEmpty) return "Enter Password";
                if (value.length < 8) return "Password too short";
                return null;
              },
              controller: _etPass,
              obscureText: _obscureText,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.pinkAccent, width: 2.0)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue),
                ),
                labelText: AppLocalizations.of(context)!.translate('password')!,
                labelStyle: TextStyle(color: Colors.white),
                suffixIcon: IconButton(
                    icon: Icon(_iconVisible, color: Colors.grey[400], size: 20),
                    onPressed: () {
                      _toggleObscureText();
                    }),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Align(
                alignment: Alignment.centerRight,
                child: Container(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ForgotPasswordPage(email: widget.email)));
                      FocusScope.of(context).unfocus();
                    },
                    child: Text(
                      AppLocalizations.of(context)!
                          .translate('forgot_password')!,
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                )),
            SizedBox(
              height: 40,
            ),
            Center(
                child: Text(
              '$errorText',
              style: TextStyle(color: Colors.white, fontSize: 12),
            )),
            SizedBox(
              height: 10,
            ),
            Container(
              child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) => Colors.pinkAccent,
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80.0),
                    )),
                  ),
                  onPressed: () async {
                    /*Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => BottomNavigationBarPage()),
                        (Route<dynamic> route) => false);*/
                    setState(() {
                      circular = true;
                    });
                    if (_globalkey.currentState!.validate()) {
                      Map<String, String> data = {
                        "password": _etPass.text,
                        "phonemail": _etEmail.text,
                      };
                      print(data);
                      var response = await networkHandler.post(
                          '/api/Usermanagement/Login', data);
                      Map<String, dynamic> output = json.decode(response.body);
                      if (response.statusCode == 400) {
                        print(output);
                        setState(() {
                          validate = false;
                          circular = false;
                          errorText = "Email and Password are required";
                        });
                      } else if (output['code'] == '00') {
                        print(output);
                        await storage.write(
                            key: 'phoneNumber',
                            value: output['data']['phoneNumber']);
                        await storage.write(
                            key: 'firstName',
                            value: output['data']['firstName']);
                        await storage.write(
                            key: 'lastName', value: output['data']['lastName']);
                        await storage.write(
                            key: 'email', value: output['data']['email']);
                        await storage.write(
                            key: 'walletId', value: output['data']['walletId']);

                        if (output['data']['transactionPinSetupSatus'] ==
                            true) {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      BottomNavigationBarPage()),
                              (Route<dynamic> route) => false);
                        } else if (output['data']['transactionPinSetupSatus'] ==
                            false) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SigninPhoneNumberVerificationPage()));
                        }
                      }
                      if (output['code'] != '00') {
                        setState(() {
                          validate = true;
                          circular = false;
                          errorText = output['message'];
                        });
                      }
                    } else {
                      setState(() {
                        validate = false;
                        circular = false;
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
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
                            AppLocalizations.of(context)!.translate('login')!,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                  )),
            ),
            SizedBox(
              height: 40,
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SignupEmailPage()));
                  FocusScope.of(context).unfocus();
                },
                child: Wrap(
                  children: [
                    Text(
                      AppLocalizations.of(context)!
                          .translate('no_account_yet')!,
                      style: GlobalStyle.authBottom1,
                    ),
                    Text(
                      AppLocalizations.of(context)!.translate('create_one')!,
                      style: TextStyle(fontSize: 13, color: Color(0xfffce4ec)),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Center(child: Image.asset('assets/images/logo.png', height: 80)),
          ],
        ),
      ),
    ));
  }
}
