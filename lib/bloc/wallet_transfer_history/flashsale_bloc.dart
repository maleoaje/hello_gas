import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:hello_gas/model/account/wallet_transfer_history_model.dart';
import 'package:hello_gas/network/api_provider.dart';
import './bloc.dart';

class WalletTransferBloc extends Bloc<FlashsaleEvent, FlashsaleState> {
  WalletTransferBloc() : super(InitialFlashsaleState());

  @override
  Stream<FlashsaleState> mapEventToState(
    FlashsaleEvent event,
  ) async* {
    if (event is GetFlashsaleHome) {
      yield* _getFlashsaleHome(
          event.sessionId, event.skip, event.limit, event.apiToken);
    } else if (event is GetFlashsale) {
      yield* _getFlashsale(
          event.sessionId, event.skip, event.limit, event.apiToken);
    }
  }
}

Stream<FlashsaleState> _getFlashsaleHome(
    String sessionId, String skip, String limit, apiToken) async* {
  ApiProvider _apiProvider = ApiProvider();

  yield FlashsaleHomeWaiting();
  List<WalletTransferModel> data = await _apiProvider.getWalletTransferHistory(
      sessionId, skip, limit, apiToken);
  yield GetFlashsaleHomeSuccess(flashsaleData: data);
}

Stream<FlashsaleState> _getFlashsale(
    String sessionId, String skip, String limit, apiToken) async* {
  ApiProvider _apiProvider = ApiProvider();

  yield FlashsaleWaiting();
  List<WalletTransferModel> data = await _apiProvider.getWalletTransferHistory(
      sessionId, skip, limit, apiToken);
  yield GetFlashsaleSuccess(flashsaleData: data);
}
