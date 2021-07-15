/*
This is home page

For this homepage, appBar is created at the bottom after CustomScrollView
we used AutomaticKeepAliveClientMixin to keep the state when moving from 1 navbar to another navbar, so the page is not refresh overtime

include file in reuseable/global_function.dart to call function from GlobalFunction
include file in reuseable/global_widget.dart to call function from GlobalWidget
include file in reuseable/cache_image_network.dart to use cache image network
include file in reuseable/shimmer_loading.dart to use shimmer loading
include file in model/home/category/category_for_you_model.dart to get categoryForYouData
include file in model/home/category/category_model.dart to get categoryData
include file in model/home/coupon_model.dart to get couponData
include file in model/home/flashsale_model.dart to get flashsaleData
include file in model/home/home_banner_model.dart to get homeBannerData
include file in model/home/last_search_model.dart to get lastSearchData
include file in model/home/trending_model.dart to get homeTrendingData
include file in model/home/recomended_product_model.dart to get recomendedProductData

install plugin in pubspec.yaml
- carousel_slider => slider images (https://pub.dev/packages/carousel_slider)
- fluttertoast => to show toast (https://pub.dev/packages/fluttertoast)

Don't forget to add all images and sound used in this pages at the pubspec.yaml
 */

import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hello_gas/bloc/home/category/category/bloc.dart';
import 'package:hello_gas/bloc/home/category/category_for_you/bloc.dart';
import 'package:hello_gas/bloc/home/flashsale/bloc.dart';
import 'package:hello_gas/bloc/home/home_banner/bloc.dart';
import 'package:hello_gas/bloc/home/home_trending/bloc.dart';
import 'package:hello_gas/bloc/home/last_search/bloc.dart';
import 'package:hello_gas/bloc/home/recomended_product/bloc.dart';
import 'package:hello_gas/config/constants.dart';
import 'package:hello_gas/config/global_style.dart';
import 'package:hello_gas/model/home/category/category_for_you_model.dart';
import 'package:hello_gas/model/home/category/category_model.dart';
import 'package:hello_gas/model/home/flashsale_model.dart';
import 'package:hello_gas/model/home/home_banner_model.dart';
import 'package:hello_gas/model/home/last_search_model.dart';
import 'package:hello_gas/model/home/trending_model.dart';
import 'package:hello_gas/model/home/recomended_product_model.dart';
import 'package:hello_gas/ui/general/chat_us.dart';
import 'package:hello_gas/ui/home/coupon.dart';
import 'package:hello_gas/ui/home/flashsale.dart';
import 'package:hello_gas/ui/home/last_search.dart';
import 'package:hello_gas/ui/general/product_detail/product_detail.dart';
import 'package:hello_gas/ui/general/notification.dart';
import 'package:hello_gas/ui/home/category/product_category.dart';
import 'package:hello_gas/ui/home/search/search_product.dart';
import 'package:hello_gas/ui/reuseable/app_localizations.dart';
import 'package:hello_gas/ui/reuseable/cache_image_network.dart';
import 'package:hello_gas/ui/home/search/search.dart';
import 'package:hello_gas/ui/reuseable/global_function.dart';
import 'package:hello_gas/ui/reuseable/global_widget.dart';
import 'package:hello_gas/ui/reuseable/shimmer_loading.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // initialize global function, global widget and shimmer loading
  final _globalFunction = GlobalFunction();
  final _globalWidget = GlobalWidget();
  final _shimmerLoading = ShimmerLoading();

  List<HomeBannerModel> homeBannerData = [];
  List<FlashsaleModel> flashsaleData = [];
  List<LastSearchModel> lastSearchData = [];
  List<HomeTrendingModel> homeTrendingData = [];
  List<CategoryForYouModel> categoryForYouData = [];
  List<CategoryModel> categoryData = [];

  late HomeBannerBloc _homeBannerBloc;
  bool _lastDataHomeBanner = false;

  late FlashsaleBloc _flashsaleBloc;
  bool _lastDataFlashsale = false;

  late LastSearchBloc _lastSearchBloc;
  bool _lastDataSeach = false;

  late HomeTrendingBloc _homeTrendingBloc;
  bool _lastDataTrending = false;

  late CategoryForYouBloc _categoryForYouBloc;
  bool _lastDataCategoryForYou = false;

  late CategoryBloc _categoryBloc;
  bool _lastDataCategory = false;

  List<RecomendedProductModel> recomendedProductData = [];
  late RecomendedProductBloc _recomendedProductBloc;
  int _apiPageRecomended = 0;
  bool _lastDataRecomended = false;
  bool _processApiRecomended = false;

  CancelToken apiToken = CancelToken(); // used to cancel fetch data from API

  int _currentImageSlider = 0;

  late ScrollController _scrollController;
  Color _topIconColor = Colors.white;
  Color _topSearchColor = Colors.white;
  late AnimationController _topColorAnimationController;
  late Animation _appBarColor;
  Brightness _statusIconBrightness = Brightness.dark;

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
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.translate('flash_sale_is_over')!,
            toastLength: Toast.LENGTH_LONG);
      }
    });
  }

  void _cancelFlashsaleTimer() {
    if (_flashsaleTimer != null) {
      _flashsaleTimer?.cancel();
      _flashsaleTimer = null;
    }
  }

  // keep the state to do not refresh when switch navbar
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // get data when initState
    _homeBannerBloc = BlocProvider.of<HomeBannerBloc>(context);
    _homeBannerBloc
        .add(GetHomeBanner(sessionId: SESSION_ID, apiToken: apiToken));

    _flashsaleBloc = BlocProvider.of<FlashsaleBloc>(context);
    _flashsaleBloc.add(GetFlashsaleHome(
        sessionId: SESSION_ID, skip: '0', limit: '8', apiToken: apiToken));

    _lastSearchBloc = BlocProvider.of<LastSearchBloc>(context);
    _lastSearchBloc.add(GetLastSearchHome(
        sessionId: SESSION_ID, skip: '0', limit: '8', apiToken: apiToken));

    _homeTrendingBloc = BlocProvider.of<HomeTrendingBloc>(context);
    _homeTrendingBloc.add(GetHomeTrending(
        sessionId: SESSION_ID, skip: '0', limit: '8', apiToken: apiToken));

    _categoryForYouBloc = BlocProvider.of<CategoryForYouBloc>(context);
    _categoryForYouBloc
        .add(GetCategoryForYou(sessionId: SESSION_ID, apiToken: apiToken));

    _categoryBloc = BlocProvider.of<CategoryBloc>(context);
    _categoryBloc.add(GetCategory(sessionId: SESSION_ID, apiToken: apiToken));

    _recomendedProductBloc = BlocProvider.of<RecomendedProductBloc>(context);
    _recomendedProductBloc.add(GetRecomendedProduct(
        sessionId: SESSION_ID,
        skip: _apiPageRecomended.toString(),
        limit: LIMIT_PAGE.toString(),
        apiToken: apiToken));

    setupAnimateAppbar();

    // set how many times left for flashsale
    var timeNow = DateTime.now();

    // 8000 second = 2 hours 13 minutes 20 second for flashsale timer
    var flashsaleTime =
        timeNow.add(Duration(seconds: 8000)).difference(timeNow);
    _flashsaleSecond = flashsaleTime.inSeconds;
    _startFlashsaleTimer();

    super.initState();
  }

  @override
  void dispose() {
    apiToken.cancel("cancelled"); // cancel fetch data from API

    _scrollController.dispose();
    _topColorAnimationController.dispose();

    _cancelFlashsaleTimer();
    super.dispose();
  }

  void setupAnimateAppbar() {
    // use this function and paramater to animate top bar
    _topColorAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));
    _appBarColor = ColorTween(begin: Colors.transparent, end: Colors.white)
        .animate(_topColorAnimationController);
    _scrollController = ScrollController()
      ..addListener(() {
        _topColorAnimationController.animateTo(_scrollController.offset / 120);
        // if scroll for above 150, then change app bar color to white, search button to dark, and top icon color to dark
        // if scroll for below 150, then change app bar color to transparent, search button to white and top icon color to light
        if (_scrollController.hasClients &&
            _scrollController.offset > (150 - kToolbarHeight)) {
          if (_topIconColor != BLACK_GREY) {
            _topIconColor = BLACK_GREY;
            _topSearchColor = Colors.grey[100]!;
            _statusIconBrightness = Brightness.light;
          }
        } else {
          if (_topIconColor != Colors.white) {
            _topIconColor = Colors.white;
            _topSearchColor = Colors.white;
            _statusIconBrightness = Brightness.dark;
          }
        }
      });
  }

  // this function used to fetch data from API if we scroll to the bottom of the page
  void _onScroll() {
    double maxScroll = _scrollController.position.maxScrollExtent;
    double currentScroll = _scrollController.position.pixels;

    if (currentScroll == maxScroll) {
      if (_lastDataRecomended == false && !_processApiRecomended) {
        _recomendedProductBloc.add(GetRecomendedProduct(
            sessionId: SESSION_ID,
            skip: _apiPageRecomended.toString(),
            limit: LIMIT_PAGE.toString(),
            apiToken: apiToken));
        _processApiRecomended = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // if we used AutomaticKeepAliveClientMixin, we must call super.build(context);
    super.build(context);

    final double boxImageSize = (MediaQuery.of(context).size.width / 3);
    final double categoryForYouHeightShort = boxImageSize;
    final double categoryForYouHeightLong = (boxImageSize * 2);
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<HomeBannerBloc, HomeBannerState>(
            listener: (context, state) {
              if (state is HomeBannerError) {
                _globalFunction.showToast(
                    type: 'error', message: state.errorMessage);
              }
              if (state is GetHomeBannerSuccess) {
                if (state.homeBannerData.length == 0) {
                  _lastDataHomeBanner = true;
                } else {
                  homeBannerData.addAll(state.homeBannerData);
                }
              }
            },
          ),
          BlocListener<FlashsaleBloc, FlashsaleState>(
            listener: (context, state) {
              if (state is FlashsaleHomeError) {
                _globalFunction.showToast(
                    type: 'error', message: state.errorMessage);
              }
              if (state is GetFlashsaleHomeSuccess) {
                if (state.flashsaleData.length == 0) {
                  _lastDataFlashsale = true;
                } else {
                  flashsaleData.addAll(state.flashsaleData);
                }
              }
            },
          ),
          BlocListener<LastSearchBloc, LastSearchState>(
            listener: (context, state) {
              if (state is LastSearchHomeError) {
                _globalFunction.showToast(
                    type: 'error', message: state.errorMessage);
              }
              if (state is GetLastSearchHomeSuccess) {
                if (state.lastSearchData.length == 0) {
                  _lastDataSeach = true;
                } else {
                  lastSearchData.addAll(state.lastSearchData);
                }
              }
            },
          ),
          BlocListener<HomeTrendingBloc, HomeTrendingState>(
            listener: (context, state) {
              if (state is HomeTrendingError) {
                _globalFunction.showToast(
                    type: 'error', message: state.errorMessage);
              }
              if (state is GetHomeTrendingSuccess) {
                homeTrendingData.addAll(state.homeTrendingData);
              }
            },
          ),
          BlocListener<CategoryForYouBloc, CategoryForYouState>(
            listener: (context, state) {
              if (state is CategoryForYouError) {
                _globalFunction.showToast(
                    type: 'error', message: state.errorMessage);
              }
              if (state is GetCategoryForYouSuccess) {
                if (state.categoryForYouData.length == 0) {
                  _lastDataCategoryForYou = true;
                } else {
                  categoryForYouData.addAll(state.categoryForYouData);
                }
              }
            },
          ),
          BlocListener<RecomendedProductBloc, RecomendedProductState>(
            listener: (context, state) {
              if (state is RecomendedProductError) {
                _globalFunction.showToast(
                    type: 'error', message: state.errorMessage);
              }
              if (state is GetRecomendedProductSuccess) {
                _scrollController.addListener(_onScroll);
                if (state.recomendedProductData.length == 0) {
                  _lastDataRecomended = true;
                } else {
                  _apiPageRecomended += LIMIT_PAGE;
                  recomendedProductData.addAll(state.recomendedProductData);
                }
                _processApiRecomended = false;
              }
            },
          ),
          BlocListener<CategoryBloc, CategoryState>(
            listener: (context, state) {
              if (state is CategoryError) {
                _globalFunction.showToast(
                    type: 'error', message: state.errorMessage);
              }
              if (state is GetCategorySuccess) {
                if (state.categoryData.length == 0) {
                  _lastDataCategory = true;
                } else {
                  categoryData.addAll(state.categoryData);
                }
              }
            },
          ),
        ],
        child: RefreshIndicator(
          onRefresh: refreshData,
          child: Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverList(
                      delegate: SliverChildListDelegate([
                    Container(
                      // Here the height of the container is 45% of our total height
                      height: size.height * .35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        image: DecorationImage(
                          alignment: Alignment.center,
                          image: AssetImage("assets/images/hello.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    /*Container(
                      margin: EdgeInsets.only(top: 10, left: 16, right: 16),
                      child:
                          Text('Categories', style: GlobalStyle.sectionTitle),
                    ),
                    _createGridCategory(),*/
                    Container(
                      margin: EdgeInsets.only(top: 10, left: 16, right: 16),
                      child: Text('Featured Products',
                          style: GlobalStyle.sectionTitle),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      height: boxImageSize *
                          GlobalStyle.horizontalProductHeightMultiplication,
                      child: BlocBuilder<FlashsaleBloc, FlashsaleState>(
                        builder: (context, state) {
                          if (state is FlashsaleHomeError) {
                            return Container(
                                child: Center(
                                    child: Text(ERROR_OCCURED,
                                        style: TextStyle(
                                            fontSize: 14, color: BLACK_GREY))));
                          } else {
                            if (_lastDataFlashsale) {
                              return Container(
                                  child: Center(
                                      child: Text(
                                          AppLocalizations.of(context)!
                                              .translate('no_flash_sale')!,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: BLACK_GREY))));
                            } else {
                              if (flashsaleData.length == 0) {
                                return _shimmerLoading
                                    .buildShimmerHomeFlashsale(boxImageSize);
                              } else {
                                return ListView.builder(
                                  padding: EdgeInsets.only(left: 12, right: 12),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: flashsaleData.length + 1,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (index == flashsaleData.length) {
                                      return _buildLastBox(
                                          boxImageSize, FlashSalePage());
                                    } else {
                                      return _buildFlashsaleCard(
                                          index, boxImageSize);
                                    }
                                  },
                                );
                              }
                            }
                          }
                        },
                      ),
                    ),
                  ])),
                ],
              ),
              // Create AppBar with Animation
              Container(
                height: 80,
                child: AnimatedBuilder(
                  animation: _topColorAnimationController,
                  builder: (context, child) => AppBar(
                    backgroundColor: _appBarColor.value,
                    brightness: _statusIconBrightness,
                    elevation: GlobalStyle.appBarElevation,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future refreshData() async {
    setState(() {
      _apiPageRecomended = 0;
      homeBannerData.clear();
      flashsaleData.clear();
      lastSearchData.clear();
      homeTrendingData.clear();
      categoryForYouData.clear();
      categoryData.clear();
      recomendedProductData.clear();
      _homeBannerBloc
          .add(GetHomeBanner(sessionId: SESSION_ID, apiToken: apiToken));
      _flashsaleBloc.add(GetFlashsaleHome(
          sessionId: SESSION_ID, skip: '0', limit: '8', apiToken: apiToken));
      _lastSearchBloc.add(GetLastSearchHome(
          sessionId: SESSION_ID, skip: '0', limit: '8', apiToken: apiToken));
      _homeTrendingBloc.add(GetHomeTrending(
          sessionId: SESSION_ID, skip: '0', limit: '8', apiToken: apiToken));
      _categoryForYouBloc
          .add(GetCategoryForYou(sessionId: SESSION_ID, apiToken: apiToken));
      _categoryBloc.add(GetCategory(sessionId: SESSION_ID, apiToken: apiToken));
      _recomendedProductBloc.add(GetRecomendedProduct(
          sessionId: SESSION_ID,
          skip: _apiPageRecomended.toString(),
          limit: LIMIT_PAGE.toString(),
          apiToken: apiToken));
    });
  }

  Widget _createHomeBannerSlider() {
    double homeBannerWidth = MediaQuery.of(context).size.width;
    double homeBannerHeight = MediaQuery.of(context).size.width * 6 / 8;

    return BlocBuilder<HomeBannerBloc, HomeBannerState>(
      builder: (context, state) {
        if (state is HomeBannerError) {
          return Container(
              width: homeBannerWidth,
              height: homeBannerHeight,
              child: Center(
                  child: Text(ERROR_OCCURED,
                      style: TextStyle(fontSize: 14, color: BLACK_GREY))));
        } else {
          if (_lastDataHomeBanner) {
            return Container(
                width: homeBannerWidth,
                height: homeBannerHeight,
                child: Center(
                    child: Text(
                        AppLocalizations.of(context)!
                            .translate('no_home_banner_data')!,
                        style: TextStyle(fontSize: 14, color: BLACK_GREY))));
          } else {
            if (homeBannerData.length == 0) {
              return _shimmerLoading.buildShimmerHomeBanner(
                  homeBannerWidth, homeBannerHeight);
            } else {
              return Column(
                children: [
                  CarouselSlider(
                    items: homeBannerData
                        .map((item) => Container(
                              child: buildCacheNetworkImage(
                                  width: 0, height: 0, url: item.image),
                            ))
                        .toList(),
                    options: CarouselOptions(
                        aspectRatio: 8 / 6,
                        viewportFraction: 1.0,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 6),
                        autoPlayAnimationDuration: Duration(milliseconds: 300),
                        enlargeCenterPage: false,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentImageSlider = index;
                          });
                        }),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: homeBannerData.map((item) {
                      int index = homeBannerData.indexOf(item);
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageSlider == index
                              ? PRIMARY_COLOR
                              : Colors.grey[300],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            }
          }
        }
      },
    );
  }

  Widget _createCoupon() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => CouponPage()));
      },
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
            color: SOFT_BLUE, borderRadius: BorderRadius.circular(5)),
        child: Row(
          children: [
            Expanded(
              child: Container(
                child: Text(
                  AppLocalizations.of(context)!.translate('coupon_waiting')!,
                  style: TextStyle(
                      fontSize: 14,
                      color: Color(0xffffffff),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Icon(Icons.local_offer, color: Colors.white)
          ],
        ),
      ),
    );
  }

  Widget _buildFlashsaleTime() {
    int hour = _flashsaleSecond ~/ 3600;
    int minute = _flashsaleSecond % 3600 ~/ 60;
    int second = _flashsaleSecond % 60;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(3, 4, 3, 4),
          decoration: BoxDecoration(
              color: Colors.red, borderRadius: BorderRadius.circular(5)), //
          child: Text(_globalFunction.formatTime(hour),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ),
        Text(' : ',
            style: TextStyle(
                color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold)),
        Container(
          padding: EdgeInsets.fromLTRB(3, 4, 3, 4),
          decoration: BoxDecoration(
              color: Colors.red, borderRadius: BorderRadius.circular(5)), //
          child: Text(_globalFunction.formatTime(minute),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ),
        Text(' : ',
            style: TextStyle(
                color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold)),
        Container(
          padding: EdgeInsets.fromLTRB(3, 4, 3, 4),
          decoration: BoxDecoration(
              color: Colors.red, borderRadius: BorderRadius.circular(5)), //
          child: Text(_globalFunction.formatTime(second),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  Widget _createGridCategory() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryError) {
          return Container(
              child: Center(
                  child: Text(ERROR_OCCURED,
                      style: TextStyle(fontSize: 14, color: BLACK_GREY))));
        } else {
          if (_lastDataCategory) {
            return Wrap();
          } else {
            if (categoryData.length == 0) {
              return _shimmerLoading.buildShimmerCategory();
            } else {
              return GridView.count(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                primary: false,
                childAspectRatio: 1.1,
                shrinkWrap: true,
                crossAxisSpacing: 0,
                mainAxisSpacing: 0,
                crossAxisCount: 4,
                children: List.generate(categoryData.length, (index) {
                  return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProductCategoryPage(
                                    categoryName: categoryData[index].item)));
                      },
                      child: Column(children: [
                        buildCacheNetworkImage(
                            width: 40,
                            height: 40,
                            url: categoryData[index].itemimage,
                            plColor: Colors.transparent),
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Text(
                              categoryData[index].item,
                              style: TextStyle(
                                color: CHARCOAL,
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ]));
                }),
              );
            }
          }
        }
      },
    );
  }

  Widget _buildLastBox(boxImageSize, StatefulWidget page) {
    return Container(
      width: boxImageSize + 10,
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
                context, MaterialPageRoute(builder: (context) => page));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 50,
                child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) => PRIMARY_COLOR,
                      ),
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.0),
                      )),
                    ),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => page));
                    },
                    child: Text(
                      AppLocalizations.of(context)!.translate('go')!,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    )),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                AppLocalizations.of(context)!
                    .translate('check_another_product')!,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlashsaleCard(index, boxImageSize) {
    return Container(
      width: boxImageSize + 10,
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
                          width: boxImageSize + 10,
                          height: boxImageSize + 50,
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
                      padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: Text(flashsaleData[index].itemKg,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                  )
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
                      margin: EdgeInsets.only(top: 5),
                      child: Text(
                          '\₦ ' +
                              _globalFunction.removeDecimalZeroFormat(
                                  flashsaleData[index].itemPrice),
                          style: GlobalStyle.productPrice),
                    ),
                    /*Container(
                      margin: EdgeInsets.only(top: 2),
                      child: Text(
                          '\₦ ' +
                              _globalFunction.removeDecimalZeroFormat(
                                  ((100 - flashsaleData[index].discount) *
                                      flashsaleData[index].price /
                                      100)),
                          style: GlobalStyle.productPrice),
                    )*/
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
