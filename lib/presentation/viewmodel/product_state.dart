import '../../domain/entities/product.dart';

class ProductState {
  final bool isLoading;
  final String? errorMessage;
  final List<Product> products;

  const ProductState({
    this.isLoading = false,
    this.errorMessage,
    this.products = const [],
  });

  ProductState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Product>? products,
    bool clearError = false,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      products: products ?? this.products,
    );
  }
}
