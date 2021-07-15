/*
This is account information page

include file in reuseable/global_function.dart to call function from GlobalFunction
include file in reuseable/global_widget.dart to call function from GlobalWidget
include file in reuseable/cache_image_network.dart to use cache image network
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hello_gas/config/constants.dart';
import 'package:hello_gas/config/global_style.dart';
import 'package:hello_gas/network/network_handler.dart';
import 'package:hello_gas/ui/account/account_information/edit_email.dart';
import 'package:hello_gas/ui/account/account_information/edit_name.dart';
import 'package:hello_gas/ui/account/account_information/edit_phone_number.dart';
import 'package:hello_gas/ui/account/account_information/edit_profile_picture.dart';
import 'package:hello_gas/ui/reuseable/app_localizations.dart';
import 'package:hello_gas/ui/reuseable/cache_image_network.dart';
import 'package:hello_gas/ui/reuseable/global_widget.dart';

class AccountInformationPage extends StatefulWidget {
  @override
  _AccountInformationPageState createState() => _AccountInformationPageState();
}

class _AccountInformationPageState extends State<AccountInformationPage> {
  // initialize global widget
  final _globalWidget = GlobalWidget();
  TextEditingController _etEmail = TextEditingController();
  TextEditingController _etFirstName = TextEditingController();
  TextEditingController _etLastName = TextEditingController();
  TextEditingController _etphone = TextEditingController();
  TextEditingController _etLocation = TextEditingController();
  TextEditingController _etPass = TextEditingController();
  FlutterSecureStorage storage = FlutterSecureStorage();
  bool _obscureText = true;
  bool circular = false;
  String errorText = '';
  bool circularA = true;
  String walletID = '';
  String email = '';
  bool validate = true;
  final _globalkey = GlobalKey<FormState>();
  NetworkHandler networkHandler = NetworkHandler();
  IconData _iconVisible = Icons.visibility_off;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchData() async {
    String walletId = (await storage.read(key: 'walletId'))!;
    String mail = (await storage.read(key: 'email'))!;
    setState(() {
      email = mail;
      walletID = walletId;
      circularA = false;
    });
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
            'Update Account Information',
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
          child: Form(
            key: _globalkey,
            child: ListView(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 30),
              children: <Widget>[
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
                            BorderSide(color: PRIMARY_COLOR, width: 2.0)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffb3e5fc)),
                    ),
                    labelText: 'First Name',
                    labelStyle: TextStyle(color: PRIMARY_COLOR),
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
                            BorderSide(color: PRIMARY_COLOR, width: 2.0)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffb3e5fc)),
                    ),
                    labelText: 'Last Name',
                    labelStyle: TextStyle(color: PRIMARY_COLOR),
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
                  controller: _etLocation,
                  style: TextStyle(color: Colors.white),
                  onChanged: (textValue) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: PRIMARY_COLOR, width: 2.0)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffb3e5fc)),
                    ),
                    labelText: 'Location',
                    labelStyle: TextStyle(color: PRIMARY_COLOR),
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
                            BorderSide(color: PRIMARY_COLOR, width: 2.0)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffb3e5fc)),
                    ),
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(color: PRIMARY_COLOR),
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
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) => PRIMARY_COLOR,
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
                            "walletId": walletID,
                            "phoneNumber": _etphone.text,
                            "firstName": _etFirstName.text,
                            "lastName": _etLastName.text,
                            "email": email,
                            "location": _etLocation.text
                          };
                          print(data);
                          var response = await networkHandler.post(
                              '/api/Usermanagement/UpdateAccountprofile', data);
                          Map<String, dynamic> output =
                              json.decode(response.body);
                          print(output);
                          if (output['code'] == '00') {
                            print(output);
                            setState(() {
                              circular = false;
                            });

                            Navigator.of(context).pop();
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
                                'Update Profile',
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
              ],
            ),
          ),
        ));
  }

  Widget _createProfilePicture() {
    final double profilePictureSize = MediaQuery.of(context).size.width / 3;
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: EdgeInsets.only(top: 40),
        width: profilePictureSize,
        height: profilePictureSize,
        child: GestureDetector(
          onTap: () {
            _showPopupUpdatePicture();
          },
          child: Stack(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: (profilePictureSize),
                child: Hero(
                  tag: 'profilePicture',
                  child: ClipOval(
                      child: buildCacheNetworkImage(
                          width: profilePictureSize,
                          height: profilePictureSize,
                          url: GLOBAL_URL + '/assets/images/user/avatar.png')),
                ),
              ),
              // create edit icon in the picture
              Container(
                width: 30,
                height: 30,
                margin: EdgeInsets.only(
                    top: 0, left: MediaQuery.of(context).size.width / 4),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 1,
                  child: Icon(Icons.edit, size: 12, color: CHARCOAL),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _verifiedLabel() {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
      decoration: BoxDecoration(
          color: SOFT_BLUE, borderRadius: BorderRadius.circular(2)),
      child: Row(
        children: [
          Text(AppLocalizations.of(context)!.translate('verified')!,
              style: TextStyle(color: Colors.white, fontSize: 11)),
          SizedBox(
            width: 4,
          ),
          Icon(Icons.done, color: Colors.white, size: 11)
        ],
      ),
    );
  }

  void _showPopupUpdatePicture() {
    // set up the buttons
    Widget cancelButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(AppLocalizations.of(context)!.translate('no')!,
            style: TextStyle(color: SOFT_BLUE)));
    Widget continueButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EditProfilePicturePage()));
        },
        child: Text(AppLocalizations.of(context)!.translate('yes')!,
            style: TextStyle(color: SOFT_BLUE)));

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Text(
        AppLocalizations.of(context)!.translate('edit_profile_picture')!,
        style: TextStyle(fontSize: 18),
      ),
      content: Text(
          AppLocalizations.of(context)!
              .translate('edit_profile_picture_message')!,
          style: TextStyle(fontSize: 13, color: BLACK_GREY)),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
