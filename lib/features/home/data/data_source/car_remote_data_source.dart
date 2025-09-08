import 'package:dartz/dartz.dart';
import '../../../../core/network/failure.dart';
import '../../../../core/network/api_urls.dart';
import '../../../../core/network/app_dio.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/car_model.dart';

abstract class CarRemoteDataSource {
  Future<Either<Failure, List<CarModel>>> fetchCars();
  Future<Either<Failure, CarModel>> fetchCarDetails(int carId);
  Future<Either<Failure, List<CarModel>>> fetchSimilarCars(int carId);
}

class CarRemoteDataSourceImpl implements CarRemoteDataSource {
  final AppDio _dio;

  CarRemoteDataSourceImpl(this._dio);

  @override
  Future<Either<Failure, List<CarModel>>> fetchCars() async {
    try {
      AppLogger.info('Fetching cars from API...', 'CarDataSource');
      final response = await _dio.dio.get(ApiUrls.cars);
      
      AppLogger.network('GET', ApiUrls.cars, response.statusCode);
      
      if (response.statusCode == 200) {
        final List<dynamic> carsData = response.data;
        final cars = carsData.map((json) => CarModel.fromJson(json)).toList();
        AppLogger.success('Successfully fetched ${cars.length} cars', 'CarDataSource');
        return Right(cars);
      } else {
        AppLogger.error('Failed to fetch cars: ${response.statusCode}', 'CarDataSource');
        return Left(Failure(message: 'Failed to fetch cars: ${response.statusCode}'));
      }
    } catch (e) {
      AppLogger.error('CarRemoteDataSource error', 'CarDataSource', e);
      return Left(Failure(message: 'Failed to fetch cars: $e'));
    }
  }

  @override
  Future<Either<Failure, CarModel>> fetchCarDetails(int carId) async {
    try {
      print('Fetching car details for ID: $carId');
      final response = await _dio.dio.get('${ApiUrls.cars}$carId/');
      
      print('Car details response: $response');
      
      if (response.statusCode == 200) {
        final car = CarModel.fromJson(response.data);
        return Right(car);
      } else {
        return Left(Failure(message: 'Failed to fetch car details'));
      }
    } catch (e) {
      print('CarRemoteDataSource error: $e');
      return Left(Failure(message: 'Failed to fetch car details: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CarModel>>> fetchSimilarCars(int carId) async {
    try {
      print('Fetching similar cars for car ID: $carId');
      final response = await _dio.dio.get('${ApiUrls.cars}$carId/similar/');
      
      print('Similar cars response: $response');
      
      if (response.statusCode == 200) {
        final List<dynamic> carsData = response.data;
        final cars = carsData.map((json) => CarModel.fromJson(json)).toList();
        return Right(cars);
      } else {
        return Left(Failure(message: 'Failed to fetch similar cars'));
      }
    } catch (e) {
      print('CarRemoteDataSource error: $e');
      return Left(Failure(message: 'Failed to fetch similar cars: $e'));
    }
  }
}
