import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:hello_gas/model/account/address_model.dart';
import 'package:hello_gas/network/api_provider.dart';
import './bloc.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  AddressBloc() : super(InitialAddressState());

  @override
  Stream<AddressState> mapEventToState(
    AddressEvent event,
  ) async* {
    if(event is GetAddress){
      yield* _getAddress(event.sessionId, event.apiToken);
    }
  }
}

Stream<AddressState> _getAddress(String sessionId, apiToken) async* {
  ApiProvider _apiProvider = ApiProvider();

  yield AddressWaiting();
  try {
    List<AddressModel> data = await _apiProvider.getAddress(sessionId, apiToken);
    yield GetAddressSuccess(addressData: data);
  } catch (ex){
    if(ex != 'cancel'){
      yield AddressError(errorMessage: ex.toString());
    }
  }
}