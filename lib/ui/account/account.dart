/*
This is account page

we used AutomaticKeepAliveClientMixin to keep the state when moving from 1 navbar to another navbar, so the page is not refresh overtime

include file in reuseable/global_widget.dart to call function from GlobalWidget
 */

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hello_gas/config/constants.dart';
import 'package:hello_gas/config/global_style.dart';
import 'package:hello_gas/network/network_handler.dart';
import 'package:hello_gas/ui/account/account_information/account_information.dart';
import 'package:hello_gas/ui/account/change_password.dart';
import 'package:hello_gas/ui/account/payment_method/payment_method.dart';
import 'package:hello_gas/ui/account/change_pin.dart';
import 'package:hello_gas/ui/account/funds_transfer.dart';
import 'package:hello_gas/ui/account/wallet_transfer_history.dart';
import 'package:hello_gas/ui/authentication/signin/signin_email.dart';
import 'package:hello_gas/ui/reuseable/app_localizations.dart';
import 'package:hello_gas/ui/account/fund_wallet.dart';
import 'package:hello_gas/ui/reuseable/global_widget.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>
    with AutomaticKeepAliveClientMixin {
  // initialize global widget
  final _globalWidget = GlobalWidget();
  FlutterSecureStorage storage = FlutterSecureStorage();
  NetworkHandler networkHandler = NetworkHandler();
  String name = '';
  String email = '';
  String amount = '';
  String walletID = '';
  bool circular = true;
  bool circularBal = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    fetchBalance();
    fetchData();
  }

  void fetchBalance() async {
    String walletId = (await storage.read(key: 'walletId'))!;
    var response = await networkHandler
        .get('/api/Usermanagement/GetWalletBalance?WalletId=$walletId');
    setState(() {
      amount = response['data']['walletBalance'];
      circular = false;
    });
  }

  void fetchData() async {
    String firstName = (await storage.read(key: 'firstName'))!;
    String mail = (await storage.read(key: 'email'))!;
    String walletId = (await storage.read(key: 'walletId'))!;
    setState(() {
      name = firstName;
      email = mail;
      walletID = walletId;
      circular = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // if we used AutomaticKeepAliveClientMixin, we must call super.build(context);
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          elevation: GlobalStyle.appBarElevation,
          title: Text(
            AppLocalizations.of(context)!.translate('account')!,
            style: GlobalStyle.appBarTitle,
          ),
          backgroundColor: Colors.transparent,
          brightness: GlobalStyle.appBarBrightness,
          bottom: _globalWidget.bottomAppBar(),
        ),
        body: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            image: DecorationImage(
              alignment: Alignment.center,
              image: AssetImage("assets/images/acct.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              _createAccountInformation(),
              Container(
                height: 100,
                width: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    alignment: Alignment.center,
                    image: AssetImage("assets/images/currentB.jpg"),
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
                child: Stack(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(120, 0, 0, 0),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                    text: "\nCurrent Balance\n",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                                TextSpan(
                                    text: "\₦ ",
                                    style: TextStyle(
                                        color: Colors.pinkAccent,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700)),
                                TextSpan(
                                    text: '$amount \n',
                                    style: TextStyle(
                                        color: Colors.pinkAccent,
                                        fontSize: 25,
                                        fontWeight: FontWeight.w700)),
                                TextSpan(
                                    text: "Wallet ID: $walletID ",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _createListMenu(
                  AppLocalizations.of(context)!.translate('change_password')!,
                  ChangePasswordPage()),
              Divider(height: 0, color: Colors.grey[400]),
              _createListMenu(
                  'Change Transction Pin',
                  ChangePinPage(
                    email: email,
                  )),
              Divider(height: 0, color: Colors.grey[400]),
              _createListMenu('Wallet to Wallet Transfer', TransferPage()),
              Divider(height: 0, color: Colors.grey[400]),
              _createListMenu('Fund Wallet', FundWalletPage()),
              Divider(height: 0, color: Colors.grey[400]),
              _createListMenu(
                  'Wallet Transaction History', WalletTransferHistoryPage()),
              Divider(height: 0, color: Colors.grey[400]),
              Container(
                margin: EdgeInsets.fromLTRB(0, 18, 0, 0),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SigninEmailPage()));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.power_settings_new,
                          size: 20, color: ASSENT_COLOR),
                      SizedBox(width: 8),
                      Text(AppLocalizations.of(context)!.translate('sign_out')!,
                          style: TextStyle(fontSize: 15, color: ASSENT_COLOR)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _createAccountInformation() {
    //final double profilePictureSize = MediaQuery.of(context).size.width / 4;
    return Container(
      margin: EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hi ' + name,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 8,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AccountInformationPage()));
                  },
                  child: Row(
                    children: [
                      Text('Update Account Information',
                          style: TextStyle(fontSize: 14, color: BLACK_GREY)),
                      SizedBox(
                        width: 8,
                      ),
                      Icon(Icons.chevron_right, size: 20, color: SOFT_GREY)
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _createListMenu(String menuTitle, StatefulWidget page) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 18, 0, 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(menuTitle, style: TextStyle(fontSize: 15, color: CHARCOAL)),
            Icon(Icons.chevron_right, size: 20, color: SOFT_GREY),
          ],
        ),
      ),
    );
  }
}
