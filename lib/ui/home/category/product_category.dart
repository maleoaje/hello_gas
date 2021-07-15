/*
This is product category page

include file in reuseable/global_function.dart to call function from GlobalFunction
include file in reuseable/global_widget.dart to call function from GlobalWidget
include file in reuseable/cache_image_network.dart to use cache image network
include file in reuseable/shimmer_loading.dart to use shimmer loading
include file in model/home/category/category_model.dart to get categoryData

install plugin in pubspec.yaml
- carousel_slider => slider images (https://pub.dev/packages/carousel_slider)

Don't forget to add all images and sound used in this pages at the pubspec.yaml
 */

import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hello_gas/bloc/home/category/category_all_product/bloc.dart';
import 'package:hello_gas/bloc/home/category/category_banner/bloc.dart';
import 'package:hello_gas/bloc/home/category/category_new_product/bloc.dart';
import 'package:hello_gas/bloc/home/category/category_trending_product/bloc.dart';
import 'package:hello_gas/config/constants.dart';
import 'package:hello_gas/config/global_style.dart';
import 'package:hello_gas/model/home/category/category_all_product_model.dart';
import 'package:hello_gas/model/home/category/category_banner_model.dart';
import 'package:hello_gas/model/home/category/category_new_product_model.dart';
import 'package:hello_gas/model/home/category/category_trending_product_model.dart';
import 'package:hello_gas/ui/reuseable/app_localizations.dart';
import 'package:hello_gas/ui/reuseable/cache_image_network.dart';
import 'package:hello_gas/ui/home/search/search.dart';
import 'package:hello_gas/ui/reuseable/global_function.dart';
import 'package:hello_gas/ui/reuseable/global_widget.dart';
import 'package:hello_gas/ui/reuseable/shimmer_loading.dart';

class ProductCategoryPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const ProductCategoryPage({Key? key, this.categoryId = 0, required this.categoryName}) : super(key: key);
  @override
  _ProductCategoryPageState createState() => _ProductCategoryPageState();
}

class _ProductCategoryPageState extends State<ProductCategoryPage> {
  // initialize global function, global widget and shimmer loading
  final _globalFunction = GlobalFunction();
  final _globalWidget = GlobalWidget();
  final _shimmerLoading = ShimmerLoading();

  ScrollController _scrollController = ScrollController();

  List<CategoryBannerModel> categoryBannerData = [];
  late CategoryBannerBloc _categoryBannerBloc;
  bool _lastDataCategoryBanner = false;

  List<CategoryTrendingProductModel> categoryTrendingProductData = [];
  late CategoryTrendingProductBloc _categoryTrendingProductBloc;
  bool _lastDataCategoryTrendingProduct = false;

  List<CategoryNewProductModel> categoryNewProductData = [];
  late CategoryNewProductBloc _categoryNewProductBloc;
  bool _lastDataCategoryNewProduct = false;

  List<CategoryAllProductModel> categoryAllProductData = [];
  late CategoryAllProductBloc _categoryAllProductBloc;
  int _apiPageCategoryAllProduct = 0;
  bool _lastDataCategoryAllProduct = false;
  bool _processApiCategoryAllProduct = false;

  CancelToken apiToken = CancelToken(); // used to cancel fetch data from API

  int _currentImageSlider = 0;

