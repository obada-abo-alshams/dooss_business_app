import 'package:dooss_business_app/core/cubits/optimized_cubit.dart';
import '../../data/data_source/car_remote_data_source.dart';
import '../../data/models/car_model.dart';
import 'car_state.dart';

/// Refactored CarCubit with proper state management and clean architecture principles
/// 
/// Key improvements:
/// - All emit calls are protected with isClosed checks
/// - Uses Either.fold pattern for error handling (no try-catch)
/// - Optimized state emissions for better performance
/// - Proper async operation handling to prevent state emission after disposal
class CarCubit extends OptimizedCubit<CarState> {
  final CarRemoteDataSource _carRemoteDataSource;

  CarCubit(this._carRemoteDataSource) : super(const CarState());

  /// Load cars for home screen (first 10 items)
  /// Uses Either.fold pattern for clean error handling
  void loadCars() async {
    // Check if cubit is still active before starting
    if (isClosed) return;
    
    print('🚀 CarCubit - Starting to load cars');
    safeEmit(state.copyWith(isLoading: true, error: null));
    
    final result = await _carRemoteDataSource.fetchCars();
    
    // Use fold pattern for clean architecture error handling
    result.fold(
      (failure) {
        // Handle failure case - only emit if cubit is still active
        if (!isClosed) {
          print('❌ CarCubit - Failed to load cars: ${failure.message}');
          safeEmit(state.copyWith(
            error: failure.message,
            isLoading: false,
          ));
        }
      },
      (allCars) {
        // Handle success case - only emit if cubit is still active
        if (!isClosed) {
          print('✅ CarCubit - Successfully fetched ${allCars.length} cars');
          final homeCars = allCars.take(10).toList();
          
          // Use batchEmit for complex state updates (already has isClosed check)
          batchEmit((currentState) => currentState.copyWith(
            cars: homeCars,
            allCars: allCars,
            isLoading: false,
            error: null, // Clear any previous errors
          ));
        }
      },
    );
  }

  /// Load all cars for "See All Cars" screen with pagination
  /// Protected against state emission after disposal
  void loadAllCars() async {
    if (isClosed) return;
    
    safeEmit(state.copyWith(isLoading: true, error: null, currentPage: 1));
    
    final result = await _carRemoteDataSource.fetchCars();
    
    result.fold(
      (failure) {
        if (!isClosed) {
          safeEmit(state.copyWith(
            error: failure.message,
            isLoading: false,
          ));
        }
      },
      (allCars) {
        if (!isClosed) {
          final firstPageCars = allCars.take(10).toList();
          
          batchEmit((currentState) => currentState.copyWith(
            allCars: allCars,
            cars: firstPageCars,
            isLoading: false,
            currentPage: 1,
            hasMoreCars: allCars.length > 10,
            error: null,
          ));
        }
      },
    );
  }

  /// Load more cars for pagination
  /// Uses local data so no API call, but still needs disposal protection
  void loadMoreCars() async {
    if (isClosed || state.isLoadingMore || !state.hasMoreCars) return;
    
    safeEmit(state.copyWith(isLoadingMore: true));
    
    // Simulate small delay for better UX
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Double-check cubit is still active after delay
    if (isClosed) return;
    
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
  }

  /// Filter cars by brand - local operation
  void filterByBrand(String brand) {
    if (isClosed) return;
    
    if (brand.isEmpty) {
      emitOptimized(state.copyWith(
        cars: state.allCars, 
        selectedBrand: '',
      ));
    } else {
      final filteredCars = state.allCars
          .where((car) => car.brand.toLowerCase() == brand.toLowerCase())
          .toList();
      
      emitOptimized(state.copyWith(
        cars: filteredCars,
        selectedBrand: brand,
      ));
    }
  }

  /// Clear all filters - local operation
  void clearFilters() {
    if (isClosed) return;
    
    emitOptimized(state.copyWith(
      cars: state.allCars,
      selectedBrand: '',
    ));
  }

  /// Search cars by name or brand - local operation
  void searchCars(String query) {
    if (isClosed) return;
    
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

  /// Toggle favorite status for a car - local operation
  void toggleFavorite(int carId) {
    if (isClosed) return;
    
    final updatedCars = state.cars.map((car) {
      if (car.id == carId) {
        return car.copyWith(isFavorite: !car.isFavorite);
      }
      return car;
    }).toList();
    
    emitOptimized(state.copyWith(cars: updatedCars));
  }

  /// Show home cars (first 10) - local operation
  void showHomeCars() {
    if (isClosed) return;
    
    if (state.allCars.isNotEmpty) {
      final homeCars = state.allCars.take(10).toList();
      emitOptimized(state.copyWith(cars: homeCars));
    }
  }

  /// Load car details for car details screen
  /// Uses Either.fold pattern with proper disposal protection
  Future<void> loadCarDetails(int carId) async {
    if (isClosed) return;
    
    safeEmit(state.copyWith(isLoading: true, error: null));

    final result = await _carRemoteDataSource.fetchCarDetails(carId);

    result.fold(
      (failure) {
        if (!isClosed) {
          safeEmit(state.copyWith(
            isLoading: false,
            error: failure.message,
          ));
        }
      },
      (car) {
        if (!isClosed) {
          safeEmit(state.copyWith(
            isLoading: false,
            selectedCar: car,
            error: null,
          ));
          
          // Load similar cars asynchronously without blocking main car details
          _loadSimilarCars(carId);
        }
      },
    );
  }

  /// Load similar cars asynchronously
  /// Protected against disposal and uses Either.fold pattern
  Future<void> _loadSimilarCars(int carId) async {
    // Early return if cubit is already closed
    if (isClosed) return;
    
    final result = await _carRemoteDataSource.fetchSimilarCars(carId);

    result.fold(
      (failure) {
        // Don't emit error for similar cars, just log it
        print('Failed to load similar cars: ${failure.message}');
      },
      (similarCars) {
        // Only emit if cubit is still active
        if (!isClosed) {
          safeEmit(state.copyWith(similarCars: similarCars));
        }
      },
    );
  }

  /// Clear error state - local operation
  void clearError() {
    if (isClosed) return;
    
    emitOptimized(state.copyWith(error: null));
  }

  /// Reset to initial state - local operation
  void resetState() {
    if (isClosed) return;
    
    emitOptimized(const CarState());
  }

  /// Get total number of cars available - getter (no state emission)
  int get totalCarsCount => state.allCars.length;

  /// Check if there are more cars to show - getter (no state emission)
  bool get hasMoreCars => state.allCars.length > 10;

  /// Check if currently loading - getter (no state emission)
  bool get isLoading => state.isLoading;

  /// Check if there's an error - getter (no state emission)
  bool get hasError => state.error != null;

  /// Get current error message - getter (no state emission)
  String? get errorMessage => state.error;

  /// Override close to add logging and ensure proper cleanup
  @override
  Future<void> close() {
    print('🔒 CarCubit - Closing and cleaning up resources');
    return super.close();
  }
}
