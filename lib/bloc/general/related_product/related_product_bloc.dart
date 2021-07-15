import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:hello_gas/model/general/related_product_model.dart';
import 'package:hello_gas/network/api_provider.dart';
import './bloc.dart';

class RelatedProductBloc extends Bloc<RelatedProductEvent, RelatedProductState> {
  RelatedProductBloc() : super(InitialRelatedProductState());

  @override
  Stream<RelatedProductState> mapEventToState(
    RelatedProductEvent event,
  ) async* {
    if(event is GetRelatedProduct){
      yield* _getRelatedProduct(event.sessionId, event.apiToken);
    }
  }
}

Stream<RelatedProductState> _getRelatedProduct(String sessionId, apiToken) async* {
  ApiProvider _apiProvider = ApiProvider();

  yield RelatedProductWaiting();
  try {
    List<RelatedProductModel> data = await _apiProvider.getRelatedProduct(sessionId, apiToken);
    yield GetRelatedProductSuccess(relatedProductData: data);
  } catch (ex){
    if(ex != 'cancel'){
      yield RelatedProductError(errorMessage: ex.toString());
    }
  }
}