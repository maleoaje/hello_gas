import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:hello_gas/model/home/last_search_model.dart';
import 'package:hello_gas/network/api_provider.dart';
import './bloc.dart';

class LastSearchBloc extends Bloc<LastSearchEvent, LastSearchState> {
  LastSearchBloc() : super(InitialLastSearchState());

  @override
  Stream<LastSearchState> mapEventToState(
    LastSearchEvent event,
  ) async* {
    if(event is GetLastSearchHome){
      yield* _getLastSearchHome(event.sessionId, event.skip, event.limit, event.apiToken);
    } else if(event is GetLastSearch){
      yield* _getLastSearch(event.sessionId, event.skip, event.limit, event.apiToken);
    }
  }
}

Stream<LastSearchState> _getLastSearchHome(String sessionId, String skip, String limit, apiToken) async* {
  ApiProvider _apiProvider = ApiProvider();

  yield LastSearchHomeWaiting();
  try {
    List<LastSearchModel> data = await _apiProvider.getLastSearch(sessionId, skip, limit, apiToken);
    yield GetLastSearchHomeSuccess(lastSearchData: data);
  } catch (ex){
    if(ex != 'cancel'){
      yield LastSearchHomeError(errorMessage: ex.toString());
    }
  }
}

Stream<LastSearchState> _getLastSearch(String sessionId, String skip, String limit, apiToken) async* {
  ApiProvider _apiProvider = ApiProvider();

  yield LastSearchWaiting();
  try {
    List<LastSearchModel> data = await _apiProvider.getLastSearchInfinite(sessionId, skip, limit, apiToken);
    yield GetLastSearchSuccess(lastSearchData: data);
  } catch (ex){
    if(ex != 'cancel'){
      yield LastSearchError(errorMessage: ex.toString());
    }
  }
}