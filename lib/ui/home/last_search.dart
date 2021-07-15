/*
This is last search page

include file in reuseable/global_function.dart to call function from GlobalFunction
include file in reuseable/global_widget.dart to call function from GlobalWidget
include file in reuseable/cache_image_network.dart to use cache image network
include file in reuseable/shimmer_loading.dart to use shimmer loading
include file in model/home/last_search_model.dart to get lastSearchData

Don't forget to add all images and sound used in this pages at the pubspec.yaml
 */

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hello_gas/bloc/home/last_search/bloc.dart';
import 'package:hello_gas/config/constants.dart';
import 'package:hello_gas/config/global_style.dart';
import 'package:hello_gas/model/home/last_search_model.dart';
import 'package:hello_gas/ui/reuseable/app_localizations.dart';
import 'package:hello_gas/ui/home/search/search.dart';
import 'package:hello_gas/ui/reuseable/global_function.dart';
import 'package:hello_gas/ui/reuseable/global_widget.dart';
import 'package:hello_gas/ui/reuseable/shimmer_loading.dart';

class LastSearchPage extends StatefulWidget {
  @override
  _LastSearchPageState createState() => _LastSearchPageState();
}

class _LastSearchPageState extends State<LastSearchPage> {
  // initialize global function, global widget and shimmer loading
  final _globalFunction = GlobalFunction();
  final _globalWidget = GlobalWidget();
  final _shimmerLoading = ShimmerLoading();

  List<LastSearchModel> lastSearchData = [];

  late LastSearchBloc _lastSearchBloc;
  int _apiPage = 0;
  ScrollController _scrollController = ScrollController();
  bool _lastData = false;
  bool _processApi = false;

  CancelToken apiToken = CancelToken(); // used to cancel fetch data from API

  @override
  void initState() {
    // get data when initState
    _lastSearchBloc = BlocProvider.of<LastSearchBloc>(context);
    _lastSearchBloc.add(GetLastSearch(sessionId: SESSION_ID, skip: _apiPage.toString(), limit: '10', apiToken: apiToken));

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
      if (_lastData == false && !_processApi) {
        _lastSearchBloc.add(GetLastSearch(sessionId: SESSION_ID, skip: _apiPage.toString(), limit: '10', apiToken: apiToken));
        _processApi = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: GlobalStyle.appBarIconThemeColor,
          ),
          elevation: GlobalStyle.appBarElevation,
          title: Text(
            AppLocalizations.of(context)!.translate('last_search')!,
            style: GlobalStyle.appBarTitle,
          ),
          backgroundColor: GlobalStyle.appBarBackgroundColor,
          brightness: GlobalStyle.appBarBrightness,
          actions: [
            IconButton(
                icon: Icon(Icons.search, color: BLACK_GREY),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SearchPage()));
                }),
          ],
          bottom: _globalWidget.bottomAppBar(),
        ),
        body: WillPopScope(
          onWillPop: () {
            Navigator.pop(context);
            return Future.value(true);
          },
          child: RefreshIndicator(
            onRefresh: refreshData,
            child: BlocListener<LastSearchBloc, LastSearchState>(
              listener: (context, state) {
                if (state is LastSearchError) {
                  _globalFunction.showToast(
                      type: 'error', message: state.errorMessage);
                }
                if (state is GetLastSearchSuccess) {
                  _scrollController.addListener(_onScroll);
                  if (state.lastSearchData.length == 0) {
                    _lastData = true;
                  } else {
                    _apiPage += 10;
                    lastSearchData.addAll(state.lastSearchData);
                  }
                  _processApi = false;
                }
              },
              child: BlocBuilder<LastSearchBloc, LastSearchState>(
                builder: (context, state) {
                  if (state is LastSearchError) {
                    return Container(
                        child: Center(
                            child: Text(ERROR_OCCURED,
                                style:
                                    TextStyle(fontSize: 14, color: BLACK_GREY))));
                  } else {
                    if (_lastData && _apiPage == 0) {
                      return Container(
                          child: Center(
                              child: Text(AppLocalizations.of(context)!.translate('no_last_search')!,
                                  style: TextStyle(
                                      fontSize: 14, color: BLACK_GREY))));
                    } else {
                      if (lastSearchData.length == 0) {
                        return _shimmerLoading.buildShimmerProduct(((MediaQuery.of(context).size.width) - 24) / 2 - 12);
                      } else {
                        return CustomScrollView(
                            shrinkWrap: true,
                            primary: false,
                            controller: _scrollController,
                            physics: AlwaysScrollableScrollPhysics(),
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
                                      return _globalWidget.buildProductGrid(context, lastSearchData[index]);
                                    },
                                    childCount: lastSearchData.length,
                                  ),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: _globalWidget.buildProgressIndicator(_lastData),
                              ),
                            ]);
                      }
                    }
                  }
                },
              ),
            ),
          ),
        ));
  }

  Future refreshData() async {
    setState(() {
      _apiPage = 0;
      _lastData = false;
      lastSearchData.clear();
      _lastSearchBloc.add(GetLastSearch(sessionId: SESSION_ID, skip: _apiPage.toString(), limit: '10', apiToken: apiToken));
    });
  }
}
