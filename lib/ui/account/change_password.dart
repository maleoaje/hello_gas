/*
This is change password page

include file in reuseable/global_function.dart to call function from GlobalFunction
include file in reuseable/global_widget.dart to call function from GlobalWidget
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hello_gas/config/constants.dart';
import 'package:hello_gas/config/global_style.dart';
import 'package:hello_gas/network/network_handler.dart';
import 'package:hello_gas/ui/reuseable/app_localizations.dart';
import 'package:hello_gas/ui/reuseable/global_function.dart';
import 'package:hello_gas/ui/reuseable/global_widget.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextEditingController _etCurrentPass = TextEditingController();
  TextEditingController _etNewPass = TextEditingController();
  TextEditingController _etConfirmPass = TextEditingController();
  // initialize global function
  final _globalFunction = GlobalFunction();
  final _globalWidget = GlobalWidget();
  String email = '';

  final FocusNode _oldPasswordFocus = FocusNode();

  bool circularA = true;
  bool _obscureTextNewPass = true;
  bool _obscureTextRetypePass = true;
  IconData _iconVisibleNewPass = Icons.visibility_off;
  IconData _iconVisibleRetypePass = Icons.visibility_off;
  FlutterSecureStorage storage = FlutterSecureStorage();
  NetworkHandler networkHandler = NetworkHandler();
  final _globalkey = GlobalKey<FormState>();

  String errorText = '';
  bool validate = false;
  bool circular = false;

  void _toggleNewPass() {
    setState(() {
      _obscureTextNewPass = !_obscureTextNewPass;
      if (_obscureTextNewPass == true) {
        _iconVisibleNewPass = Icons.visibility_off;
      } else {
        _iconVisibleNewPass = Icons.visibility;
      }
    });
  }

  void _toggleRetypePass() {
    setState(() {
      _obscureTextRetypePass = !_obscureTextRetypePass;
      if (_obscureTextRetypePass == true) {
        _iconVisibleRetypePass = Icons.visibility_off;
      } else {
        _iconVisibleRetypePass = Icons.visibility;
      }
    });
  }

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
    _oldPasswordFocus.dispose();
    super.dispose();
  }

  void _showPopupInsertPassword() {
    // set up the buttons
    Widget cancelButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(AppLocalizations.of(context)!.translate('cancel')!,
            style: TextStyle(color: SOFT_BLUE)));
    Widget continueButton = TextButton(
        onPressed: () async {
          setState(() {
            circular = true;
          });

          String email = (await storage.read(key: 'email'))!;
          print(email);
          Map<String, String> passChange = {
            "email": email,
            "current_Password": _etCurrentPass.text,
            "new_Password": _etNewPass.text,
            "confirm_Password": _etConfirmPass.text
          };
          print(passChange);
          var response = await networkHandler.post(
              '/api/Usermanagement/Changepassword', passChange);
          Map<String, dynamic> pass = json.decode(response.body);
          print(pass);
          if (pass['code'] == '00') {
            Navigator.pop(context);
            _globalFunction.startLoading(
                context,
                AppLocalizations.of(context)!
                    .translate('change_password_success')!,
                1);
            setState(() {
              circular = false;
            });
          } else if (pass['code'] == '02') {
            {
              setState(() {
                circular = false;
              });
              Fluttertoast.showToast(
                  msg: pass['message'], toastLength: Toast.LENGTH_LONG);
            }
          }

          /*
          Navigator.pop(context);
          _globalFunction.startLoading(
              context,
              AppLocalizations.of(context)!
                  .translate('change_password_success')!,
              1);*/
        },
        child: Text(AppLocalizations.of(context)!.translate('submit')!,
            style: TextStyle(color: SOFT_BLUE)));

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Text(
        AppLocalizations.of(context)!.translate('verify')!,
        style: TextStyle(fontSize: 18),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AppLocalizations.of(context)!.translate('enter_old_password')!,
              style: TextStyle(fontSize: 13, color: BLACK_GREY)),
          TextFormField(
            validator: (value) {
              if (value!.isEmpty) return "Enter Old Password";
              if (value.length < 8) return "Password too short";
              return null;
            },
            obscureText: true,
            controller: _etCurrentPass,
            focusNode: _oldPasswordFocus,
            style: TextStyle(color: CHARCOAL),
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: PRIMARY_COLOR, width: 2.0)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFCCCCCC)),
              ),
            ),
          ),
        ],
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        FocusScope.of(context).requestFocus(_oldPasswordFocus);
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: GlobalStyle.appBarIconThemeColor,
          ),
          elevation: GlobalStyle.appBarElevation,
          title: Text(
            AppLocalizations.of(context)!.translate('change_password')!,
            style: GlobalStyle.appBarTitle,
          ),
          backgroundColor: GlobalStyle.appBarBackgroundColor,
          brightness: GlobalStyle.appBarBrightness,
          bottom: _globalWidget.bottomAppBar(),
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
          child: ListView(
            padding: EdgeInsets.all(30),
            children: [
              SizedBox(
                height: 20,
              ),
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) return "Enter New Password";
                  if (value.length < 8) return "Password too short";
                  return null;
                },
                obscureText: _obscureTextNewPass,
                style: TextStyle(color: CHARCOAL),
                controller: _etNewPass,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: PRIMARY_COLOR, width: 2.0)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFCCCCCC)),
                  ),
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: BLACK_GREY),
                  suffixIcon: IconButton(
                      icon: Icon(_iconVisibleNewPass,
                          color: Colors.grey[400], size: 20),
                      onPressed: () {
                        _toggleNewPass();
                      }),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                  'Must contain at least one uppercase letter and a special character',
                  style: GlobalStyle.authNotes),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                obscureText: _obscureTextRetypePass,
                style: TextStyle(color: CHARCOAL),
                controller: _etConfirmPass,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: PRIMARY_COLOR, width: 2.0)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFCCCCCC)),
                  ),
                  labelText: AppLocalizations.of(context)!
                      .translate('retype_password')!,
                  labelStyle: TextStyle(color: BLACK_GREY),
                  suffixIcon: IconButton(
                      icon: Icon(_iconVisibleRetypePass,
                          color: Colors.grey[400], size: 20),
                      onPressed: () {
                        _toggleRetypePass();
                      }),
                ),
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
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.0),
                      )),
                    ),
                    onPressed: () {
                      _showPopupInsertPassword();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Text(
                        AppLocalizations.of(context)!.translate('save')!,
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
        ));
  }
}
