import 'dart:convert';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Classe responsável pela autenticação do usuário
class AuthService {
  // Instância do serviço de API
  final ApiService _apiService = ApiService();

  // Variável para controlar o estado de carregamento
  bool _isLoading = false;

  // Getter para acessar o estado de carregamento
  bool get isLoading => _isLoading;

  // Método para definir o estado de carregamento
  void setLoading(bool value) {
    _isLoading = value;
  }

  // Método para salvar as credenciais do usuário
  Future<void> saveCredentials(
      String email, String password, String token, int userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Salva o email, senha, token e id nas preferências
    await prefs.setString('email', email);
    await prefs.setString('senha', password);
    await prefs.setString('token', token);
    await prefs.setInt('id', userId);
  }

  // Método para limpar as credenciais salvas
  Future<void> clearCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Remove as credenciais das preferências
    await prefs.remove('email');
    await prefs.remove('senha');
    await prefs.remove('token');
    await prefs.remove('id');
  }

  // Método para obter as credenciais salvas
  Future<Map<String, dynamic>?> getSavedCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Recupera o email, senha, token e id
    final String? email = prefs.getString('email');
    final String? password = prefs.getString('senha');
    final String? token = prefs.getString('token');
    final int? userId = prefs.getInt('id');

    // Verifica se todas as credenciais estão disponíveis
    if (email != null && password != null && token != null && userId != null) {
      return {
        'email': email,
        'senha': password,
        'token': token,
        'id': userId,
      };
    }
    return null; // Retorna null se não houver credenciais
  }

  // Método para verificar se a opção "lembrar-me" está ativada
  Future<bool> getRememberMe() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('remember_me') ?? false;
  }

  // Método para decodificar o payload de um token JWT
  Map<String, dynamic> _parseJwt(String token) {
    final parts = token.split('.');

    // Verifica se o token é válido
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);

    // Verifica se o payload é um mapa válido
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('Invalid payload');
    }

    return payloadMap; // Retorna o payload decodificado
  }

  // Método para decodificar uma string base64
  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    // Ajusta o comprimento da string para ser múltiplo de 4
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!');
    }

    return utf8
        .decode(base64Url.decode(output)); // Retorna a string decodificada
  }

  // Método para fazer login do usuário
  Future<Map<String, dynamic>> login(String email, String password,
      {bool rememberMe = false}) async {
    try {
      setLoading(true); // Inicia o carregamento

      // Envia uma requisição POST para obter o token
      final tokenResponse = await _apiService.post('/connect/token', {
        'email': email,
        'senha': password,
      }, headers: {});

      // Verifica se a resposta foi bem-sucedida
      if (tokenResponse.statusCode == 200) {
        final jwt = json.decode(tokenResponse.body)['token'];

        // Decodifica o token JWT e obtém o payload
        final payload = _parseJwt(jwt);

        // Obtém o ID do usuário a partir do payload
        final userId =
            payload['id'] ?? payload['email']; // Ou outro campo desejado

        // Salva as credenciais conforme o estado do "lembrar-me"
        if (rememberMe) {
          await saveCredentials(
              email, password, jwt, userId); // Salva todas as credenciais
        } else {
          await saveToken(jwt, userId); // Salva somente o token e id
        }

        return {'token': jwt, 'userId': userId}; // Retorna o token e o userId
      } else {
        // Retorna erro caso a autenticação falhe
        final errorData = json.decode(tokenResponse.body);
        return {'error': errorData['error']};
      }
    } finally {
      setLoading(false); // Finaliza o carregamento
    }
  }

  // Método para salvar o token e o ID do usuário
  Future<void> saveToken(String token, int userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Salva o token
    await prefs.setString('token', token);

    // Salva o ID
    await prefs.setInt('id', userId);
  }
}
