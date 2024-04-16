import 'dart:convert';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<void> saveCredentials(String email, String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }

  Future<void> clearCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');
  }

  Future<Map<String, String>?> getSavedCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('email');
    final String? password = prefs.getString('password');
    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final tokenResponse = await _apiService.post('/connect/token', {
      'email': email,
      'senha': password,
    });

    if (tokenResponse.statusCode == 200) {
      final jwt = json.decode(tokenResponse.body)['token'];

      await saveCredentials(email, password);

      final loginResponse = await _apiService.post(
        '/login',
        {
          'email': email,
          'senha': password,
        },
        authToken: jwt,
      );

      if (loginResponse.statusCode == 200) {
        return json.decode(loginResponse.body);
      } else {
        final errorData = json.decode(loginResponse.body);
        return {'error': errorData['error']};
      }
    } else {
      final errorData = json.decode(tokenResponse.body);
      return {'error': errorData['error']};
    }
  }
}
