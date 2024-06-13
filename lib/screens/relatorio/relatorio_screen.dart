import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:registro_ponto/services/report_service.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/date_picker_dialog.dart';
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
  bool _isButtonDisabled = false;
  String? _errorMessage;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startDateController.text = _dateFormat.format(_startDate);
    _endDateController.text = _dateFormat.format(_endDate);
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime tempDate = isStart ? _startDate : _endDate;
    DateTime currentDate = DateTime.now();

    DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return CustomDatePickerDialog(
          initialDate: tempDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          currentDate: currentDate,
          onDateChanged: (DateTime date) {
            setState(() {
              tempDate = date;
            });
          },
        );
      },
    );

    if (picked != null) {
      if (picked.isAfter(currentDate)) {
        picked = currentDate;
      }

      if (isStart) {
        setState(() {
          _startDate = picked!;
          _startDateController.text = _dateFormat.format(picked);
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
            _endDateController.text = _dateFormat.format(_endDate);
          }
        });
      } else {
        setState(() {
          _endDate = picked!;
          _endDateController.text = _dateFormat.format(picked);
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
            _endDateController.text = _dateFormat.format(_endDate);
          }
        });
      }
    }
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _reportService.generateReport(_startDate, _endDate);

    setState(() {
      _isLoading = false;
    });

    if (result != null && result['success']) {
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
                    final filePath = '${directory.path}/relatorio.pdf';
                    OpenFile.open(filePath);
                    Navigator.of(context).pop();
                  } else {
                    _showErrorMessage('O arquivo PDF não foi encontrado.');
                  }
                },
                child: const Text('Abrir arquivo'),
              ),
            ],
          );
        },
      );
    } else {
      final errorMessage = result != null && result['error'] != null
          ? result['error']
          : 'Falha ao gerar o relatório';
      _showErrorMessage(errorMessage);
    }
  }

  void _showErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
      _isButtonDisabled = true;
    });

    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _errorMessage = null;
        _isButtonDisabled = false;
      });
    });
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
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
                              controller: _startDateController,
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
                              controller: _endDateController,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _isButtonDisabled ? null : _generateReport,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  _isButtonDisabled ? Colors.grey : Colors.blue,
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
              ),
              if (_errorMessage != null && _errorMessage!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: ErrorMessageWidget(
                    message: _errorMessage!,
                    fontSize: 16.0,
                    onShow: () {
                      setState(() {
                        _isButtonDisabled = true;
                      });
                    },
                    onHide: () {
                      setState(() {
                        _isButtonDisabled = false;
                      });
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
