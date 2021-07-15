/*
This is flash sale page

include file in reuseable/global_function.dart to call function from GlobalFunction
include file in reuseable/global_widget.dart to call function from GlobalWidget
include file in reuseable/cache_image_network.dart to use cache image network
include file in reuseable/shimmer_loading.dart to use shimmer loading
include file in model/home/flashsale_model.dart to get flashsaleData
 */

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hello_gas/bloc/wallet_transfer_history/bloc.dart';
import 'package:hello_gas/config/constants.dart';
import 'package:hello_gas/config/global_style.dart';
import 'package:hello_gas/model/account/wallet_transfer_history_model.dart';
import 'package:hello_gas/ui/home/search/search.dart';
import 'package:hello_gas/ui/reuseable/global_function.dart';
import 'package:hello_gas/ui/reuseable/global_widget.dart';
import 'package:hello_gas/ui/reuseable/shimmer_loading.dart';

class WalletTransferHistoryPage extends StatefulWidget {
  final int seconds;

  const WalletTransferHistoryPage({this.seconds = 0});
  @override
  _WalletHistoryPageState createState() => _WalletHistoryPageState();
}

class _WalletHistoryPageState extends State<WalletTransferHistoryPage> {
  // initialize global function, global widget and shimmer loading
  final _globalFunction = GlobalFunction();
  final _globalWidget = GlobalWidget();
  final _shimmerLoading = ShimmerLoading();

  List<WalletTransferModel> flashsaleData = [];

  late WalletTransferBloc _flashsaleBloc;
  int _apiPage = 0;
  ScrollController _scrollController = ScrollController();
  bool _lastData = false;
  bool _processApi = false;

  CancelToken apiToken = CancelToken(); // used to cancel fetch data from API

  @override
  void initState() {
    // get data when initState
    _flashsaleBloc = BlocProvider.of<WalletTransferBloc>(context);
    _flashsaleBloc.add(GetFlashsale(
        sessionId: SESSION_ID,
        skip: _apiPage.toString(),
        limit: LIMIT_PAGE.toString(),
        apiToken: apiToken));

    super.initState();
  }

  @override
  void dispose() {
    apiToken.cancel("cancelled"); // cancel fetch data from API
    _scrollController.dispose();

    super.dispose();
  }

  // this function used to fetch data from API if we scroll to the bottom of the page
  void _onScroll() {
    double maxScroll = _scrollController.position.maxScrollExtent;
    double currentScroll = _scrollController.position.pixels;

    /*
    only for home.dart, flashsale.dart and product_category.dart
    you need to check if the skip == 0, use timer
     */
    if (_apiPage == 0) {
      Timer(Duration(milliseconds: 3000), () {
        if (currentScroll == maxScroll) {
          if (_lastData == false && !_processApi) {
            _flashsaleBloc.add(GetFlashsale(
                sessionId: SESSION_ID,
                skip: _apiPage.toString(),
                limit: LIMIT_PAGE.toString(),
                apiToken: apiToken));
            _processApi = true;
          }
        }
      });
    } else {
      if (currentScroll == maxScroll) {
        if (_lastData == false && !_processApi) {
          _flashsaleBloc.add(GetFlashsale(
              sessionId: SESSION_ID,
              skip: _apiPage.toString(),
              limit: LIMIT_PAGE.toString(),
              apiToken: apiToken));
          _processApi = true;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _scrollController.addListener(_onScroll);
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: GlobalStyle.appBarIconThemeColor,
          ),
          elevation: GlobalStyle.appBarElevation,
          title: Text(
            "Transaction History",
            style: GlobalStyle.appBarTitle,
          ),
          backgroundColor: Colors.white,
          brightness: Brightness.dark,
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
          child: WillPopScope(
            onWillPop: () {
              Navigator.pop(context);
              return Future.value(true);
            },
            child: RefreshIndicator(
              onRefresh: refreshData,
              child: BlocListener<WalletTransferBloc, FlashsaleState>(
                listener: (context, state) {
                  if (state is FlashsaleError) {
                    _globalFunction.showToast(
                        type: 'error', message: state.errorMessage);
                  }
                  if (state is GetFlashsaleSuccess) {
                    if (state.flashsaleData.length == 0) {
                      _lastData = true;
                    } else {
                      _apiPage += LIMIT_PAGE;
                      flashsaleData.addAll(state.flashsaleData);
                    }
                    _processApi = false;
                  }
                },
                child: ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    Container(
                      margin: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Wallet Transaction history',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: PRIMARY_COLOR)),
                        ],
                      ),
                    ),
                    BlocBuilder<WalletTransferBloc, FlashsaleState>(
                      builder: (context, state) {
                        if (state is FlashsaleError) {
                          return Container(
                              child: Center(
                                  child: Text(ERROR_OCCURED,
                                      style: TextStyle(
                                          fontSize: 14, color: BLACK_GREY))));
                        } else {
                          if (_lastData && _apiPage == 0) {
                            return Container(
                                child: Center(
                                    child: Text('No transaction history',
                                        style: TextStyle(
                                            fontSize: 14, color: BLACK_GREY))));
                          } else {
                            if (flashsaleData.length == 0) {
                              return _shimmerLoading.buildShimmerFlashsale(
                                  ((MediaQuery.of(context).size.width) - 24) /
                                          2 -
                                      12);
                            } else {
                              return CustomScrollView(
                                  shrinkWrap: true,
                                  primary: false,
                                  slivers: <Widget>[
                                    SliverPadding(
                                      padding: EdgeInsets.fromLTRB(1, 1, 1, 1),
                                      sliver: SliverGrid(
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 1,
                                                mainAxisSpacing: 2,
                                                crossAxisSpacing: 5,
                                                childAspectRatio: 3.5),
                                        delegate: SliverChildBuilderDelegate(
                                          (BuildContext context, int index) {
                                            return _buildFlashsaleCard(index);
                                          },
                                          childCount: flashsaleData.length,
                                        ),
                                      ),
                                    ),
                                    /*SliverToBoxAdapter(
                                      child: (_apiPage == LIMIT_PAGE &&
                                              flashsaleData.length < LIMIT_PAGE)
                                          ? Wrap()
                                          : _globalWidget
                                              .buildProgressIndicator(_lastData),
                                    ),*/
                                  ]);
                            }
                          }
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildFlashsaleCard(index) {
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 2,
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: ASSENT_COLOR,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Icon(
                        Icons.history,
                        color: Colors.white,
                        size: 40,
                      ),
                      padding: EdgeInsets.all(5),
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Sender: ' + flashsaleData[index].senderFullName,
                          style: GlobalStyle.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Receiver: ' + flashsaleData[index].receiverFullName,
                          style: GlobalStyle.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Transaction Date: ' +
                              flashsaleData[index].transactionDate.toString(),
                          style: GlobalStyle.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Narration: ' +
                              flashsaleData[index].narration.toString(),
                          style: GlobalStyle.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Transaction Status: ' +
                              flashsaleData[index].transactionstatus,
                          style: GlobalStyle.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '₦' + flashsaleData[index].amount.toString(),
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: ASSENT_COLOR.withOpacity(0.7)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future refreshData() async {
    setState(() {
      _apiPage = 0;
      _lastData = false;
      flashsaleData.clear();
      _flashsaleBloc.add(GetFlashsale(
          sessionId: SESSION_ID,
          skip: _apiPage.toString(),
          limit: LIMIT_PAGE.toString(),
          apiToken: apiToken));
    });
  }
}
