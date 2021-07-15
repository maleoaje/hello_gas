/*
This is shopping cart page

include file in reuseable/global_function.dart to call function from GlobalFunction
include file in reuseable/global_widget.dart to call function from GlobalWidget
include file in model/shopping_cart/shopping_cart_model.dart to get shoppingCartData
include file in reuseable/cache_image_network.dart to use cache image network

install plugin in pubspec.yaml
- fluttertoast => to show toast (https://pub.dev/packages/fluttertoast)

Don't forget to add all images and sound used in this pages at the pubspec.yaml
 */

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hello_gas/bloc/shopping_cart/bloc.dart';
import 'package:hello_gas/config/constants.dart';
import 'package:hello_gas/config/global_style.dart';
import 'package:hello_gas/model/shopping_cart/shopping_cart_model.dart';
import 'package:hello_gas/ui/home/coupon.dart';
import 'package:hello_gas/ui/reuseable/app_localizations.dart';
import 'package:hello_gas/ui/reuseable/global_function.dart';
import 'package:hello_gas/ui/reuseable/global_widget.dart';
import 'package:hello_gas/ui/shopping_cart/delivery.dart';
import 'package:hello_gas/ui/general/product_detail/product_detail.dart';
import 'package:hello_gas/ui/reuseable/cache_image_network.dart';

class ShoppingCartPage extends StatefulWidget {
  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  // initialize global function and global widget
  final _globalFunction = GlobalFunction();
  final _globalWidget = GlobalWidget();

  List<ShoppingCartModel> shoppingCartData = [];

  late ShoppingCartBloc _shoppingCartBloc;
  bool _lastData = false;

  CancelToken apiToken = CancelToken(); // used to cancel fetch data from API

  double _totalPrice = 0;

  @override
  void initState() {
    // get data when initState
    _shoppingCartBloc = BlocProvider.of<ShoppingCartBloc>(context);
    _shoppingCartBloc.add(GetShoppingCart(sessionId: SESSION_ID, apiToken: apiToken));

    super.initState();
  }

  @override
  void dispose() {
    apiToken.cancel("cancelled"); // cancel fetch data from API
    super.dispose();
  }

