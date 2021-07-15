/*
This is review product page

include file in reuseable/global_function.dart to call function from GlobalFunction
include file in reuseable/global_widget.dart to call function from GlobalWidget
include file in reuseable/cache_image_network.dart to use cache image network

install plugin in pubspec.yaml
- smooth_star_rating => to show toast (https://pub.dev/packages/smooth_star_rating)
 */

import 'package:flutter/material.dart';
import 'package:hello_gas/config/constants.dart';
import 'package:hello_gas/config/global_style.dart';
import 'package:hello_gas/library/smooth_star_rating/smooth_star_rating.dart';
import 'package:hello_gas/ui/reuseable/app_localizations.dart';
import 'package:hello_gas/ui/reuseable/cache_image_network.dart';
import 'package:hello_gas/ui/reuseable/global_function.dart';
import 'package:hello_gas/ui/reuseable/global_widget.dart';

class ReviewProductPage extends StatefulWidget {
  final String name;
  final String image;

  const ReviewProductPage({Key? key, this.name = '', this.image=''}) : super(key: key);

  @override
  _ReviewProductPageState createState() => _ReviewProductPageState();
}

class _ReviewProductPageState extends State<ReviewProductPage> {
  // initialize global function and global widget
  final _globalFunction = GlobalFunction();
  final _globalWidget = GlobalWidget();

  double _rating = 0;
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
    final double boxImageSize = (MediaQuery.of(context).size.width / 4);
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: GlobalStyle.appBarIconThemeColor,
          ),
          elevation: GlobalStyle.appBarElevation,
          title: Text(
            AppLocalizations.of(context)!.translate('review_product')!,
            style: GlobalStyle.appBarTitle,
          ),
          backgroundColor: GlobalStyle.appBarBackgroundColor,
          brightness: GlobalStyle.appBarBrightness,
          bottom: _globalWidget.bottomAppBar(),
        ),
        body: ListView(
          children: [
            Container(
              margin: EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      child: buildCacheNetworkImage(width: boxImageSize, height: boxImageSize, url: widget.image)),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.name,
                          style: GlobalStyle.productName.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )
                ],
              )
            ),
            Divider(
              height: 0,
              color: Colors.grey[400],
            ),
            Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 32),
                child: Text(AppLocalizations.of(context)!.translate('give_rating')!, style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18
                ))
            ),
            Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 32),
                child: SmoothStarRating(
                  rating: 5,
                  isReadOnly: false,
                  size: 40,
                  filledIconData: Icons.star,
                  defaultIconData: Icons.star_border,
                  color: Colors.yellow[700],
                  borderColor: Colors.yellow[700],
                  starCount: 5,
                  allowHalfRating: false,
                  spacing: 1,
                  onRated: (value) {
                    _rating = value;
                    print("rating value -> $_rating");
                    // print("rating value dd -> ${value.truncate()}");
                  },
                )
            ),
            Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 32, left: 24, right: 24),
                child: Text(AppLocalizations.of(context)!.translate('review_message')!)
            ),
            Container(
              margin: EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: TextField(
                maxLines: null,
                decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                        BorderSide(color: PRIMARY_COLOR, width: 2.0)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFCCCCCC)),
                    ),
                    labelText: AppLocalizations.of(context)!.translate('review')!,
                    labelStyle:
                    TextStyle(color: BLACK_GREY)),
              ),
            ),
            Container(
              margin: EdgeInsets.all(24),
              child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) => PRIMARY_COLOR,
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.0),
                        )
                    ),
                  ),
                  onPressed: () {
                    _globalFunction.startLoading(context, AppLocalizations.of(context)!.translate('add_review_success')!, 1);
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
                  )
              ),
            )
          ],
        )
    );
  }
}
