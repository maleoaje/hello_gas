import 'package:hello_gas/model/home/flashsale_model.dart';
import 'package:meta/meta.dart';

@immutable
abstract class FlashsaleState {}

class InitialFlashsaleState extends FlashsaleState {}

class FlashsaleError extends FlashsaleState {
  final String errorMessage;

  FlashsaleError({
    required this.errorMessage,
  });
}

class FlashsaleHomeError extends FlashsaleState {
  final String errorMessage;

  FlashsaleHomeError({
    required this.errorMessage,
  });
}

class FlashsaleWaiting extends FlashsaleState {}

class FlashsaleHomeWaiting extends FlashsaleState {}

class GetFlashsaleSuccess extends FlashsaleState {
  final List<FlashsaleModel> flashsaleData;
  GetFlashsaleSuccess({required this.flashsaleData});
}

class GetFlashsaleHomeSuccess extends FlashsaleState {
  final List<FlashsaleModel> flashsaleData;
  GetFlashsaleHomeSuccess({required this.flashsaleData});
}