  void _countTotalPrice(){
    _totalPrice = 0;
    for(int i=0;i<shoppingCartData.length;i++){
      _totalPrice += shoppingCartData[i].price * shoppingCartData[i].qty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double boxImageSize = (MediaQuery.of(context).size.width / 5);

    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: GlobalStyle.appBarIconThemeColor,
          ),
          elevation: GlobalStyle.appBarElevation,
          title: Text(
            AppLocalizations.of(context)!.translate('shopping_cart')!,
            style: GlobalStyle.appBarTitle,
          ),
          backgroundColor: GlobalStyle.appBarBackgroundColor,
          brightness: GlobalStyle.appBarBrightness,
          bottom: _globalWidget.bottomAppBar(),
        ),
        body: RefreshIndicator(
          onRefresh: refreshData,
          child: BlocListener<ShoppingCartBloc, ShoppingCartState>(
            listener: (context, state) {
              if(state is ShoppingCartError) {
                _globalFunction.showToast(type: 'error', message: state.errorMessage);
              }
              if(state is GetShoppingCartSuccess) {
                if(state.shoppingCartData.length==0){
                  _lastData = true;
                } else {
                  shoppingCartData.addAll(state.shoppingCartData);
                }
                _countTotalPrice();
              }
            },
            child: BlocBuilder<ShoppingCartBloc, ShoppingCartState>(
              builder: (context, state) {
                if(state is ShoppingCartError) {
                  return Container(
                      child: Center(
                          child: Text(ERROR_OCCURED, style: TextStyle(
                              fontSize: 14,
                              color: BLACK_GREY
                          ))
                      )
                  );
                } else {
                  if(_lastData){
                    return Container(
                        child: Center(
                            child: Text(AppLocalizations.of(context)!.translate('shopping_cart_empty')!, style: TextStyle(
                                fontSize: 14,
                                color: BLACK_GREY
                            ))
                        )
                    );
                  } else {
                    if(shoppingCartData.length==0){
                      return _globalWidget.buildProgressIndicator(false);
                    } else {
                      return ListView(
                        physics: AlwaysScrollableScrollPhysics(),
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            color: Colors.white,
                            child: Column(
                              children: List.generate(shoppingCartData.length,(index){
                                return _buildItem(index, boxImageSize);
                              }),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 12),
                            padding: EdgeInsets.all(16),
                            color: Colors.white,
                            child: Column(
                              children: [
                                _createUseCoupon(),
                                _createTotalPrice(),
                              ],
                            ),
                          )
                        ],
                      );
                    }
                  }
                }
              },
            ),
          ),
        )
    );
  }

  Widget _createUseCoupon(){
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => CouponPage()));
      },
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
                width: 1,
                color: Colors.grey[300]!
            ),
            borderRadius: BorderRadius.all(
                Radius.circular(10) //         <--- border radius here
            )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.local_offer, color: SOFT_BLUE),
                SizedBox(width: 12),
                Text(AppLocalizations.of(context)!.translate('use_coupon')!, style: TextStyle(
                    color: CHARCOAL, fontWeight: FontWeight.bold
                )),
              ],
            ),
            Icon(Icons.chevron_right, size: 20, color: SOFT_GREY),
          ],
        ),
      ),
    );
  }

  Widget _createTotalPrice(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.translate('total')!, style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold
            )),
            SizedBox(height: 5),
            Text('\$'+_globalFunction.removeDecimalZeroFormat(_totalPrice), style: GlobalStyle.shoppingCartTotalPrice),
          ],
        ),
        TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) => PRIMARY_COLOR,
              ),
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  )
              ),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => DeliveryPage(shoppingCartData: shoppingCartData)));
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                AppLocalizations.of(context)!.translate('next')!,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
            )
        )
      ],
    );
  }

  Column _buildItem(index, boxImageSize){
    int quantity = shoppingCartData[index].qty;
    return Column(
      children: [
        Container(
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailPage(name: shoppingCartData[index].name, image: shoppingCartData[index].image, price: shoppingCartData[index].price, rating: 4, review: 23, sale: 36)));
                  },
                  child: ClipRRect(
                      borderRadius:
                      BorderRadius.all(Radius.circular(4)),
                      child: buildCacheNetworkImage(width: boxImageSize, height: boxImageSize, url: shoppingCartData[index].image)),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailPage(name: shoppingCartData[index].name, image: shoppingCartData[index].image, price: shoppingCartData[index].price, rating: 4, review: 23, sale: 36)));
                        },
                        child: Text(
                          shoppingCartData[index].name,
                          style: GlobalStyle.productName.copyWith(fontSize: 14),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        child: Text('\$ '+_globalFunction.removeDecimalZeroFormat(shoppingCartData[index].price),
                            style: GlobalStyle.productPrice),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                showPopupDelete(index, boxImageSize);
                              },
                              child: Container(
                                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                height: 30,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        width: 1, color: Colors.grey[300]!)),
                                child: Icon(Icons.delete,
                                    color: BLACK_GREY, size: 20),
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    setState(() {
                                      quantity--;
                                      shoppingCartData[index].setQty(quantity);
                                      _countTotalPrice();
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    height: 28,
                                    decoration: BoxDecoration(
                                        color: SOFT_BLUE,
                                        borderRadius: BorderRadius.circular(8)
                                    ),
                                    child: Icon(Icons.remove,
                                        color: Colors.white, size: 20),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  child: Text(quantity.toString(), style: TextStyle(

                                  )),
                                ),
                                SizedBox(width: 10),
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    setState(() {
                                      quantity++;
                                      shoppingCartData[index].setQty(quantity);
                                      _countTotalPrice();
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    height: 28,
                                    decoration: BoxDecoration(
                                        color: SOFT_BLUE,
                                        borderRadius: BorderRadius.circular(8)
                                    ),
                                    child: Icon(Icons.add,
                                        color: Colors.white, size: 20),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        (index == shoppingCartData.length - 1)
            ? Wrap()
            : Divider(
          height: 32,
          color: Colors.grey[400],
        )
      ],
    );
  }

  Future refreshData() async {
    setState(() {
      shoppingCartData.clear();
      _shoppingCartBloc.add(GetShoppingCart(sessionId: SESSION_ID, apiToken: apiToken));
    });
  }

  void showPopupDelete(index, boxImageSize) {
    // set up the buttons
    Widget cancelButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(AppLocalizations.of(context)!.translate('no')!, style: TextStyle(color: SOFT_BLUE))
    );
    Widget continueButton = TextButton(
        onPressed: () {
          setState(() {
            shoppingCartData.removeAt(index);
          });
          _countTotalPrice();
          Navigator.pop(context);
          Fluttertoast.showToast(msg: AppLocalizations.of(context)!.translate('shopping_cart_deleted')!, toastLength: Toast.LENGTH_LONG);
        },
        child: Text(AppLocalizations.of(context)!.translate('yes')!, style: TextStyle(color: SOFT_BLUE))
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Text(AppLocalizations.of(context)!.translate('delete_from_shoping_cart')!, style: TextStyle(fontSize: 18),),
      content: Text(AppLocalizations.of(context)!.translate('are_you_sure_delete_shopping_cart')!, style: TextStyle(fontSize: 13, color: BLACK_GREY)),
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
