import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/errors/app_exception.dart';
import '../models/user_model.dart';

class AuthRemoteDatasource {
  static const _baseUrl = 'https://dummyjson.com';
  final http.Client client;

  AuthRemoteDatasource(this.client);

  Future<UserModel> login(String username, String password) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } else {
      final errorData = jsonDecode(response.body) as Map<String, dynamic>;
      throw AppException(
        errorData['message'] ?? 'Erro ao fazer login',
        statusCode: response.statusCode,
      );
    }
  }
}
