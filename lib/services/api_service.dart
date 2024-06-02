import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = 'https://tcc-api-project.vercel.app';

  Future<http.Response> post(String path, Map<String, dynamic> data,
      {String? authToken}) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (authToken != null) {
      headers['Authorization'] = authToken;
    }
    final response = await http.post(
      uri,
      headers: headers,
      body: json.encode(data),
    );
    return response;
  }

  Future<http.Response> get(String path, {String? authToken}) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    final response = await http.get(
      uri,
      headers: headers,
    );
    return response;
  }

  Future<http.Response> put(String path, Map<String, dynamic> data,
      {String? authToken}) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (authToken != null) {
      headers['Authorization'] = authToken;
    }
    final response = await http.put(
      uri,
      headers: headers,
      body: json.encode(data),
    );
    return response;
  }

  Future<http.Response> delete(String path, Map<String, dynamic> data,
      {String? authToken}) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (authToken != null) {
      headers['Authorization'] = authToken;
    }
    final response = await http.delete(
      uri,
      headers: headers,
    );
    return response;
  }
}
