/*
This is search page

include file in reuseable/global_function.dart to call function from GlobalFunction
include file in reuseable/shimmer_loading.dart to use shimmer loading
include file in reuseable/cache_image_network.dart to use cache image network
include file in model/account/last_seen_model.dart to get lastSeenData
include file in model/home/search/search_model.dart to get searchData

Don't forget to add all images and sound used in this pages at the pubspec.yaml
 */

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hello_gas/bloc/account/last_seen_product/bloc.dart';
import 'package:hello_gas/bloc/home/search/search/bloc.dart';
import 'package:hello_gas/config/constants.dart';
import 'package:hello_gas/config/global_style.dart';
import 'package:hello_gas/model/account/last_seen_model.dart';
import 'package:hello_gas/model/home/search/search_model.dart';
import 'package:hello_gas/ui/general/product_detail/product_detail.dart';
import 'package:hello_gas/ui/reuseable/app_localizations.dart';
import 'package:hello_gas/ui/reuseable/cache_image_network.dart';
import 'package:hello_gas/ui/home/search/search_product.dart';
import 'package:hello_gas/ui/reuseable/global_function.dart';
import 'package:hello_gas/ui/reuseable/shimmer_loading.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // initialize global function and shimmer loading
  final _globalFunction = GlobalFunction();
  final _shimmerLoading = ShimmerLoading();

  List<SearchModel> searchData = [];

  late SearchBloc _searchBloc;
  bool _lastDataSearch = false;

  CancelToken apiToken = CancelToken(); // used to cancel fetch data from API

  TextEditingController _etSearch = TextEditingController();

  List<LastSeenModel> lastSeenData = [];
  late LastSeenProductBloc _lastSeenProductBloc;

  bool _lastData = false;

  @override
  void initState() {
    // get data when initState
    _searchBloc = BlocProvider.of<SearchBloc>(context);
    _searchBloc.add(GetSearch(sessionId: SESSION_ID, apiToken: apiToken));

    _lastSeenProductBloc = BlocProvider.of<LastSeenProductBloc>(context);
    _lastSeenProductBloc.add(GetLastSeenProduct(sessionId: SESSION_ID, skip: '0', limit: '10', apiToken: apiToken));
    
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
    final double boxImageSize = (MediaQuery.of(context).size.width / 7);
    return Scaffold(
        appBar: AppBar(
            titleSpacing: 0.0,
            iconTheme: IconThemeData(
              color: GlobalStyle.appBarIconThemeColor,
            ),
            elevation: GlobalStyle.appBarElevation,
            backgroundColor: GlobalStyle.appBarBackgroundColor,
            brightness: GlobalStyle.appBarBrightness,
            // create search text field in the app bar
            title: Container(
              margin: EdgeInsets.only(right: 16),
              height: kToolbarHeight - 20,
              child: TextField(
                controller: _etSearch,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: (textValue) {
                  setState(() {});
                },
                maxLines: 1,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                decoration: InputDecoration(
                  prefixIcon:
                      Icon(Icons.search, color: Colors.grey[500], size: 18),
                  suffixIcon: (_etSearch.text == '')
                      ? null
                      : GestureDetector(
                          onTap: () {
                            setState(() {
                              _etSearch = TextEditingController(text: '');
                            });
                          },
                          child: Icon(Icons.close,
                              color: Colors.grey[500], size: 18)),
                  contentPadding: EdgeInsets.all(0),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: AppLocalizations.of(context)!.translate('search_product_small')!,
                ),
              ),
            )),
        body: WillPopScope(
          onWillPop: () {
            Navigator.pop(context);
            FocusScope.of(context).unfocus();
            return Future.value(true);
          },
          // if search field is empty, show history search
          // if search field not empty, show search text
          child: _etSearch.text == ''
              ? _showHistorySearch(boxImageSize)
              : _showSearchText(),
        ));
  }

  Widget _showHistorySearch(boxImageSize){
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(AppLocalizations.of(context)!.translate('last_seen_product')!, style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.bold
        )),
        Container(
          margin: EdgeInsets.only(top: 8),
          height: boxImageSize,
          child: BlocListener<LastSeenProductBloc, LastSeenProductState>(
            listener: (context, state) {
              if(state is LastSeenProductError) {
                _globalFunction.showToast(type: 'error', message: state.errorMessage);
              }
              if(state is GetLastSeenProductSuccess) {
                lastSeenData.addAll(state.lastSeenData);
              }
            },
            child: BlocBuilder<LastSeenProductBloc, LastSeenProductState>(
              builder: (context, state) {
                if(state is LastSeenProductError) {
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
                            child: Text(AppLocalizations.of(context)!.translate('no_last_seen_product')!, style: TextStyle(
                                fontSize: 14,
                                color: BLACK_GREY
                            ))
                        )
                    );
                  } else {
                    if(lastSeenData.length==0){
                      return _shimmerLoading.buildShimmerImageHorizontal(boxImageSize);
                    } else {
                      return ListView.builder(
                        padding: EdgeInsets.only(right: 12),
                        scrollDirection: Axis.horizontal,
                        itemCount: lastSeenData.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _buildLastSeenCard(index, boxImageSize);
                        },
                      );
                    }
                  }
                }
              },
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 32),
          child: Text(AppLocalizations.of(context)!.translate('last_search')!, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
        BlocListener<SearchBloc, SearchState>(
          listener: (context, state) {
            if(state is SearchError) {
              _globalFunction.showToast(type: 'error', message: state.errorMessage);
            }
            if(state is GetSearchSuccess) {
              if(state.searchData.length==0){
                _lastDataSearch = true;
              } else {
                searchData.addAll(state.searchData);
              }
            }
          },
          child: BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              if(state is SearchError) {
                return Container(
                    child: Center(
                        child: Text(ERROR_OCCURED, style: TextStyle(
                            fontSize: 14,
                            color: BLACK_GREY
                        ))
                    )
                );
              } else {
                if(_lastDataSearch){
                  return Container(
                      child: Center(
                          child: Text(AppLocalizations.of(context)!.translate('no_search_data')!, style: TextStyle(
                              fontSize: 14,
                              color: BLACK_GREY
                          ))
                      )
                  );
                } else {
                  if(searchData.length==0){
                    return _shimmerLoading.buildShimmerSearch();
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: searchData.length,
                          // Add one more item for progress indicator
                          padding: EdgeInsets.symmetric(vertical: 0),
                          itemBuilder: (BuildContext context, int index) {
                            return _buildLastSearchList(index);
                          },
                        ),
                      ],
                    );
                  }
                }
              }
            },
          ),
        )
      ],
    );
  }

  Widget _showSearchText(){
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Container(
          margin: EdgeInsets.only(top: 16),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              setState(() {
                int idx = searchData.indexWhere((data) => data.words==_etSearch.text);
                if(idx==-1){
                  if(searchData.length==5){
                    searchData.removeLast();
                  }
                  searchData.insert(0, SearchModel(id: 1, words: _etSearch.text));
                } else {
                  searchData.removeAt(idx);
                  searchData.insert(0, SearchModel(id: 1, words: _etSearch.text));
                }
              });
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SearchProductPage(words: _etSearch.text)));
            },
            child: Row(
              children: [
                Icon(Icons.access_time, color: SOFT_GREY, size: 16),
                SizedBox(width: 12),
                Text(_etSearch.text, style: TextStyle(color: CHARCOAL)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLastSeenCard(index, boxImageSize){
    return Container(
      margin: EdgeInsets.only(left: index == 0 ? 0 : 12),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailPage(name: lastSeenData[index].name, image: lastSeenData[index].image, price: lastSeenData[index].price, rating: lastSeenData[index].rating, review: lastSeenData[index].review, sale: lastSeenData[index].sale)));
        },
        child: ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            child: buildCacheNetworkImage(width: boxImageSize, height: boxImageSize, url: lastSeenData[index].image)),
      ),
    );
  }
  
  Widget _buildLastSearchList(index){
    return Container(
      margin: EdgeInsets.only(top: 16),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SearchProductPage(words: searchData[index].words)));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Container(
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: SOFT_GREY, size: 16),
                    SizedBox(width: 12),
                    Flexible(
                      child: Text(searchData[index].words,
                          style: TextStyle(color: CHARCOAL), overflow: TextOverflow.ellipsis, maxLines: 1),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
                onTap: (){
                  setState(() {
                    searchData.removeAt(index);
                  });
                },
                child: Icon(Icons.close, color: BLACK_GREY, size: 18)
            ),
          ],
        ),
      ),
    );
  }
}
