import 'package:dartz/dartz.dart';
import 'package:dooss_business_app/core/network/api.dart';
import 'package:dooss_business_app/core/network/api_request.dart';
import 'package:dooss_business_app/core/network/api_urls.dart';
import 'package:dooss_business_app/core/network/failure.dart';
import 'package:dooss_business_app/features/home/data/models/product_model.dart';
import 'product_remote_data_source.dart';

class ProductRemoteDataSourceImp implements ProductRemoteDataSource {
  final API api;
  ProductRemoteDataSourceImp({required this.api});

  @override
  Future<Either<Failure, List<ProductModel>>> fetchProducts() async {
    print('Fetching products from API...');
    final response = await api.get(
      apiRequest: ApiRequest(url: ApiUrls.products),
    );
    print('API response: $response');
    
    return response.fold(
      (failure) {
        print('Failure: ${failure.message}');
        return Left(failure);
      },
      (data) {
        print('Data received: $data');
        if (data is List) {
          final products = data.map((e) => ProductModel.fromJson(e)).toList();
          return Right(products);
        } else {
          print('Invalid data format received from API');
          return Left(Failure(message: 'Invalid data format received from API'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, List<ProductModel>>> fetchProductsByCategory(String category) async {
    print('Fetching products by category from API...');
    final response = await api.get(
      apiRequest: ApiRequest(url: '${ApiUrls.products}?category=$category'),
    );
    print('API response: $response');
    
    return response.fold(
      (failure) {
        print('Failure: ${failure.message}');
        return Left(failure);
      },
      (data) {
        print('Data received: $data');
        if (data is List) {
          final products = data.map((e) => ProductModel.fromJson(e)).toList();
          return Right(products);
        } else {
          print('Invalid data format received from API');
          return Left(Failure(message: 'Invalid data format received from API'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, ProductModel>> fetchProductDetails(int productId) async {
    print('Fetching product details from API...');
    final url = '${ApiUrls.products}$productId/';
    print('Constructed URL: $url');
    final response = await api.get(
      apiRequest: ApiRequest(url: url),
    );
    print('API response: $response');
    
    return response.fold(
      (failure) {
        print('Failure: ${failure.message}');
        return Left(failure);
      },
      (data) {
        print('Data received: $data');
        final product = ProductModel.fromJson(data);
        return Right(product);
      },
    );
  }

  @override
  Future<Either<Failure, List<ProductModel>>> fetchRelatedProducts(int productId) async {
    try {
      print('Fetching related products from API...');
      final response = await api.get(
        apiRequest: ApiRequest(url: '${ApiUrls.products}$productId/related/'),
      );
      print('API response: $response');
      return response.fold(
        (failure) {
          print('Failure: ${failure.message}');
          return <ProductModel>[];
        },
        (data) {
          print('Data received: $data');
          if (data is List) {
            return data.map((e) => ProductModel.fromJson(e)).toList();
          } else {
            print('Invalid data format received from API');
            return <ProductModel>[];
          }
        },
      );
    } catch (e) {
      print('ProductRemoteDataSource fetchRelatedProducts error: $e');
      return <ProductModel>[];
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> fetchProductReviews(int productId) async {
    try {
      print('Fetching product reviews from API...');
      final response = await api.get(
        apiRequest: ApiRequest(url: '${ApiUrls.products}$productId/reviews/'),
      );
      print('API response: $response');
      return response.fold(
        (failure) {
          print('Failure: ${failure.message}');
          return <Map<String, dynamic>>[];
        },
        (data) {
          print('Data received: $data');
          if (data is List) {
            return data.cast<Map<String, dynamic>>();
          } else {
            print('Invalid data format received from API');
            return <Map<String, dynamic>>[];
          }
        },
      );
    } catch (e) {
      print('ProductRemoteDataSource fetchProductReviews error: $e');
      return <Map<String, dynamic>>[];
    }
  }
}
