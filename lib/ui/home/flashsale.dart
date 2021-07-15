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
import 'package:hello_gas/bloc/home/flashsale/bloc.dart';
import 'package:hello_gas/config/constants.dart';
import 'package:hello_gas/config/global_style.dart';
import 'package:hello_gas/model/home/flashsale_model.dart';
import 'package:hello_gas/ui/general/product_detail/product_detail.dart';
import 'package:hello_gas/ui/reuseable/app_localizations.dart';
import 'package:hello_gas/ui/reuseable/cache_image_network.dart';
import 'package:hello_gas/ui/home/search/search.dart';
import 'package:hello_gas/ui/reuseable/global_function.dart';
import 'package:hello_gas/ui/reuseable/global_widget.dart';
import 'package:hello_gas/ui/reuseable/shimmer_loading.dart';

class FlashSalePage extends StatefulWidget {
  final int seconds;

  const FlashSalePage({Key? key, this.seconds = 0}) : super(key: key);
  @override
  _FlashSalePageState createState() => _FlashSalePageState();
}

class _FlashSalePageState extends State<FlashSalePage> {
  // initialize global function, global widget and shimmer loading
  final _globalFunction = GlobalFunction();
  final _globalWidget = GlobalWidget();
  final _shimmerLoading = ShimmerLoading();

  List<FlashsaleModel> flashsaleData = [];

  late FlashsaleBloc _flashsaleBloc;
  int _apiPage = 0;
  ScrollController _scrollController = ScrollController();
  bool _lastData = false;
  bool _processApi = false;

  CancelToken apiToken = CancelToken(); // used to cancel fetch data from API

  Timer? _flashsaleTimer;
  late int _flashsaleSecond;

  void _startFlashsaleTimer() {
    const period = const Duration(seconds: 1);
    _flashsaleTimer = Timer.periodic(period, (timer) {
      setState(() {
        _flashsaleSecond--;
      });
      if (_flashsaleSecond == 0) {
        _cancelFlashsaleTimer();
      }
    });
  }

  void _cancelFlashsaleTimer() {
    if (_flashsaleTimer != null) {
      _flashsaleTimer?.cancel();
      _flashsaleTimer = null;
    }
  }

  @override
  void initState() {
    // get data when initState
    _flashsaleBloc = BlocProvider.of<FlashsaleBloc>(context);
    _flashsaleBloc.add(GetFlashsale(
        sessionId: SESSION_ID,
        skip: _apiPage.toString(),
        limit: LIMIT_PAGE.toString(),
        apiToken: apiToken));

    _flashsaleSecond = widget.seconds;
    if (_flashsaleSecond != 0) {
      _startFlashsaleTimer();
    }

    super.initState();
  }

  @override
  void dispose() {
    apiToken.cancel("cancelled"); // cancel fetch data from API
    _scrollController.dispose();
    _cancelFlashsaleTimer();

    super.dispose();
  }

  // this function used to fetch data from API if we scroll to the bottom of the page
  void _onScroll() {
    double maxScroll = _scrollController.position.maxScrollExtent;
    double currentScroll = _scrollController.position.pixels;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: PRIMARY_COLOR,
          ),
          elevation: GlobalStyle.appBarElevation,
          title: Text(
            'Gas Services',
            style: GlobalStyle.appBarTitle,
          ),
          backgroundColor: GlobalStyle.appBarBackgroundColor,
          brightness: GlobalStyle.appBarBrightness,
          bottom: _globalWidget.bottomAppBar(),
        ),
        body: WillPopScope(
          onWillPop: () {
            Navigator.pop(context);
            return Future.value(true);
          },
          child: RefreshIndicator(
            onRefresh: refreshData,
            child: BlocListener<FlashsaleBloc, FlashsaleState>(
              listener: (context, state) {
                if (state is FlashsaleError) {
                  _globalFunction.showToast(
                      type: 'error', message: state.errorMessage);
                }
                if (state is GetFlashsaleSuccess) {
                  _scrollController.addListener(_onScroll);
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
                controller: _scrollController,
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  /*buildCacheNetworkImage(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width / 2,
                      url: GLOBAL_URL + '/assets/images/flashsale/1.jpg'),*/
                  BlocBuilder<FlashsaleBloc, FlashsaleState>(
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
                                  child: Text(
                                      AppLocalizations.of(context)!
                                          .translate('no_flash_sale')!,
                                      style: TextStyle(
                                          fontSize: 14, color: BLACK_GREY))));
                        } else {
                          if (flashsaleData.length == 0) {
                            return _shimmerLoading.buildShimmerFlashsale(
                                ((MediaQuery.of(context).size.width) - 24) / 2 -
                                    12);
                          } else {
                            return CustomScrollView(
                                shrinkWrap: true,
                                primary: false,
                                slivers: <Widget>[
                                  SliverPadding(
                                    padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                                    sliver: SliverGrid(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 8,
                                        crossAxisSpacing: 8,
                                        childAspectRatio: GlobalStyle
                                            .gridDelegateFlashsaleRatio,
                                      ),
                                      delegate: SliverChildBuilderDelegate(
                                        (BuildContext context, int index) {
                                          return _buildFlashsaleCard(index);
                                        },
                                        childCount: flashsaleData.length,
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: (_apiPage == LIMIT_PAGE &&
                                            flashsaleData.length < LIMIT_PAGE)
                                        ? Wrap()
                                        : _globalWidget
                                            .buildProgressIndicator(_lastData),
                                  ),
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
        ));
  }

  Widget _buildFlashsaleCard(index) {
    final double boxImageSize =
        ((MediaQuery.of(context).size.width) - 24) / 2 - 12;
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 2,
        color: Colors.white,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProductDetailPage(
                          name: flashsaleData[index].item,
                          image: flashsaleData[index].itemimage,
                          price: flashsaleData[index].itemPrice,
                          rating: 4,
                          review: 45,
                        )));
          },
          child: Column(
            children: <Widget>[
              Stack(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      child: buildCacheNetworkImage(
                          width: boxImageSize,
                          height: boxImageSize + 60,
                          url: flashsaleData[index].itemimage)),
                  Positioned(
                    right: 0,
                    top: 10,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(6),
                              bottomLeft: Radius.circular(6))),
                      padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
                      child: Text(flashsaleData[index].itemKg,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flashsaleData[index].item,
                      style: GlobalStyle.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              '\₦ ' + flashsaleData[index].itemPrice.toString(),
                              style: GlobalStyle.productPrice),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
