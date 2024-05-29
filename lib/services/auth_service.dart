import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';

class AuthService {
  final String baseUrl = 'http://criticasapp.pythonanywhere.com';

  Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      await SecureStorage.writeToken(data['token']);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<void> register(String email, String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      var data = json.decode(response.body);
      await SecureStorage.writeToken(data['token']);
    } else {
      throw Exception('Failed to register');
    }
  }

  Future<void> logout() async {
    await SecureStorage.deleteToken();
  }

  Future<int> getUserId() async {
    final token = await SecureStorage.readToken();

    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['id'];
    } else {
      throw Exception('Failed to get user ID');
    }
  }
}