  @override
  void initState() {
    // get data when initState
    _categoryBannerBloc = BlocProvider.of<CategoryBannerBloc>(context);
    _categoryBannerBloc.add(GetCategoryBanner(sessionId: SESSION_ID, categoryId: widget.categoryId, apiToken: apiToken));

    _categoryTrendingProductBloc = BlocProvider.of<CategoryTrendingProductBloc>(context);
    _categoryTrendingProductBloc.add(GetCategoryTrendingProduct(sessionId: SESSION_ID, categoryId: widget.categoryId, skip: '0', limit: '8', apiToken: apiToken));

    _categoryNewProductBloc = BlocProvider.of<CategoryNewProductBloc>(context);
    _categoryNewProductBloc.add(GetCategoryNewProduct(sessionId: SESSION_ID, categoryId: widget.categoryId, skip: '0', limit: '8', apiToken: apiToken));

    _categoryAllProductBloc = BlocProvider.of<CategoryAllProductBloc>(context);
    _categoryAllProductBloc.add(GetCategoryAllProduct(sessionId: SESSION_ID, categoryId: widget.categoryId, skip: _apiPageCategoryAllProduct.toString(), limit: LIMIT_PAGE.toString(), apiToken: apiToken));

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

    if (currentScroll == maxScroll) {
      if (_lastDataCategoryAllProduct == false && !_processApiCategoryAllProduct) {
        _categoryAllProductBloc.add(GetCategoryAllProduct(sessionId: SESSION_ID, categoryId: widget.categoryId, skip: _apiPageCategoryAllProduct.toString(), limit: LIMIT_PAGE.toString(), apiToken: apiToken));
        _processApiCategoryAllProduct = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double boxImageSize = (MediaQuery.of(context).size.width / 3);

    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: GlobalStyle.appBarIconThemeColor,
          ),
          elevation: GlobalStyle.appBarElevation,
          title: Text(
            widget.categoryName.replaceAll('\n', ' '),
            style: GlobalStyle.appBarTitle,
          ),
          backgroundColor: GlobalStyle.appBarBackgroundColor,
          brightness: GlobalStyle.appBarBrightness,
          actions: [
            IconButton(
                icon: Icon(Icons.search, color: BLACK_GREY),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()));
                }),
          ],
          bottom: _globalWidget.bottomAppBar(),
        ),
        body: WillPopScope(
          onWillPop: (){
            Navigator.pop(context);
            return Future.value(true);
          },
          child: RefreshIndicator(
            onRefresh: refreshData,
            child: MultiBlocListener(
              listeners: [
                BlocListener<CategoryBannerBloc, CategoryBannerState>(
                  listener: (context, state) {
                    if(state is CategoryBannerError) {
                      _globalFunction.showToast(type: 'error', message: state.errorMessage);
                    }
                    if(state is GetCategoryBannerSuccess) {
                      _scrollController.addListener(_onScroll);
                      if(state.categoryBannerData.length==0){
                        _lastDataCategoryBanner = true;
                      } else {
                        categoryBannerData.addAll(state.categoryBannerData);
                      }
                    }
                  },
                ),
                BlocListener<CategoryTrendingProductBloc, CategoryTrendingProductState>(
                  listener: (context, state) {
                    if(state is CategoryTrendingProductError) {
                      _globalFunction.showToast(type: 'error', message: state.errorMessage);
                    }
                    if(state is GetCategoryTrendingProductSuccess) {
                      if(state.categoryTrendingProductData.length==0){
                        _lastDataCategoryTrendingProduct = true;
                      } else {
                        categoryTrendingProductData.addAll(state.categoryTrendingProductData);
                      }
                    }
                  },
                ),
                BlocListener<CategoryNewProductBloc, CategoryNewProductState>(
                  listener: (context, state) {
                    if(state is CategoryNewProductError) {
                      _globalFunction.showToast(type: 'error', message: state.errorMessage);
                    }
                    if(state is GetCategoryNewProductSuccess) {
                      if(state.categoryNewProductData.length==0){
                        _lastDataCategoryNewProduct = true;
                      } else {
                        categoryNewProductData.addAll(state.categoryNewProductData);
                      }
                    }
                  },
                ),
                BlocListener<CategoryAllProductBloc, CategoryAllProductState>(
                  listener: (context, state) {
                    if (state is CategoryAllProductError) {
                      _globalFunction.showToast(type: 'error', message: state.errorMessage);
                    }
                    if (state is GetCategoryAllProductSuccess) {
                      if (state.categoryAllProductData.length == 0) {
                        _lastDataCategoryAllProduct = true;
                      } else {
                        _apiPageCategoryAllProduct += LIMIT_PAGE;
                        categoryAllProductData.addAll(state.categoryAllProductData);
                      }
                      _processApiCategoryAllProduct = false;
                    }
                  },
                )
              ],
              child: ListView(
                controller: _scrollController,
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  _createCategorySlider(),
                  Container(
                    margin: EdgeInsets.only(top:20, left: 16, right: 16),
                    child: Text(AppLocalizations.of(context)!.translate('trending_product')!, style: GlobalStyle.sectionTitle),
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 8),
                      height: boxImageSize*GlobalStyle.horizontalProductHeightMultiplication,
                      child: BlocBuilder<CategoryTrendingProductBloc, CategoryTrendingProductState>(
                        builder: (context, state) {
                          if(state is CategoryTrendingProductError) {
                            return Container(
                                child: Center(
                                    child: Text(ERROR_OCCURED, style: TextStyle(
                                        fontSize: 14,
                                        color: BLACK_GREY
                                    ))
                                )
                            );
                          } else {
                            if(_lastDataCategoryTrendingProduct){
                              return Container(
                                  child: Center(
                                      child: Text(AppLocalizations.of(context)!.translate('no_trending_product')!, style: TextStyle(
                                          fontSize: 14,
                                          color: BLACK_GREY
                                      ))
                                  )
                              );
                            } else {
                              if(categoryTrendingProductData.length==0){
                                return _shimmerLoading.buildShimmerHorizontalProduct(boxImageSize);
                              } else {
                                return ListView.builder(
                                  padding: EdgeInsets.only(left: 12, right: 12),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: categoryTrendingProductData.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return _globalWidget.buildHorizontalProductCard(context, categoryTrendingProductData[index]);
                                  },
                                );
                              }
                            }
                          }
                        },
                      )
                  ),
                  Container(
                    margin: EdgeInsets.only(top:20, left: 16, right: 16),
                    child: Text(AppLocalizations.of(context)!.translate('new_product')!, style: GlobalStyle.sectionTitle),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    height: boxImageSize*GlobalStyle.horizontalProductHeightMultiplication,
                    child: BlocBuilder<CategoryNewProductBloc, CategoryNewProductState>(
                      builder: (context, state) {
                        if(state is CategoryNewProductError) {
                          return Container(
                              child: Center(
                                  child: Text(ERROR_OCCURED, style: TextStyle(
                                      fontSize: 14,
                                      color: BLACK_GREY
                                  ))
                              )
                          );
                        } else {
                          if(_lastDataCategoryNewProduct){
                            return Container(
                                child: Center(
                                    child: Text(AppLocalizations.of(context)!.translate('no_new_product')!, style: TextStyle(
                                        fontSize: 14,
                                        color: BLACK_GREY
                                    ))
                                )
                            );
                          } else {
                            if(categoryNewProductData.length==0){
                              return _shimmerLoading.buildShimmerHorizontalProduct(boxImageSize);
                            } else {
                              return ListView.builder(
                                padding: EdgeInsets.only(left: 12, right: 12),
                                scrollDirection: Axis.horizontal,
                                itemCount: categoryNewProductData.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return _globalWidget.buildHorizontalProductCard(context, categoryNewProductData[index]);
                                },
                              );
                            }
                          }
                        }
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top:20, left: 16, right: 16),
                    child: Text(AppLocalizations.of(context)!.translate('all_product')!, style: GlobalStyle.sectionTitle),
                  ),
                  BlocBuilder<CategoryAllProductBloc, CategoryAllProductState>(
                    builder: (context, state) {
                      if (state is CategoryAllProductError) {
                        return Container(
                            child: Center(
                                child: Text(ERROR_OCCURED,
                                    style:
                                    TextStyle(fontSize: 14, color: BLACK_GREY))));
                      } else {
                        if (_lastDataCategoryAllProduct && _apiPageCategoryAllProduct == 0) {
                          return Container(
                              height: 200,
                              child: Center(
                                child: Text(AppLocalizations.of(context)!.translate('no_product')!,
                                    style: TextStyle(
                                        fontSize: 14, color: BLACK_GREY)),
                              ));
                        } else {
                          if (categoryAllProductData.length == 0) {
                            return _shimmerLoading.buildShimmerProduct(((MediaQuery.of(context).size.width) - 24) / 2 - 12);
                          } else {
                            return CustomScrollView(
                                shrinkWrap: true,
                                primary: false,
                                slivers: <Widget>[
                                  SliverPadding(
                                    padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                                    sliver: SliverGrid(
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 8,
                                        crossAxisSpacing: 8,
                                        childAspectRatio: GlobalStyle.gridDelegateRatio,
                                      ),
                                      delegate: SliverChildBuilderDelegate(
                                            (BuildContext context, int index) {
                                          return _globalWidget.buildProductGrid(context, categoryAllProductData[index]);
                                        },
                                        childCount: categoryAllProductData.length,
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: _globalWidget.buildProgressIndicator(_lastDataCategoryAllProduct),
                                  ),
                                ]);
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }

  Widget _createCategorySlider(){
    double categoryBannerWidth = MediaQuery.of(context).size.width;
    double categoryBannerHeight = MediaQuery.of(context).size.width/2;

    return BlocBuilder<CategoryBannerBloc, CategoryBannerState>(
      builder: (context, state) {
        if(state is CategoryBannerError) {
          return Container(
              width: categoryBannerWidth,
              height: categoryBannerHeight,
              child: Center(
                  child: Text(ERROR_OCCURED, style: TextStyle(
                      fontSize: 14,
                      color: BLACK_GREY
                  ))
              )
          );
        } else {
          if(_lastDataCategoryBanner){
            return Wrap();
          } else {
            if(categoryBannerData.length==0){
              return _shimmerLoading.buildShimmerCategoryBanner(categoryBannerWidth, categoryBannerHeight);
            } else {
              return Stack(
                children: [
                  CarouselSlider(
                    items: categoryBannerData.map((item) => Container(
                      child: buildCacheNetworkImage(width: 0, height: 0, url: item.image),
                    )).toList(),
                    options: CarouselOptions(
                        aspectRatio: 2,
                        viewportFraction: 1.0,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 6),
                        autoPlayAnimationDuration: Duration(milliseconds: 300),
                        enlargeCenterPage: false,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentImageSlider = index;
                          });
                        }
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: categoryBannerData.map((item) {
                          int index = categoryBannerData.indexOf(item);
                          return Container(
                            width: 8.0,
                            height: 8.0,
                            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageSlider == index
                                  ? SOFT_BLUE
                                  : Colors.grey[300],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              );
            }
          }
        }
      },
    );
  }

  Future refreshData() async {
    setState(() {
      _apiPageCategoryAllProduct = 0;
      _lastDataCategoryBanner = false;
      _lastDataCategoryTrendingProduct = false;
      _lastDataCategoryNewProduct = false;
      _lastDataCategoryAllProduct = false;
      categoryBannerData.clear();
      categoryTrendingProductData.clear();
      categoryNewProductData.clear();
      categoryAllProductData.clear();
      _categoryBannerBloc.add(GetCategoryBanner(sessionId: SESSION_ID, categoryId: widget.categoryId, apiToken: apiToken));
      _categoryTrendingProductBloc.add(GetCategoryTrendingProduct(sessionId: SESSION_ID, categoryId: widget.categoryId, skip: '0', limit: '8', apiToken: apiToken));
      _categoryNewProductBloc.add(GetCategoryNewProduct(sessionId: SESSION_ID, categoryId: widget.categoryId, skip: '0', limit: '8', apiToken: apiToken));
      _categoryAllProductBloc.add(GetCategoryAllProduct(sessionId: SESSION_ID, categoryId: widget.categoryId, skip: _apiPageCategoryAllProduct.toString(), limit: LIMIT_PAGE.toString(), apiToken: apiToken));
    });
  }
}
