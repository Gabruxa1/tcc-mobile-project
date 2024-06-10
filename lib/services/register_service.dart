import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:registro_ponto/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ReportService {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
  }

  Future<Map<String, dynamic>?> generateReport(
      DateTime startDate, DateTime endDate) async {
    try {
      setLoading(true);

      final credentials = await getSavedCredentials();
      if (credentials == null) {
        return {'error': 'Credenciais não encontradas'};
      }

      final String formattedStartDate =
          DateFormat('yyyy-MM-dd').format(startDate);
      final String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
      final String path =
          '/relatorio/${credentials['funcionario_id']}?data_inicio=$formattedStartDate&data_fim=$formattedEndDate';

      final http.Response response = await _apiService.get(path);

      if (response.statusCode == 200) {
        final reportData = json.decode(response.body);
        await generatePDF(reportData);
        return reportData;
      } else {
        final errorData = json.decode(response.body);
        return {'error': errorData['error']};
      }
    } catch (error) {
      return {'error': 'Erro ao fazer a solicitação: $error'};
    } finally {
      setLoading(false);
    }
  }

  Future<Map<String, String>?> getSavedCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? id = prefs.getInt('funcionario_id');
    if (id != null) {
      return {'funcionario_id': id.toString()};
    }
    return null;
  }

  Future<void> generatePDF(Map<String, dynamic> reportData) async {
    final pdf = pw.Document();

    pdf.addPage(pw.MultiPage(
      build: (context) => [
        pw.Header(
          level: 0,
          child: pw.Text('Relatório de Horas Trabalhadas'),
        ),
        pw.Paragraph(
            text:
                'Nome: ${reportData['nome']} | Data: ${DateTime.now().toIso8601String()}'),
        pw.Paragraph(
            text:
                'Período: ${reportData['pontos'][0]['data']} - ${reportData['pontos'].last['data']}'),
        pw.Table.fromTextArray(
          headers: ['Data', 'Entrada', 'Saída', 'Horas Trabalhadas'],
          data: List<List<dynamic>>.generate(
            reportData['pontos'].length,
            (index) => [
              reportData['pontos'][index]['data'],
              reportData['pontos'][index]['entrada'],
              reportData['pontos'][index]['saida'],
              reportData['pontos'][index]['horas_trabalhadas'],
            ],
          ),
        ),
        pw.Paragraph(
            text: 'Total de Horas Trabalhadas: ${reportData['total_horas']}'),
      ],
    ));

    final output = await getExternalStorageDirectory();
    if (output != null) {
      final file = File('${output.path}/relatorio.pdf');
      await file.writeAsBytes(await pdf.save());
    } else {
      throw 'Não foi possível acessar o diretório de armazenamento externo.';
    }
  }
}
