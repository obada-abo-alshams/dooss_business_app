import '../../data/models/dealer_model.dart';
import '../../data/models/reel_model.dart';
import '../../data/models/service_model.dart';
import '../../../home/data/models/car_model.dart';

class DealerProfileState {
  final DealerModel? dealer;
  final List<ReelModel> reels;
  final List<CarModel> cars;
  final List<ServiceModel> services;
  final bool isLoading;
  final bool isLoadingReels;
  final bool isLoadingCars;
  final bool isLoadingServices;
  final String? error;

  const DealerProfileState({
    this.dealer,
    this.reels = const [],
    this.cars = const [],
    this.services = const [],
    this.isLoading = false,
    this.isLoadingReels = false,
    this.isLoadingCars = false,
    this.isLoadingServices = false,
    this.error,
  });

  DealerProfileState copyWith({
    DealerModel? dealer,
    List<ReelModel>? reels,
    List<CarModel>? cars,
    List<ServiceModel>? services,
    bool? isLoading,
    bool? isLoadingReels,
    bool? isLoadingCars,
    bool? isLoadingServices,
    String? error,
  }) {
    return DealerProfileState(
      dealer: dealer ?? this.dealer,
      reels: reels ?? this.reels,
      cars: cars ?? this.cars,
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
      isLoadingReels: isLoadingReels ?? this.isLoadingReels,
      isLoadingCars: isLoadingCars ?? this.isLoadingCars,
      isLoadingServices: isLoadingServices ?? this.isLoadingServices,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DealerProfileState &&
        other.dealer == dealer &&
        other.reels == reels &&
        other.cars == cars &&
        other.services == services &&
        other.isLoading == isLoading &&
        other.isLoadingReels == isLoadingReels &&
        other.isLoadingCars == isLoadingCars &&
        other.isLoadingServices == isLoadingServices &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      dealer,
      Object.hashAll(reels),
      Object.hashAll(cars),
      Object.hashAll(services),
      isLoading,
      isLoadingReels,
      isLoadingCars,
      isLoadingServices,
      error,
    );
  }
}
