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
        return {'success': false, 'error': 'Credenciais não encontradas'};
      }

      final String formattedStartDate =
          DateFormat('yyyy-MM-dd').format(startDate);
      final String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
      final String path =
          '/relatorio/${credentials['funcionario_id']}?data_inicio=$formattedStartDate&data_fim=$formattedEndDate';

      final http.Response response = await _apiService.get(path, headers: {});

      if (response.statusCode == 200) {
        final reportData = json.decode(response.body);
        final success = await _generatePDF(reportData);
        if (success) {
          return {'success': true, 'data': reportData};
        } else {
          return {'success': false, 'error': 'Erro ao gerar o PDF'};
        }
      } else {
        final errorMessage = json.decode(response.body)['error'];
        return {'success': false, 'error': errorMessage};
      }
    } catch (error) {
      return {'success': false, 'error': 'Erro ao fazer a solicitação'};
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

  Future<bool> _generatePDF(Map<String, dynamic> reportData) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Relatório de Horas Trabalhadas',
              style: const pw.TextStyle(fontSize: 20),
            ),
          ),
          pw.Paragraph(
            text:
                'Nome: ${reportData['nome']} | Data: ${_formatDate(DateTime.parse(reportData['pontos'][0]['data']))}',
          ),
          pw.Table.fromTextArray(
            headers: ['Data', 'Entrada', 'Saída', 'Horas Trabalhadas'],
            data: List<List<dynamic>>.generate(
              reportData['pontos'].length,
              (index) => [
                _formatDate(
                    DateTime.parse(reportData['pontos'][index]['data'])),
                reportData['pontos'][index]['entrada'],
                reportData['pontos'][index]['saida'],
                reportData['pontos'][index]['horas_trabalhadas'],
              ],
            ),
          ),
          pw.Paragraph(
            text: 'Total de Horas Trabalhadas: ${reportData['total_horas']}',
          ),
        ],
      ));

      final output = await getExternalStorageDirectory();
      if (output != null) {
        final file = File('${output.path}/relatorio.pdf');
        await file.writeAsBytes(await pdf.save());
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }

  String _formatDate(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(dateTime);
  }
}
