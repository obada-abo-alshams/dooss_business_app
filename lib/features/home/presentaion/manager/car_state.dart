import '../../data/models/car_model.dart';

class CarState {
  final bool isLoading;
  final String? error;
  final CarModel? selectedCar;
  final List<CarModel> similarCars;
  
  // Fields for car listing
  final List<CarModel> cars;
  final List<CarModel> allCars;
  final String selectedBrand;
  final int currentPage;
  final bool hasMoreCars;
  final bool isLoadingMore;

  const CarState({
    this.isLoading = false,
    this.error,
    this.selectedCar,
    this.similarCars = const [],
    this.cars = const [],
    this.allCars = const [],
    this.selectedBrand = '',
    this.currentPage = 1,
    this.hasMoreCars = true,
    this.isLoadingMore = false,
  });

  CarState copyWith({
    bool? isLoading,
    String? error,
    CarModel? selectedCar,
    List<CarModel>? similarCars,
    List<CarModel>? cars,
    List<CarModel>? allCars,
    String? selectedBrand,
    int? currentPage,
    bool? hasMoreCars,
    bool? isLoadingMore,
  }) {
    return CarState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedCar: selectedCar ?? this.selectedCar,
      similarCars: similarCars ?? this.similarCars,
      cars: cars ?? this.cars,
      allCars: allCars ?? this.allCars,
      selectedBrand: selectedBrand ?? this.selectedBrand,
      currentPage: currentPage ?? this.currentPage,
      hasMoreCars: hasMoreCars ?? this.hasMoreCars,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CarState &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.selectedCar == selectedCar &&
        other.similarCars == similarCars &&
        other.cars == cars &&
        other.allCars == allCars &&
        other.selectedBrand == selectedBrand &&
        other.currentPage == currentPage &&
        other.hasMoreCars == hasMoreCars &&
        other.isLoadingMore == isLoadingMore;
  }

  @override
  int get hashCode {
    return Object.hash(
      isLoading,
      error,
      selectedCar,
      Object.hashAll(similarCars),
      Object.hashAll(cars),
      Object.hashAll(allCars),
      selectedBrand,
      currentPage,
      hasMoreCars,
      isLoadingMore,
    );
  }
}
