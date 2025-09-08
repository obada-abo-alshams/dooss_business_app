import 'package:dooss_business_app/core/cubits/optimized_cubit.dart';
import 'product_state.dart';
import 'package:dooss_business_app/features/home/data/data_source/product_remote_data_source.dart';

// Cubit
class ProductCubit extends OptimizedCubit<ProductState> {
  final ProductRemoteDataSource dataSource;
  
  ProductCubit(this.dataSource) : super(const ProductState());

  void loadProducts() async {
    safeEmit(state.copyWith(isLoading: true, error: null));
    
    final result = await dataSource.fetchProducts();
    
    result.fold(
      (failure) {
        safeEmit(state.copyWith(
          error: failure.message,
          isLoading: false,
        ));
      },
      (allProducts) {
        final homeProducts = allProducts.take(10).toList();
        
        batchEmit((currentState) => currentState.copyWith(
          products: homeProducts,
          allProducts: allProducts,
          isLoading: false,
        ));
      },
    );
  }

  void loadAllProducts() async {
    // If we already have all products, use them
    if (state.allProducts.isNotEmpty) {
      final first8Products = state.allProducts.take(8).toList();
      emitOptimized(state.copyWith(
        filteredProducts: state.allProducts,
        displayedProducts: first8Products,
        selectedCategory: 'All',
        hasMoreProducts: state.allProducts.length > 8,
      ));
      return;
    }

    // Otherwise, fetch from API
    safeEmit(state.copyWith(isLoading: true, error: null));
    
    final result = await dataSource.fetchProducts();
    
    result.fold(
      (failure) {
        safeEmit(state.copyWith(
          error: failure.message,
          isLoading: false,
        ));
      },
      (allProducts) {
        final first8Products = allProducts.take(8).toList();
        
        batchEmit((currentState) => currentState.copyWith(
          allProducts: allProducts,
          filteredProducts: allProducts,
          displayedProducts: first8Products,
          selectedCategory: 'All',
          hasMoreProducts: allProducts.length > 8,
          isLoading: false,
        ));
      },
    );
  }

  void showHomeProducts() {
    // Show only first 10 products
    final homeProducts = state.allProducts.take(10).toList();
    emitOptimized(state.copyWith(products: homeProducts));
  }

  void filterByCategory(String category) {
    if (category == 'All') {
      final first8Products = state.allProducts.take(8).toList();
      emitOptimized(state.copyWith(
        filteredProducts: state.allProducts,
        displayedProducts: first8Products,
        selectedCategory: category,
        hasMoreProducts: state.allProducts.length > 8,
      ));
    } else {
      // Filter products by category (mock filtering for now)
      final filteredProducts = state.allProducts.where((product) {
        // Mock category filtering - in real app, this would be based on product.category
        return product.name.toLowerCase().contains(category.toLowerCase()) ||
               product.description.toLowerCase().contains(category.toLowerCase());
      }).toList();
      
      final first8Products = filteredProducts.take(8).toList();
      emitOptimized(state.copyWith(
        filteredProducts: filteredProducts,
        displayedProducts: first8Products,
        selectedCategory: category,
        hasMoreProducts: filteredProducts.length > 8,
      ));
    }
  }

  void loadMoreProducts() {
    if (state.isLoadingMore || !state.hasMoreProducts) return;
    
    safeEmit(state.copyWith(isLoadingMore: true));
    
    final currentDisplayedCount = state.displayedProducts.length;
    final next8Products = state.filteredProducts.skip(currentDisplayedCount).take(8).toList();
    final newDisplayedProducts = [...state.displayedProducts, ...next8Products];
    
    batchEmit((currentState) => currentState.copyWith(
      displayedProducts: newDisplayedProducts,
      hasMoreProducts: newDisplayedProducts.length < state.filteredProducts.length,
      isLoadingMore: false,
    ));
  }

  void loadProductDetails(int productId) async {
    safeEmit(state.copyWith(isLoading: true, error: null));
    
    final productResult = await dataSource.fetchProductDetails(productId);
    
    productResult.fold(
      (failure) {
        safeEmit(state.copyWith(
          error: failure.message,
          isLoading: false,
        ));
      },
      (product) async {
        // First emit the main product details immediately
        safeEmit(state.copyWith(
          selectedProduct: product,
          isLoading: false,
        ));
        
        // Then load additional data asynchronously
        _loadAdditionalProductData(productId);
      },
    );
  }

  void toggleProductFavorite(int productId) {
    // Here you would typically update the favorite status in the backend
    // For now, we'll just emit the same state
    emitOptimized(state.copyWith());
  }

  /// Load additional product data (related products and reviews) safely
  Future<void> _loadAdditionalProductData(int productId) async {
    // Load related products and reviews in parallel
    final relatedProductsResult = await dataSource.fetchRelatedProducts(productId);
    final reviewsResult = await dataSource.fetchProductReviews(productId);
    
    // Only emit if cubit is still active
    if (!isClosed) {
      relatedProductsResult.fold(
        (relatedFailure) {
          // If related products fail, still show product details
          reviewsResult.fold(
            (reviewFailure) {
              // Both related and reviews failed - no additional emit needed
              // Product details are already shown
            },
            (reviews) {
              // Only related products failed
              safeEmit(state.copyWith(
                productReviews: reviews,
              ));
            },
          );
        },
        (relatedProducts) {
          reviewsResult.fold(
            (reviewFailure) {
              // Only reviews failed
              safeEmit(state.copyWith(
                relatedProducts: relatedProducts,
              ));
            },
            (reviews) {
              // Everything succeeded
              batchEmit((currentState) => currentState.copyWith(
                relatedProducts: relatedProducts,
                productReviews: reviews,
              ));
            },
          );
        },
      );
    }
  }
}
