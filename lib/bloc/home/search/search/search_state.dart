import 'package:hello_gas/model/home/search/search_model.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SearchState {}

class InitialSearchState extends SearchState {}

class SearchError extends SearchState {
  final String errorMessage;

  SearchError({
    required this.errorMessage,
  });
}

class SearchWaiting extends SearchState {}

class GetSearchSuccess extends SearchState {
  final List<SearchModel> searchData;
  GetSearchSuccess({required this.searchData});
}