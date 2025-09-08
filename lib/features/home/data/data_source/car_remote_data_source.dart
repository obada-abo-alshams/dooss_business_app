import 'package:dartz/dartz.dart';
import '../../../../core/network/failure.dart';
import '../../../../core/network/api_urls.dart';
import '../../../../core/network/app_dio.dart';
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
      print('Fetching cars from API...');
      final response = await _dio.dio.get(ApiUrls.cars);
      
      print('Cars response: $response');
      
      if (response.statusCode == 200) {
        final List<dynamic> carsData = response.data;
        final cars = carsData.map((json) => CarModel.fromJson(json)).toList();
        print('✅ Successfully fetched ${cars.length} cars');
        return Right(cars);
      } else {
        print('❌ Failed to fetch cars: ${response.statusCode}');
        return Left(Failure(message: 'Failed to fetch cars: Status ${response.statusCode}'));
      }
    } catch (e) {
      print('❌ CarRemoteDataSource error: $e');
      return Left(Failure(message: 'Network error: $e'));
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
