import 'package:hello_gas/model/home/home_banner_model.dart';
import 'package:meta/meta.dart';

@immutable
abstract class HomeBannerState {}

class InitialHomeBannerState extends HomeBannerState {}

class HomeBannerError extends HomeBannerState {
  final String errorMessage;

  HomeBannerError({
    required this.errorMessage,
  });
}

class HomeBannerWaiting extends HomeBannerState {}

class GetHomeBannerSuccess extends HomeBannerState {
  final List<HomeBannerModel> homeBannerData;
  GetHomeBannerSuccess({required this.homeBannerData});
}