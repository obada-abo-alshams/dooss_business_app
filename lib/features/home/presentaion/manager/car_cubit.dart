import 'package:dooss_business_app/core/cubits/optimized_cubit.dart';
import 'package:dooss_business_app/core/utils/app_logger.dart';
import '../../data/data_source/car_remote_data_source.dart';
import '../../data/models/car_model.dart';
import 'car_state.dart';

class CarCubit extends OptimizedCubit<CarState> {
  final CarRemoteDataSource _carRemoteDataSource;

  CarCubit(this._carRemoteDataSource) : super(const CarState());

  void loadCars() async {
    AppLogger.info('Starting to load cars', 'CarCubit');
    safeEmit(state.copyWith(isLoading: true, error: null));
    
    final result = await _carRemoteDataSource.fetchCars();
    
    result.fold(
      (failure) {
        AppLogger.error('Failed to load cars: ${failure.message}', 'CarCubit');
        safeEmit(state.copyWith(
          error: failure.message,
          isLoading: false,
        ));
      },
      (allCars) {
        AppLogger.success('Successfully fetched ${allCars.length} cars', 'CarCubit');
        final homeCars = allCars.take(10).toList();
        
        batchEmit((currentState) => currentState.copyWith(
          cars: homeCars,
          allCars: allCars,
          isLoading: false,
        ));
      },
    );
  }

  void loadAllCars() async {
    safeEmit(state.copyWith(isLoading: true, error: null, currentPage: 1));
    
    final result = await _carRemoteDataSource.fetchCars();
    
    result.fold(
      (failure) {
        safeEmit(state.copyWith(
          error: failure.message,
          isLoading: false,
        ));
      },
      (allCars) {
        final firstPageCars = allCars.take(10).toList();
        
        batchEmit((currentState) => currentState.copyWith(
          allCars: allCars,
          cars: firstPageCars,
          isLoading: false,
          currentPage: 1,
          hasMoreCars: allCars.length > 10,
        ));
      },
    );
  }

  void loadMoreCars() async {
    if (state.isLoadingMore || !state.hasMoreCars) return;
    
    safeEmit(state.copyWith(isLoadingMore: true));
    
    try {
      final nextPage = state.currentPage + 1;
      final startIndex = (nextPage - 1) * 10;
      final endIndex = startIndex + 10;
      
      if (startIndex < state.allCars.length) {
        final newCars = state.allCars.skip(startIndex).take(10).toList();
        final updatedCars = [...state.cars, ...newCars];
        
        batchEmit((currentState) => currentState.copyWith(
          cars: updatedCars,
          currentPage: nextPage,
          hasMoreCars: endIndex < state.allCars.length,
          isLoadingMore: false,
        ));
      } else {
        safeEmit(state.copyWith(
          hasMoreCars: false,
          isLoadingMore: false,
        ));
      }
    } catch (e) {
      safeEmit(state.copyWith(
        error: 'Failed to load more cars',
        isLoadingMore: false,
      ));
    }
  }

  void filterByBrand(String brand) {
    if (brand.isEmpty) {
      emitOptimized(state.copyWith(cars: state.allCars, selectedBrand: ''));
    } else {
      final filteredCars = state.allCars.where((car) => car.brand == brand).toList();
      emitOptimized(state.copyWith(
        cars: filteredCars,
        selectedBrand: brand,
      ));
    }
  }

  void clearFilters() {
    emitOptimized(state.copyWith(
      cars: state.allCars,
      selectedBrand: '',
    ));
  }

  void searchCars(String query) {
    if (query.isEmpty) {
      emitOptimized(state.copyWith(cars: state.allCars));
    } else {
      final searchResults = state.allCars
          .where((car) => 
              car.name.toLowerCase().contains(query.toLowerCase()) ||
              car.brand.toLowerCase().contains(query.toLowerCase()))
          .toList();
      emitOptimized(state.copyWith(cars: searchResults));
    }
  }

  void toggleFavorite(int carId) {
    final updatedCars = state.cars.map((car) {
      if (car.id == carId) {
        return car.copyWith(isFavorite: !car.isFavorite);
      }
      return car;
    }).toList();
    emitOptimized(state.copyWith(cars: updatedCars));
  }

  void showHomeCars() {
    if (state.allCars.isNotEmpty) {
      final homeCars = state.allCars.take(10).toList();
      emitOptimized(state.copyWith(cars: homeCars));
    }
  }

  // Get total number of cars available
  int get totalCarsCount => state.allCars.length;

  // Check if there are more cars to show
  bool get hasMoreCars => state.allCars.length > 10;

  Future<void> loadCarDetails(int carId) async {
    safeEmit(state.copyWith(isLoading: true, error: null));

    final result = await _carRemoteDataSource.fetchCarDetails(carId);

    result.fold(
      (failure) {
        safeEmit(state.copyWith(
          isLoading: false,
          error: failure.message,
        ));
      },
      (car) {
        safeEmit(state.copyWith(
          isLoading: false,
          selectedCar: car,
        ));
        
        _loadSimilarCars(carId);
      },
    );
  }

  Future<void> _loadSimilarCars(int carId) async {
    final result = await _carRemoteDataSource.fetchSimilarCars(carId);

    result.fold(
      (failure) {
        print('Failed to load similar cars: ${failure.message}');
      },
      (similarCars) {
        safeEmit(state.copyWith(similarCars: similarCars));
      },
    );
  }

  void clearError() {
    emitOptimized(state.copyWith(error: null));
  }
}
