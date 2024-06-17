import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class RegisterService {
  final ApiService _apiService = ApiService();

  Future<http.Response> getPontos() async {
    final prefs = await SharedPreferences.getInstance();
    final int? funcionarioId = prefs.getInt('funcionario_id');

    if (funcionarioId == null) {
      throw Exception('Funcionário não encontrado');
    }

    final String path = '/pontos/$funcionarioId';
    return await _apiService.get(path);
  }

  Future<http.Response> registerPonto(
      String data, String entrada, String saida) async {
    final prefs = await SharedPreferences.getInstance();
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

    return await _apiService.post(path, body);
  }
}
