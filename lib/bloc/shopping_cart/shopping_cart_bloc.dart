import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:hello_gas/model/shopping_cart/shopping_cart_model.dart';
import 'package:hello_gas/network/api_provider.dart';
import './bloc.dart';

class ShoppingCartBloc extends Bloc<ShoppingCartEvent, ShoppingCartState> {
  ShoppingCartBloc() : super(InitialShoppingCartState());

  @override
  Stream<ShoppingCartState> mapEventToState(
    ShoppingCartEvent event,
  ) async* {
    if(event is GetShoppingCart){
      yield* _getShoppingCart(event.sessionId, event.apiToken);
    }
  }
}

Stream<ShoppingCartState> _getShoppingCart(String sessionId, apiToken) async* {
  ApiProvider _apiProvider = ApiProvider();

  yield ShoppingCartWaiting();
  try {
    List<ShoppingCartModel> data = await _apiProvider.getShoppingCart(sessionId, apiToken);
    yield GetShoppingCartSuccess(shoppingCartData: data);
  } catch (ex){
    if(ex != 'cancel'){
      yield ShoppingCartError(errorMessage: ex.toString());
    }
  }
}