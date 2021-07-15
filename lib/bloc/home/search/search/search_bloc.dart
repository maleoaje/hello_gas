import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:hello_gas/model/home/search/search_model.dart';
import 'package:hello_gas/network/api_provider.dart';
import './bloc.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(InitialSearchState());

  @override
  Stream<SearchState> mapEventToState(
    SearchEvent event,
  ) async* {
    if(event is GetSearch){
      yield* _getSearch(event.sessionId, event.apiToken);
    }
  }
}

Stream<SearchState> _getSearch(String sessionId, apiToken) async* {
  ApiProvider _apiProvider = ApiProvider();

  yield SearchWaiting();
  try {
    List<SearchModel> data = await _apiProvider.getSearch(sessionId, apiToken);
    yield GetSearchSuccess(searchData: data);
  } catch (ex){
    if(ex != 'cancel'){
      yield SearchError(errorMessage: ex.toString());
    }
  }
}