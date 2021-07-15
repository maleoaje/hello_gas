import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:hello_gas/model/home/category/category_trending_product_model.dart';
import 'package:hello_gas/network/api_provider.dart';
import './bloc.dart';

class CategoryTrendingProductBloc extends Bloc<CategoryTrendingProductEvent, CategoryTrendingProductState> {
  CategoryTrendingProductBloc() : super(InitialCategoryTrendingProductState());

  @override
  Stream<CategoryTrendingProductState> mapEventToState(
    CategoryTrendingProductEvent event,
  ) async* {
    if(event is GetCategoryTrendingProduct){
      yield* _getCategoryTrendingProduct(event.sessionId, event.categoryId, event.skip, event.limit, event.apiToken);
    }
  }
}

Stream<CategoryTrendingProductState> _getCategoryTrendingProduct(String sessionId, int categoryId, String skip, String limit, apiToken) async* {
  ApiProvider _apiProvider = ApiProvider();

  yield CategoryTrendingProductWaiting();
  try {
    List<CategoryTrendingProductModel> data = await _apiProvider.getCategoryTrendingProduct(sessionId, categoryId, skip, limit, apiToken);
    yield GetCategoryTrendingProductSuccess(categoryTrendingProductData: data);
  } catch (ex){
    if(ex != 'cancel'){
      yield CategoryTrendingProductError(errorMessage: ex.toString());
    }
  }
}