import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> fetchProducts({int limit = 30});
  Future<Product> fetchProductById(int id);
}
