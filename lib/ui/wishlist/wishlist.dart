/*
This is wishlist page
we used AutomaticKeepAliveClientMixin to keep the state when moving from 1 navbar to another navbar, so the page is not refresh overtime

include file in reuseable/global_function.dart to call function from GlobalFunction
include file in reuseable/global_widget.dart to call function from GlobalWidget
include file in reuseable/cache_image_network.dart to use cache image network
include file in reuseable/shimmer_loading.dart to use shimmer loading
include file in model/wishlist/wishlist_model.dart to get wishlistData

install plugin in pubspec.yaml
- fluttertoast => to show toast (https://pub.dev/packages/fluttertoast)

Don't forget to add all images and sound used in this pages at the pubspec.yaml
 */

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hello_gas/bloc/wishlist/bloc.dart';
import 'package:hello_gas/config/constants.dart';
import 'package:hello_gas/config/global_style.dart';
import 'package:hello_gas/model/wishlist/wishlist_model.dart';
import 'package:hello_gas/ui/general/chat_us.dart';
import 'package:hello_gas/ui/general/product_detail/product_detail.dart';
import 'package:hello_gas/ui/general/notification.dart';
import 'package:hello_gas/ui/reuseable/app_localizations.dart';
import 'package:hello_gas/ui/reuseable/cache_image_network.dart';
import 'package:hello_gas/ui/reuseable/global_function.dart';
import 'package:hello_gas/ui/reuseable/global_widget.dart';
import 'package:hello_gas/ui/reuseable/shimmer_loading.dart';

class WishlistPage extends StatefulWidget {
  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> with AutomaticKeepAliveClientMixin {
  // initialize global function, global widget and shimmer loading
  final _globalFunction = GlobalFunction();
  final _globalWidget = GlobalWidget();
  final _shimmerLoading = ShimmerLoading();

  List<WishlistModel> wishlistData = [];

  late WishlistBloc _wishlistBloc;
  bool _lastData = false;

  CancelToken apiToken = CancelToken(); // used to cancel fetch data from API

  // _listKey is used for AnimatedList
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  TextEditingController _etSearch = TextEditingController();

  // keep the state to do not refresh when switch navbar
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // get data when initState
    _wishlistBloc = BlocProvider.of<WishlistBloc>(context);
    _wishlistBloc.add(GetWishlist(sessionId: SESSION_ID, apiToken: apiToken));

    super.initState();
  }

