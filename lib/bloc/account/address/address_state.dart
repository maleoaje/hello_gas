import 'package:hello_gas/model/account/address_model.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AddressState {}

class InitialAddressState extends AddressState {}

class AddressError extends AddressState {
  final String errorMessage;

  AddressError({
    required this.errorMessage,
  });
}

class AddressWaiting extends AddressState {}

class GetAddressSuccess extends AddressState {
  final List<AddressModel> addressData;
  GetAddressSuccess({required this.addressData});
}