import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/errors/app_exception.dart';
import '../models/product_model.dart';

class ProductRemoteDatasource {
  static const _baseUrl = 'https://dummyjson.com/products';
  final http.Client client;

  ProductRemoteDatasource(this.client);

  Future<List<ProductModel>> fetchProducts({int limit = 30}) async {
    final response = await client.get(Uri.parse('$_baseUrl?limit=$limit'));

    if (response.statusCode != 200) {
      throw AppException(
        'Erro ao buscar produtos',
        statusCode: response.statusCode,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rawProducts = data['products'] as List<dynamic>;

    return rawProducts
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ProductModel> fetchProductById(int id) async {
    final response = await client.get(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode != 200) {
      throw AppException(
        'Erro ao buscar produto',
        statusCode: response.statusCode,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ProductModel.fromJson(data);
  }
}
