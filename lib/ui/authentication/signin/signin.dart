/*
This is signin page

include file in reuseable/global_function.dart to call function from GlobalFunction

install plugin in pubspec.yaml
- fluttertoast => to show toast (https://pub.dev/packages/fluttertoast)

Don't forget to add all images and sound used in this pages at the pubspec.yaml
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hello_gas/config/constants.dart';
import 'package:hello_gas/config/global_style.dart';
import 'package:hello_gas/ui/bottom_navigation_bar.dart';
import 'package:hello_gas/ui/authentication/signin/signin_email.dart';
import 'package:hello_gas/ui/authentication/signin/signin_phone_number_choose_verification.dart';
import 'package:hello_gas/ui/authentication/signup/signup.dart';
import 'package:hello_gas/ui/reuseable/app_localizations.dart';
import 'package:hello_gas/ui/reuseable/global_function.dart';

class SigninPage extends StatefulWidget {
  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage>{
  // initialize global function
  final _globalFunction = GlobalFunction();

  bool _buttonDisabled = true;
  String _validate = '';

  TextEditingController _etEmailPhone = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _etEmailPhone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
          padding: EdgeInsets.fromLTRB(30, 120, 30, 30),
          children: <Widget>[
            Center(
                child:
                Image.asset('assets/images/logo_light.png', height: 50)),
            SizedBox(
              height: 80,
            ),
            Text(AppLocalizations.of(context)!.translate('signin')!, style: GlobalStyle.authTitle),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: _etEmailPhone,
              style: TextStyle(color: CHARCOAL),
              onChanged: (textValue) {
                setState(() {
                  if(_globalFunction.validateMobileNumber(textValue)){
                    _buttonDisabled = false;
                    _validate = 'phonenumber';
                  } else if(_globalFunction.validateEmail(textValue)){
                    _buttonDisabled = false;
                    _validate = 'email';
                  } else {
                    _buttonDisabled = true;
                  }
                });
              },
              decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                      borderSide:
                      BorderSide(color: PRIMARY_COLOR, width: 2.0)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFCCCCCC)),
                  ),
                  labelText: AppLocalizations.of(context)!.translate('email_phone_number')!,
                  labelStyle: TextStyle(color: BLACK_GREY)),
            ),
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.translate('example')!+' : ', style: GlobalStyle.authNotes),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('0811888999', style: GlobalStyle.authNotes),
                      Text('example@domain.com', style: GlobalStyle.authNotes)
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Container(
              child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) => states.contains(MaterialState.disabled) ? Colors.grey[300]! : _buttonDisabled?Colors.grey[300]!:PRIMARY_COLOR,
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.0),
                        )
                    ),
                  ),
                  onPressed: () {
                    if(!_buttonDisabled){
                      if(_validate == 'email'){
                        Navigator.of(context).push(PageRouteBuilder(pageBuilder: (_,__,___)=> SigninEmailPage(email: _etEmailPhone.text)));
                        FocusScope.of(context).unfocus();
                      } else if(_validate == 'phonenumber') {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SigninPhoneNumberChooseVerificationPage(phoneNumber: _etEmailPhone.text)));
                        FocusScope.of(context).unfocus();
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Text(
                      AppLocalizations.of(context)!.translate('next')!,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _buttonDisabled?Colors.grey[600]:Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  )
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Center(
              child: Text(
                AppLocalizations.of(context)!.translate('or_signin_with')!,
                style: GlobalStyle.authSignWith,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(
                    onTap: (){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigationBarPage()));
                      Fluttertoast.showToast(
                          msg: AppLocalizations.of(context)!.translate('signin_google')!,
                          toastLength: Toast.LENGTH_LONG);
                    },
                    child: Image(
                        image: AssetImage("assets/images/google.png"), width: 40,),
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigationBarPage()));
                      Fluttertoast.showToast(
                          msg: AppLocalizations.of(context)!.translate('signin_facebook')!,
                          toastLength: Toast.LENGTH_LONG);
                    },
                    child: Image(
                      image: AssetImage("assets/images/facebook.png"), width: 40,),
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigationBarPage()));
                      Fluttertoast.showToast(
                          msg: AppLocalizations.of(context)!.translate('signin_twitter')!,
                          toastLength: Toast.LENGTH_LONG);
                    },
                    child: Image(
                      image: AssetImage("assets/images/twitter.png"), width: 40,),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPage()));
                  FocusScope.of(context).unfocus();
                },
                child: Wrap(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('no_account_yet')!,
                      style: GlobalStyle.authBottom1,
                    ),
                    Text(
                      AppLocalizations.of(context)!.translate('create_one')!,
                      style: GlobalStyle.authBottom2,
                    )
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
