import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource _datasource;

  ProductRepositoryImpl(this._datasource);

  @override
  Future<List<Product>> fetchProducts({int limit = 30}) async {
    return await _datasource.fetchProducts(limit: limit);
  }

  @override
  Future<Product> fetchProductById(int id) async {
    return await _datasource.fetchProductById(id);
  }
}
