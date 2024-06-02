import 'dart:convert';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
  }

  Future<void> saveCredentials(String email, String password, int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('senha', password);
    await prefs.setInt('funcionario_id', id);
  }

  Future<void> clearCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('senha');
    await prefs.remove('funcionario_id');
  }

  Future<Map<String, String>?> getSavedCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('email');
    final String? password = prefs.getString('senha');
    final int? id = prefs.getInt('funcionario_id');
    if (email != null && password != null && id != null) {
      return {
        'email': email,
        'senha': password,
        'funcionario_id': id.toString()
      };
    }
    return null;
  }

  Future<Map<String, dynamic>> login(String email, String password,
      {bool rememberMe = false}) async {
    try {
      setLoading(true);

      final tokenResponse = await _apiService.post('/connect/token', {
        'email': email,
        'senha': password,
      });

      if (tokenResponse.statusCode == 200) {
        final jwt = json.decode(tokenResponse.body)['token'];

        final loginResponse = await _apiService.post(
          '/login',
          {
            'email': email,
            'senha': password,
          },
          authToken: jwt,
        );

        if (loginResponse.statusCode == 200) {
          final funcionariosResponse =
              await _apiService.get('/funcionarios/ativos', authToken: jwt);

          if (funcionariosResponse.statusCode == 200) {
            final List<dynamic> funcionarios =
                json.decode(funcionariosResponse.body);

            int? funcionarioId;
            for (var funcionario in funcionarios) {
              if (funcionario['email'] == email) {
                funcionarioId = funcionario['id'];
                break;
              }
            }

            if (funcionarioId != null) {
              if (rememberMe) {
                await saveCredentials(email, password, funcionarioId);
              }
              return {'token': jwt, 'funcionario_id': funcionarioId};
            } else {
              return {'error': 'Funcionário não encontrado'};
            }
          } else {
            final errorData = json.decode(funcionariosResponse.body);
            return {'error': errorData['error']};
          }
        } else {
          final errorData = json.decode(loginResponse.body);
          return {'error': errorData['error']};
        }
      } else {
        final errorData = json.decode(tokenResponse.body);
        return {'error': errorData['error']};
      }
    } finally {
      setLoading(false);
    }
  }
}
