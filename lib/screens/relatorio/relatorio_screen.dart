import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:registro_ponto/services/report_service.dart';
import '../../widgets/custom_drawer.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'dart:async';
import '../../widgets/error_message_widget.dart';

class RelatorioScreen extends StatefulWidget {
  const RelatorioScreen({super.key});

  @override
  _RelatorioScreenState createState() => _RelatorioScreenState();
}

class _RelatorioScreenState extends State<RelatorioScreen> {
  final ReportService _reportService = ReportService();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime tempDate = isStart ? _startDate : _endDate;
    DateTime currentDate = DateTime.now();

    final DateTime? picked = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Localizations.override(
              context: context,
              locale: const Locale('pt', 'BR'),
              child: CalendarDatePicker(
                initialDate: tempDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                currentDate: currentDate,
                onDateChanged: (DateTime date) {
                  if (date.isAfter(currentDate)) {
                    // Se a data selecionada for futura, atualiza para a data atual
                    setState(() {
                      tempDate = currentDate;
                    });
                  } else {
                    setState(() {
                      tempDate = date;
                    });
                  }
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(tempDate);
              },
              child: const Text('Selecionar'),
            ),
          ],
        );
      },
    );

    if (picked != null && picked != (isStart ? _startDate : _endDate)) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
    });

    final reportData =
        await _reportService.generateReport(_startDate, _endDate);

    setState(() {
      _isLoading = false;
    });

    if (reportData != null) {
      // Exibe o alerta após a geração do relatório
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Relatório gerado'),
            content: const Text('O relatório foi gerado com sucesso.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () async {
                  final directory = Directory(
                      '/storage/emulated/0/Android/data/com.example.registro_ponto/files');

                  if (await File('${directory.path}/relatorio.pdf').exists()) {
                    // Abre o arquivo PDF usando a biblioteca open_file
                    final filePath = '${directory.path}/relatorio.pdf';
                    OpenFile.open(filePath);
                    Navigator.of(context).pop();
                  } else {
                    print('O arquivo PDF não foi encontrado.');
                  }
                },
                child: const Text('Abrir arquivo'),
              ),
            ],
          );
        },
      );
    } else {
      print('Falha ao gerar o relatório');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Gerar Relatório',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Selecione o período para geração',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _selectDate(context, true),
                child: AbsorbPointer(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Início',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                      text: _dateFormat.format(_startDate),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _selectDate(context, false),
                child: AbsorbPointer(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Fim',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                      text: _dateFormat.format(_endDate),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _generateReport,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue, // Cor do texto
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Gerar Relatório'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
