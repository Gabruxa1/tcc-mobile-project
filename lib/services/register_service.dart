import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class RegisterService {
  final ApiService _apiService = ApiService();

  Future<http.Response> getPontos() async {
    final prefs = await SharedPreferences.getInstance();

    // Recuperando o token salvo
    final String? token = prefs.getString('token');
    final int? funcionarioId = prefs.getInt('funcionario_id');

    if (funcionarioId == null) {
      throw Exception('Funcionário não encontrado');
    }

    final String path = '/pontos/$funcionarioId';

    // Verificando se o token existe antes de fazer a requisição
    if (token == null) {
      throw Exception(
          'Token não encontrado. Por favor, faça o login novamente.');
    }

    return await _apiService.get(path, headers: {
      'Authorization': 'Bearer $token',
    });
  }

  Future<http.Response> registerPonto(
      String data, String entrada, String saida) async {
    final prefs = await SharedPreferences.getInstance();

    // Recuperando o token salvo
    final String? token = prefs.getString('token');
    final int? funcionarioId = prefs.getInt('funcionario_id');

    if (funcionarioId == null) {
      throw Exception('Funcionário não encontrado');
    }

    final String path = '/pontos/$funcionarioId';
    final Map<String, dynamic> body = {
      'data': data,
      'entrada': entrada,
      'saida': saida,
    };

    // Verificando se o token está disponível antes de realizar a requisição
    if (token == null) {
      throw Exception(
          'Token não encontrado. Por favor, faça o login novamente.');
    }

    return await _apiService.post(path, body, headers: {
      'Authorization': 'Bearer $token',
    });
  }
}