  @override
  void dispose() {
    apiToken.cancel("cancelled"); // cancel fetch data from API
    _etSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if we used AutomaticKeepAliveClientMixin, we must call super.build(context);
    super.build(context);
    final double boxImageSize = (MediaQuery.of(context).size.width / 4);
    return Scaffold(
        appBar: AppBar(
          elevation: GlobalStyle.appBarElevation,
          title: Text(
            AppLocalizations.of(context)!.translate('wishlist')!,
            style: GlobalStyle.appBarTitle,
          ),
          backgroundColor: GlobalStyle.appBarBackgroundColor,
          brightness: GlobalStyle.appBarBrightness,
          actions: [
            GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatUsPage()));
                },
                child: Icon(Icons.email, color: BLACK_GREY)),
            IconButton(
                icon: _globalWidget.customNotifIcon(8, BLACK_GREY),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage()));
                }),
          ],
          // create search text field in the app bar
          bottom: PreferredSize(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[100]!,
                      width: 1.0,
                    )
                ),
              ),
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              height: kToolbarHeight,
              child: TextFormField(
                controller: _etSearch,
                textAlignVertical: TextAlignVertical.bottom,
                maxLines: 1,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                onChanged: (textValue) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  fillColor: Colors.grey[100],
                  filled: true,
                  hintText: AppLocalizations.of(context)!.translate('search_wishlist')!,
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  suffixIcon: (_etSearch.text == '')
                      ? null
                      : GestureDetector(
                      onTap: () {
                        setState(() {
                          _etSearch = TextEditingController(text: '');
                        });
                      },
                      child: Icon(Icons.close, color: Colors.grey[500])),
                  focusedBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      borderSide: BorderSide(color: Colors.grey[200]!)),
                  enabledBorder: UnderlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
              ),
            ),
            preferredSize: Size.fromHeight(kToolbarHeight),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: refreshData,
          child: BlocListener<WishlistBloc, WishlistState>(
            listener: (context, state) {
              if(state is WishlistError) {
                _globalFunction.showToast(type: 'error', message: state.errorMessage);
              }
              if(state is GetWishlistSuccess) {
                if(state.wishlistData.length==0){
                  _lastData = true;
                } else {
                  wishlistData.addAll(state.wishlistData);
                }
              }
            },
            child: BlocBuilder<WishlistBloc, WishlistState>(
              builder: (context, state) {
                if(state is WishlistError) {
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
                            child: Text(AppLocalizations.of(context)!.translate('no_wishlist')!, style: TextStyle(
                                fontSize: 14,
                                color: BLACK_GREY
                            ))
                        )
                    );
                  } else {
                    if(wishlistData.length==0){
                      return _shimmerLoading.buildShimmerContent();
                    } else {
                      return AnimatedList(
                        key: _listKey,
                        initialItemCount: wishlistData.length,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index, animation) {
                          return _buildWishlistCard(wishlistData[index], boxImageSize, animation, index);
                        },
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

  Widget _buildWishlistCard(WishlistModel wishlistData, boxImageSize, animation, index){
    return SizeTransition(
      sizeFactor: animation,
      child: Container(
        margin: EdgeInsets.fromLTRB(12, 6, 12, 0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
          color: Colors.white,
          child: Container(
            margin: EdgeInsets.all(8),
            child: Column(
              children: [
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailPage(name: wishlistData.name, image: wishlistData.image, price: wishlistData.price, rating: wishlistData.rating, review: wishlistData.review, sale: wishlistData.sale)));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ClipRRect(
                          borderRadius:
                          BorderRadius.all(Radius.circular(10)),
                          child: buildCacheNetworkImage(width: boxImageSize, height: boxImageSize, url: wishlistData.image)),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              wishlistData.name,
                              style: GlobalStyle.productName.copyWith(fontSize: 13),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 5),
                              child: Text('\$ '+_globalFunction.removeDecimalZeroFormat(wishlistData.price),
                                  style: GlobalStyle.productPrice),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 5),
                              child: Row(
                                children: [
                                  Icon(Icons.location_on,
                                      color: SOFT_GREY, size: 12),
                                  Text(' '+wishlistData.location,
                                      style: GlobalStyle.productLocation)
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 5),
                              child: Row(
                                children: [
                                  _globalWidget.createRatingBar(wishlistData.rating),
                                  Text('('+wishlistData.review.toString()+')', style: GlobalStyle.productTotalReview)
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 5),
                              child: Text(wishlistData.sale.toString()+' '+AppLocalizations.of(context)!.translate('sale')!,
                                  style: GlobalStyle.productSale),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          showPopupDeleteWishlist(index, boxImageSize);
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
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: (wishlistData.stock==0)
                            ? TextButton(
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all(
                                  Size(0, 30)
                              ),
                              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) => Colors.grey[300]!,
                              ),
                              overlayColor: MaterialStateProperty.all(Colors.transparent),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  )
                              ),
                            ),
                            onPressed: null,
                            child: Text(
                              AppLocalizations.of(context)!.translate('out_of_stock')!,
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13
                              ),
                              textAlign: TextAlign.center,
                            )
                        )
                            : OutlinedButton(
                            onPressed: () {
                              Fluttertoast.showToast(msg: AppLocalizations.of(context)!.translate('shopping_cart_added')!, toastLength: Toast.LENGTH_LONG);
                            },
                            style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(
                                    Size(0, 30)
                                ),
                                overlayColor: MaterialStateProperty.all(Colors.transparent),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    )
                                ),
                                side: MaterialStateProperty.all(
                                  BorderSide(
                                      color: SOFT_BLUE,
                                      width: 1.0
                                  ),
                                )
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.translate('add_to_shopping_cart')!,
                              style: TextStyle(
                                  color: SOFT_BLUE,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13
                              ),
                              textAlign: TextAlign.center,
                            )
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future refreshData() async {
    setState(() {
      wishlistData.clear();
      _wishlistBloc.add(GetWishlist(sessionId: SESSION_ID, apiToken: apiToken));
    });
  }

  void showPopupDeleteWishlist(index, boxImageSize) {
    // set up the buttons
    Widget cancelButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(AppLocalizations.of(context)!.translate('no')!, style: TextStyle(color: SOFT_BLUE))
    );
    Widget continueButton = TextButton(
        onPressed: () {
          int removeIndex = index;
          var removedItem = wishlistData.removeAt(removeIndex);
          // This builder is just so that the animation has something
          // to work with before it disappears from view since the original
          // has already been deleted.
          AnimatedListRemovedItemBuilder builder = (context, animation) {
            // A method to build the Card widget.
            return _buildWishlistCard(removedItem, boxImageSize, animation, removeIndex);
          };
          _listKey.currentState!.removeItem(removeIndex, builder);

          Navigator.pop(context);
          Fluttertoast.showToast(msg: AppLocalizations.of(context)!.translate('item_deleted_wishlist')!, toastLength: Toast.LENGTH_LONG);
        },
        child: Text(AppLocalizations.of(context)!.translate('yes')!, style: TextStyle(color: SOFT_BLUE))
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Text(AppLocalizations.of(context)!.translate('delete_wishlist')!, style: TextStyle(fontSize: 18),),
      content: Text(AppLocalizations.of(context)!.translate('are_you_sure_delete_wishlist')!, style: TextStyle(fontSize: 13, color: BLACK_GREY)),
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
