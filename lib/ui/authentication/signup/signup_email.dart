/*
This is signup with email page

Don't forget to add all images and sound used in this pages at the pubspec.yaml
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hello_gas/config/constants.dart';
import 'package:hello_gas/config/global_style.dart';
import 'package:hello_gas/network/network_handler.dart';
import 'package:hello_gas/ui/authentication/signin/signin_email.dart';
import 'package:hello_gas/ui/authentication/signup/signup_phone_number_verification.dart';
import 'package:hello_gas/ui/authentication/signin/signin.dart';
import 'package:hello_gas/ui/reuseable/app_localizations.dart';

class SignupEmailPage extends StatefulWidget {
  final String email;

  const SignupEmailPage({Key? key, this.email = ''}) : super(key: key);

  @override
  _SignupEmailPageState createState() => _SignupEmailPageState();
}

class _SignupEmailPageState extends State<SignupEmailPage> {
  TextEditingController _etEmail = TextEditingController();
  TextEditingController _etFirstName = TextEditingController();
  TextEditingController _etLastName = TextEditingController();
  TextEditingController _etphone = TextEditingController();
  TextEditingController _etPass = TextEditingController();
  bool _obscureText = true;
  bool circular = false;
  String errorText = '';
  bool validate = true;
  final _globalkey = GlobalKey<FormState>();
  NetworkHandler networkHandler = NetworkHandler();
  IconData _iconVisible = Icons.visibility_off;

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
    _etFirstName.dispose();
    _etLastName.dispose();
    _etphone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/backg.png'), fit: BoxFit.cover)),
      child: WillPopScope(
        onWillPop: () {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => SigninPage()),
              (Route<dynamic> route) => false);
          FocusScope.of(context).unfocus();
          return Future.value(true);
        },
        child: Form(
          key: _globalkey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(70, 20, 70, 30),
            children: <Widget>[
              SizedBox(
                height: 70,
              ),
              Center(
                child: Text(AppLocalizations.of(context)!.translate('signup')!,
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
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) return "Field can't be empty";
                  return null;
                },
                keyboardType: TextInputType.text,
                controller: _etFirstName,
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
                  labelText: 'First Name',
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) return "Field can't be empty";
                  return null;
                },
                keyboardType: TextInputType.text,
                controller: _etLastName,
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
                  labelText: 'Last Name',
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) return "Field can't be empty";
                  if (value.length != 11) return "Check phone number";
                  return null;
                },
                keyboardType: TextInputType.phone,
                controller: _etphone,
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
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: Colors.white),
                ),
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
                keyboardType: TextInputType.text,
                obscureText: _obscureText,
                controller: _etPass,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.pinkAccent, width: 2.0)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightBlue),
                  ),
                  labelText:
                      AppLocalizations.of(context)!.translate('password')!,
                  labelStyle: TextStyle(color: Colors.white),
                  suffixIcon: IconButton(
                      icon:
                          Icon(_iconVisible, color: Colors.grey[400], size: 20),
                      onPressed: () {
                        _toggleObscureText();
                      }),
                ),
              ),
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
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80.0),
                      )),
                    ),
                    onPressed: () async {
                      setState(() {
                        circular = true;
                      });
                      /*  Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => BottomNavigationBarPage()),
                          (Route<dynamic> route) => false);*/

                      if (_globalkey.currentState!.validate()) {
                        Map<String, String> data = {
                          "firstName": _etFirstName.text,
                          "lastName": _etLastName.text,
                          "email": _etEmail.text,
                          "phoneNumber": _etphone.text,
                          "password": _etPass.text,
                        };
                        print(data);
                        var response = await networkHandler.post(
                            '/api/Usermanagement/signup', data);
                        Map<String, dynamic> output =
                            json.decode(response.body);
                        print(output);
                        if (output['code'] == '00') {
                          print(output);
                          setState(() {
                            circular = false;
                          });
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SignupPhoneNumberVerificationPage(
                                        email: _etEmail.text,
                                        firstname: _etFirstName.text,
                                        phoneNumber: _etphone.text,
                                      )),
                              (Route<dynamic> route) => false);
                          FocusScope.of(context).unfocus();
                        } else if (response.statusCode == 400) {
                          setState(() {
                            circular = false;
                            validate = true;
                            errorText =
                                'Ensure all required fields are filled correctly';
                          });
                        } else if (output['code'] == '02') {
                          setState(() {
                            validate = false;
                            circular = false;
                            errorText = output['message'];
                          });
                          FocusScope.of(context).unfocus();
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
                              AppLocalizations.of(context)!
                                  .translate('register')!,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                    )),
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => SigninEmailPage()),
                        (Route<dynamic> route) => false);
                    FocusScope.of(context).unfocus();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GlobalStyle.iconBack,
                      Text(
                        AppLocalizations.of(context)!
                            .translate('back_to_login')!,
                        style: TextStyle(
                            color: Colors.pinkAccent,
                            fontWeight: FontWeight.w700),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              //Center(child: Image.asset('assets/images/logo_light.png',  height: 50)),
              Center(child: Image.asset('assets/images/logo.png', height: 80)),
            ],
          ),
        ),
      ),
    ));
  }
}
