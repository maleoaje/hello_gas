/*
This is delivery page

include file in reuseable/global_function.dart to call function from GlobalFunction
include file in reuseable/global_widget.dart to call function from GlobalWidget
include file in reuseable/cache_image_network.dart to use cache image network
 */

import 'package:flutter/material.dart';
import 'package:hello_gas/config/constants.dart';
import 'package:hello_gas/config/global_style.dart';
import 'package:hello_gas/model/shopping_cart/shopping_cart_model.dart';
import 'package:hello_gas/ui/general/product_detail/product_detail.dart';
import 'package:hello_gas/ui/reuseable/app_localizations.dart';
import 'package:hello_gas/ui/reuseable/cache_image_network.dart';
import 'package:hello_gas/ui/reuseable/global_function.dart';
import 'package:hello_gas/ui/reuseable/global_widget.dart';
import 'package:hello_gas/ui/shopping_cart/change_address.dart';
import 'package:hello_gas/ui/shopping_cart/payment.dart';

class DeliveryPage extends StatefulWidget {
  final List<ShoppingCartModel> shoppingCartData;

  const DeliveryPage({Key? key, required this.shoppingCartData}) : super(key: key);

  @override
  _DeliveryPageState createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  // initialize global function
  final _globalFunction = GlobalFunction();
  final _globalWidget = GlobalWidget();

  List<ShoppingCartModel> shoppingCartData = [];

  double _subTotal = 0;
  String _delivery = '';
  double _deliveryPrice = 0;

