import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductRepository {
  final String _baseUrl = 'https://dummyjson.com/products';

  Future<List<Product>> fetchProducts({int limit = 30}) async {
    final response = await http.get(Uri.parse('$_baseUrl?limit=$limit'));

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar produtos');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rawProducts = data['products'] as List<dynamic>;

    return rawProducts
        .map((item) => Product.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
