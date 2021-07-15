import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:hello_gas/model/home/category/category_all_product_model.dart';
import 'package:hello_gas/network/api_provider.dart';
import './bloc.dart';

class CategoryAllProductBloc extends Bloc<CategoryAllProductEvent, CategoryAllProductState> {
  CategoryAllProductBloc() : super(InitialCategoryAllProductState());

  @override
  Stream<CategoryAllProductState> mapEventToState(
    CategoryAllProductEvent event,
  ) async* {
    if(event is GetCategoryAllProduct){
      yield* _getCategoryAllProduct(event.sessionId, event.categoryId, event.skip, event.limit, event.apiToken);
    }
  }
}

Stream<CategoryAllProductState> _getCategoryAllProduct(String sessionId, int categoryId, String skip, String limit, apiToken) async* {
  ApiProvider _apiProvider = ApiProvider();

  yield CategoryAllProductWaiting();
  try {
    List<CategoryAllProductModel> data = await _apiProvider.getCategoryAllProduct(sessionId, categoryId, skip, limit, apiToken);
    yield GetCategoryAllProductSuccess(categoryAllProductData: data);
  } catch (ex){
    if(ex != 'cancel'){
      yield CategoryAllProductError(errorMessage: ex.toString());
    }
  }
}
