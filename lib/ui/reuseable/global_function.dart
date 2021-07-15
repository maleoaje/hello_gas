import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hello_gas/config/constants.dart';
import 'package:hello_gas/ui/reuseable/app_localizations.dart';
import 'package:intl/intl.dart';

class GlobalFunction{
  bool validateMobileNumber(String value) {
    String patttern = r'(^(?:[+0]9)?[0-9]{10,15}$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length < 8) {
      return false;
    } else if (!regExp.hasMatch(value)) {
      return false;
    } else {
      return true;
    }
  }

  bool validateEmail(String value) {
    String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return false;
    } else {
      return true;
    }
  }

  String removeDecimalZeroFormat(double v) {
    NumberFormat formatter = NumberFormat();
    formatter.minimumFractionDigits = 0;
    formatter.maximumFractionDigits = 2;
    return formatter.format(v);
  }

  void resendVerification(BuildContext context, String message){
    _showProgressDialog(context);
    Timer(Duration(seconds: 2), () {
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG);
    });
  }

  Future _showProgressDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }

  // dummy loading
  void startLoading(context, String textMessage, int backToPreviousPageStack){
    _showProgressDialog(context);
    Timer(Duration(seconds: 2), () {
      Navigator.pop(context);
      _buildShowDialog(context, textMessage, backToPreviousPageStack);
    });
  }

  Future _buildShowDialog(BuildContext context, String textMessage, int backToPreviousPageStack) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
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
                      style: TextStyle(fontSize: 14, color: BLACK_GREY),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) => PRIMARY_COLOR,
                            ),
                            overlayColor: MaterialStateProperty.all(Colors.transparent),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                )
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);

                            if(backToPreviousPageStack>0){
                              FocusScope.of(context).unfocus(); // hide keyboard when press button
                              for(int i=1;i<=backToPreviousPageStack;i++){
                                Navigator.pop(context);
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Text(
                              AppLocalizations.of(context)!.translate('ok')!.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          )
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
  // end dummy loading

  String formatTime(int timeNum) {
    return timeNum < 10 ? "0" + timeNum.toString() : timeNum.toString();
  }

  void showToast({message, type}) {
    if(type == null){
      Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_LONG);
    } else if(type == 'success'){
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 13.0);
    } else {
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 13.0);
    }
  }
}