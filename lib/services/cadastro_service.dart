import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class CadastroService {
  final ApiService _apiService = ApiService();

  Future<http.Response> criarFuncionario({
    required String nome,
    required String cpf,
    required String email,
    required String senha,
  }) async {
    final cleanCpf = cpf.replaceAll(RegExp(r'\D'), '');

    final data = {
      'nome': nome,
      'cpf': cleanCpf,
      'telefone': '999999999',
      'email': email,
      'senha': senha,
      'funcao': 'professor',
      'admin': true,
      'ativo': true,
      'custo_hora': 80.0
    };

    return await _apiService.post('/funcionarios', data);
  }
}