  @override
  void initState() {
    shoppingCartData = widget.shoppingCartData;
    countSubTotal();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void countSubTotal(){
    _subTotal = 0;
    for(int i=0;i<shoppingCartData.length;i++){
      _subTotal += shoppingCartData[i].price * shoppingCartData[i].qty;
    }
    _subTotal += _deliveryPrice;
  }

  @override
  Widget build(BuildContext context) {
    final double boxImageSize = (MediaQuery.of(context).size.width / 6);
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: GlobalStyle.appBarIconThemeColor,
          ),
          elevation: GlobalStyle.appBarElevation,
          title: Text(
            AppLocalizations.of(context)!.translate('delivery')!,
            style: GlobalStyle.appBarTitle,
          ),
          backgroundColor: GlobalStyle.appBarBackgroundColor,
          brightness: GlobalStyle.appBarBrightness,
          bottom: _globalWidget.bottomAppBar(),
        ),
        body: ListView(
          children: [
            _createDeliveryInformation(),
            _createOrderListInformation(boxImageSize),
            _createChooseDeliveryInformation(),
            _createSubTotalInformation()
          ],
        )
    );
  }

  Widget _createDeliveryInformation(){
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text('Home Address', style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold
                )),
              ),
              SizedBox(
                width: 8,
              ),
              Container(
                margin: EdgeInsets.only(right: 8),
                padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                decoration: BoxDecoration(
                    color: SOFT_BLUE,
                    borderRadius: BorderRadius.circular(2)
                ),
                child: Row(
                  children: [
                    Text(AppLocalizations.of(context)!.translate('default')!, style: TextStyle(
                        color: Colors.white, fontSize: 13
                    )),
                    SizedBox(
                      width: 4,
                    ),
                    Icon(Icons.done, color: Colors.white, size: 11)
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: 16,
          ),
          Container(
            child: Text('Robert Steven', style: TextStyle(
                color: CHARCOAL, fontSize: 14
            )),
          ),
          Container(
            margin: EdgeInsets.only(top: 4),
            child: Text('0811888999', style: TextStyle(
                color: CHARCOAL, fontSize: 14
            )),
          ),
          Container(
            margin: EdgeInsets.only(top: 4),
            child: Text('6019 Madison St', style: TextStyle(
                color: CHARCOAL, fontSize: 14
            )),
          ),
          Container(
            margin: EdgeInsets.only(top: 4),
            child: Text('West New York, NJ 07093', style: TextStyle(
                color: CHARCOAL, fontSize: 14
            )),
          ),
          Container(
            margin: EdgeInsets.only(top: 4),
            child: Text('USA', style: TextStyle(
                color: CHARCOAL, fontSize: 14
            )),
          ),
          SizedBox(height: 4),
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeAddressPage()));
            },
            child: Container(
              alignment: Alignment.topRight,
              child: Text(AppLocalizations.of(context)!.translate('change_address')!, style: TextStyle(
                  color: PRIMARY_COLOR, fontSize: 14
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createOrderListInformation(boxImageSize){
    return Container(
      margin: EdgeInsets.only(top: 12),
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.translate('order_list')!, style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold
          )),
          Column(
            children: List.generate(shoppingCartData.length,(index){
              int quantity = shoppingCartData[index].qty;
              return GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailPage(name: shoppingCartData[index].name, image: shoppingCartData[index].image, price: shoppingCartData[index].price, rating: 4, review: 23, sale: 36)));
                },
                child: Container(
                  margin: EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ClipRRect(
                          borderRadius:
                          BorderRadius.all(Radius.circular(8)),
                          child: buildCacheNetworkImage(width: boxImageSize, height: boxImageSize, url: shoppingCartData[index].image)),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(shoppingCartData[index].name, style: GlobalStyle.productName.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Container(
                                margin: EdgeInsets.only(top: 4),
                                child: Text(quantity.toString()+' '+AppLocalizations.of(context)!.translate('item')!+' (150 '+AppLocalizations.of(context)!.translate('gr')!+')', style: GlobalStyle.shoppingCartOtherProduct.copyWith(color: Colors.grey[400]))
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 4),
                              child: Text('\$'+_globalFunction.removeDecimalZeroFormat(quantity*shoppingCartData[index].price), style: GlobalStyle.productPrice),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _createChooseDeliveryInformation(){
    return Container(
        margin: EdgeInsets.only(top: 12),
        padding: EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.translate('delivery')!, style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold
            )),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: (){
                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return _showDeliveryPopup();
                  },
                );
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
                child: _delivery == ''?Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_shipping, color: SOFT_BLUE),
                        SizedBox(width: 12),
                        Text(AppLocalizations.of(context)!.translate('choose_delivery')!, style: TextStyle(
                            color: CHARCOAL, fontWeight: FontWeight.bold
                        )),
                      ],
                    ),
                    Icon(Icons.chevron_right, size: 20, color: SOFT_GREY),
                  ],
                ):Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_delivery, style: TextStyle(
                            color: CHARCOAL, fontWeight: FontWeight.bold
                        )),
                        SizedBox(
                          height: 5,
                        ),
                        Text('\$'+_deliveryPrice.toString(), style: GlobalStyle.deliveryTotalPrice),
                      ],
                    ),
                    Icon(Icons.chevron_right, size: 20, color: SOFT_GREY),
                  ],
                ),
              ),
            ),
          ],
        )
    );
  }

  Widget _showDeliveryPopup(){
    return StatefulBuilder(builder: (BuildContext context, StateSetter mystate) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12, bottom: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[500],
                  borderRadius: BorderRadius.circular(10)
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(AppLocalizations.of(context)!.translate('choose_courier')!, style: GlobalStyle.chooseCourier),
          ),
          Flexible(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: <Widget>[
                Text('DHL', style: GlobalStyle.courierTitle),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    setState(() {
                      _delivery = 'DHL Regular';
                      _deliveryPrice = 13;
                    });
                    countSubTotal();
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Regular', style: GlobalStyle.courierType),
                        Text('\$13', style: GlobalStyle.deliveryPrice),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    setState(() {
                      _delivery = 'DHL Express';
                      _deliveryPrice = 22;
                    });
                    countSubTotal();
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Express', style: GlobalStyle.courierType),
                        Text('\$22', style: GlobalStyle.deliveryPrice),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 32,
                  color: Colors.grey[400],
                ),
                Text('FedEx', style: GlobalStyle.courierTitle),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    setState(() {
                      _delivery = 'FedEx Regular';
                      _deliveryPrice = 9;
                    });
                    countSubTotal();
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Regular', style: GlobalStyle.courierType),
                        Text('\$9', style: GlobalStyle.deliveryPrice),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    setState(() {
                      _delivery = 'FedEx Express';
                      _deliveryPrice = 17;
                    });
                    countSubTotal();
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Express', style: GlobalStyle.courierType),
                        Text('\$17', style: GlobalStyle.deliveryPrice),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 32,
                  color: Colors.grey[400],
                ),
                Text('Other 1', style: GlobalStyle.courierTitle),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    setState(() {
                      _delivery = 'Other 1 Regular';
                      _deliveryPrice = 9;
                    });
                    countSubTotal();
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Regular', style: GlobalStyle.courierType),
                        Text('\$9', style: GlobalStyle.deliveryPrice),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    setState(() {
                      _delivery = 'Other 1 Express';
                      _deliveryPrice = 17;
                    });
                    countSubTotal();
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Express', style: GlobalStyle.courierType),
                        Text('\$17', style: GlobalStyle.deliveryPrice),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 32,
                  color: Colors.grey[400],
                ),
                Text('Other 2', style: GlobalStyle.courierTitle),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    setState(() {
                      _delivery = 'Other 2 Regular';
                      _deliveryPrice = 9;
                    });
                    countSubTotal();
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Regular', style: GlobalStyle.courierType),
                        Text('\$9', style: GlobalStyle.deliveryPrice),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    setState(() {
                      _delivery = 'Other 2 Express';
                      _deliveryPrice = 17;
                    });
                    countSubTotal();
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Express', style: GlobalStyle.courierType),
                        Text('\$17', style: GlobalStyle.deliveryPrice),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 32,
                  color: Colors.grey[400],
                ),
                Text('Other 3', style: GlobalStyle.courierTitle),
                GestureDetector(behavior: HitTestBehavior.translucent,
                  onTap: (){
                    setState(() {
                      _delivery = 'Other 3 Regular';
                      _deliveryPrice = 9;
                    });
                    countSubTotal();
                    Navigator.pop(context);
                  },

                  child: Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Regular', style: GlobalStyle.courierType),
                        Text('\$9', style: GlobalStyle.deliveryPrice),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    setState(() {
                      _delivery = 'Other 3 Express';
                      _deliveryPrice = 17;
                    });
                    countSubTotal();
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Express', style: GlobalStyle.courierType),
                        Text('\$17', style: GlobalStyle.deliveryPrice),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 32,
                  color: Colors.grey[400],
                ),
                Text('Other 4', style: GlobalStyle.courierTitle),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    setState(() {
                      _delivery = 'Other 4 Regular';
                      _deliveryPrice = 9;
                    });
                    countSubTotal();
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Regular', style: GlobalStyle.courierType),
                        Text('\$9', style: GlobalStyle.deliveryPrice),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    setState(() {
                      _delivery = 'Other 4 Express';
                      _deliveryPrice = 17;
                    });
                    countSubTotal();
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Express', style: GlobalStyle.courierType),
                        Text('\$17', style: GlobalStyle.deliveryPrice),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _createSubTotalInformation(){
    return Container(
      margin: EdgeInsets.only(top: 12),
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.translate('sub_total')!+' ', style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold
              )),
              SizedBox(height: 5),
              Text('\$'+_globalFunction.removeDecimalZeroFormat(_subTotal), style: GlobalStyle.shoppingCartTotalPrice),
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentPage()));
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  AppLocalizations.of(context)!.translate('pay')!,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              )
          )
        ],
      ),
    );
  }
}
