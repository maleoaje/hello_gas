/*
This is edit phone number verification page

include file in reuseable/global_function.dart to call function from GlobalFunction

install plugin in pubspec.yaml
- pin_code_fields => to create input field for code verification (https://pub.dev/packages/pin_code_fields)

Don't forget to add all images and sound used in this pages at the pubspec.yaml
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hello_gas/config/constants.dart';
import 'package:hello_gas/config/global_style.dart';
import 'package:hello_gas/ui/reuseable/app_localizations.dart';
import 'package:hello_gas/ui/reuseable/global_function.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class EditPhoneNumberVerificationPage extends StatefulWidget {
  final String verificationType;
  final String phoneNumber;

  const EditPhoneNumberVerificationPage({Key? key, this.verificationType = 'sms', this.phoneNumber = ''}) : super(key: key);

  @override
  _EditPhoneNumberVerificationPageState createState() => _EditPhoneNumberVerificationPageState();
}

class _EditPhoneNumberVerificationPageState extends State<EditPhoneNumberVerificationPage> {
  // initialize global function
  final _globalFunction = GlobalFunction();
  bool _isButtonDisabled = true;
  String _verificationCode = '';

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
        body: ListView(
          padding: EdgeInsets.fromLTRB(30, 120, 30, 30),
          children: <Widget>[
            Center(
                child: (widget.verificationType == 'wa')
                    ? Image.asset('assets/images/whatsapp.png', height: 50)
                    : Icon(Icons.phone_android, color: PRIMARY_COLOR, size: 50)),
            SizedBox(height: 20),
            Center(
                child: Text(
                  AppLocalizations.of(context)!.translate('enter_verification_code')!,
                  style: GlobalStyle.chooseVerificationTitle,
                )),
            SizedBox(
              height: 20,
            ),
            Container(
              width: MediaQuery.of(context).size.width / 1.5,
              child: Text(
                AppLocalizations.of(context)!.translate('enter_verification_code_message2')!+((widget.verificationType=='wa')?AppLocalizations.of(context)!.translate('whatsapp')!:AppLocalizations.of(context)!.translate('sms')!)+' '+AppLocalizations.of(context)!.translate('to')!+' '+widget.phoneNumber,
                style: GlobalStyle.chooseVerificationMessage,
                textAlign: TextAlign.center,
              ),
            ),
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
                obscureText: false,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                    shape: PinCodeFieldShape.underline,
                    fieldHeight: 50,
                    fieldWidth: 40,
                    inactiveColor: SOFT_GREY,
                    activeColor: PRIMARY_COLOR,
                    selectedColor: PRIMARY_COLOR
                ),
                animationDuration: Duration(milliseconds: 300),
                backgroundColor: Colors.transparent,
                onChanged: (value) {
                  setState(() {
                    if(value.length==4){
                      _isButtonDisabled = false;
                    } else {
                      _isButtonDisabled = true;
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
                              (Set<MaterialState> states) => states.contains(MaterialState.disabled) ? Colors.grey[300]! : _isButtonDisabled?Colors.grey[300]!:PRIMARY_COLOR,
                        ),
                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                        shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.0),
                            )
                        ),
                      ),
                      onPressed: () {
                        if(!_isButtonDisabled){
                          print(_verificationCode);
                          _globalFunction.startLoading(context, AppLocalizations.of(context)!.translate('edit_phone_number_success')!, 2);
                          FocusScope.of(context).unfocus();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          AppLocalizations.of(context)!.translate('verify')!,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _isButtonDisabled?Colors.grey[600]:Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      )
                  )
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Center(
              child: Wrap(
                children: [
                  Text(
                    AppLocalizations.of(context)!.translate('not_receive_code')!,
                    style: GlobalStyle.notReceiveCode,
                  ),
                  GestureDetector(
                    onTap: (){
                      _globalFunction.resendVerification(context, AppLocalizations.of(context)!.translate('resend_verification_message_phone')!);
                    },
                    child: Text(
                      AppLocalizations.of(context)!.translate('resend')!,
                      style: GlobalStyle.resendVerification,
                    ),
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
