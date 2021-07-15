/*
This is onboarding page
Don't forget to add all images and sound used in this pages at the pubspec.yaml
 */

import 'package:flutter/material.dart';
import 'package:hello_gas/library/flutter_overboard/overboard.dart';
import 'package:hello_gas/library/flutter_overboard/page_model.dart';
import 'package:hello_gas/ui/authentication/signin/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {

  // create each page of onBoard here
  final _pageList = [
    PageModel(
        color: Colors.white,
        imageAssetPath: 'assets/images/onboarding/search_product.gif',
        title: 'Choose Product',
        body: 'Search and browse the product you want to buy at iJShop',
        doAnimateImage: true),
  ];

  @override
  void initState() {
    super.initState();
  }

  // if user click finish, you won't see this page again until you clear your data of this apps in your phone setting
  void _finishOnboarding() async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    await _pref.setBool('onBoarding', false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: OverBoard(
          pages: _pageList,
          showBullets: true,
          finishCallback: () {
            _finishOnboarding();

            // after you click finish, direct to signin page
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => SigninPage()), (Route<dynamic> route) => false);
          },
        )
    );
  }
}
