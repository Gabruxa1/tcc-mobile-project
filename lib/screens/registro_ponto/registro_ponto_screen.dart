import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel, Event;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_drawer.dart';
import '../../services/register_service.dart';
import '../../widgets/error_message_widget.dart';
import '../../widgets/confirmation_modal.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/success_message_widget.dart';

class RegistroPontoPage extends StatefulWidget {
  const RegistroPontoPage({super.key});

  @override
  _RegistroPontoPageState createState() => _RegistroPontoPageState();
}

class _RegistroPontoPageState extends State<RegistroPontoPage> {
  DateTime _selectedDate = DateTime.now();
  final RegisterService _registerService = RegisterService();
  String? _errorMessage;
  bool _isLoading = false;
  bool _showError = false;
  bool _showSuccess = false;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
  }

  Future<void> _handleDateSelection(DateTime date) async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    if (date.isBefore(yesterday.subtract(const Duration(days: 1)))) {
      setState(() {
        _errorMessage =
            'Não é permitido registrar pontos em dias anteriores ao dia anterior. Por favor, entre em contato com a administração para ajustes.';
        _showError = true;
      });
      return;
    }

    setState(() {
      _selectedDate = date;
      _isLoading = true;
    });

    try {
      final response = await _registerService.getPontos();
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody.isNotEmpty) {
          final userKey = responseBody.keys.first;
          final pontos = responseBody[userKey]['pontos'] as List<dynamic>;
          final ponto = pontos.firstWhere(
            (p) =>
                DateTime.parse(p['data'])
                    .toLocal()
                    .toIso8601String()
                    .substring(0, 10) ==
                date.toIso8601String().substring(0, 10),
            orElse: () => null,
          );

          if (ponto == null) {
            _showConfirmationModalForEntry(date);
          } else {
            if (ponto['entrada'] != "" &&
                (ponto['saida'] == null || ponto['saida'] == "")) {
              final entrada = ponto['entrada'];
              final saida = DateFormat('HH:mm:ss').format(DateTime.now());
              const title = 'Tem certeza que deseja registrar a Saída?';
              final time = saida;

              showModalBottomSheet(
                context: context,
                isDismissible: false,
                backgroundColor: Colors.black54,
                builder: (context) {
                  return WillPopScope(
                    onWillPop: () async => false,
                    child: ConfirmationModal(
                      title: title,
                      date: DateFormat('dd/MM/yyyy').format(date),
                      time: time,
                      onConfirm: () async {
                        setState(() {
                          _isLoading = true;
                        });

                        final body = {
                          'data': DateFormat('yyyy-MM-dd').format(date),
                          'entrada': entrada,
                          'saida': saida,
                        };

                        final registerResponse =
                            await _registerService.registerPonto(
                          body['data']!,
                          body['entrada']!,
                          body['saida']!,
                        );

                        Navigator.of(context).pop();

                        if (registerResponse.statusCode == 200) {
                          setState(() {
                            _successMessage = 'Saída registrada com sucesso!';
                            _showSuccess = true;
                          });
                        } else {
                          setState(() {
                            _errorMessage =
                                json.decode(registerResponse.body)['message'];
                            _showError = true;
                          });
                        }

                        setState(() {
                          _isLoading = false;
                        });
                      },
                      onCancel: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
              );
            } else if (ponto['entrada'] != "" && ponto['saida'] != "") {
              setState(() {
                _errorMessage =
                    'Já existe um registro de entrada e saída para esta data.';
                _showError = true;
              });
            }
          }
        } else {
          setState(() {
            _errorMessage = 'Nenhum ponto encontrado';
            _showError = true;
          });
        }
      } else {
        setState(() {
          _errorMessage = json.decode(response.body)['message'];
          _showError = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        if (_errorMessage!.contains('Token')) {
          _errorMessage = 'Token inválido ou expirado. Faça login novamente.';
        }
        _showError = true;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showConfirmationModalForEntry(DateTime date) {
    final entrada = DateFormat('HH:mm:ss').format(DateTime.now());

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.black54,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: ConfirmationModal(
            title: 'Tem certeza que deseja registrar a Entrada?',
            date: DateFormat('dd/MM/yyyy').format(date),
            time: entrada,
            onConfirm: () async {
              setState(() {
                _isLoading = true;
              });

              final body = {
                'data': DateFormat('yyyy-MM-dd').format(date),
                'entrada': entrada,
                'saida': "",
              };

              final registerResponse = await _registerService.registerPonto(
                body['data']!,
                body['entrada']!,
                body['saida']!,
              );

              Navigator.of(context).pop();

              if (registerResponse.statusCode == 200) {
                setState(() {
                  _successMessage = 'Entrada registrada com sucesso!';
                  _showSuccess = true;
                });
              } else {
                setState(() {
                  _errorMessage = json.decode(registerResponse.body)['message'];
                  _showError = true;
                });
              }

              setState(() {
                _isLoading = false;
              });
            },
            onCancel: () {
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  void _hideErrorMessage() {
    setState(() {
      _showError = false;
      _errorMessage = null;
    });
  }

  void _hideSuccessMessage() {
    setState(() {
      _showSuccess = false;
      _successMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final CalendarCarousel<Event> calendarCarouselNoHeader =
        CalendarCarousel<Event>(
      locale: 'pt_BR',
      onDayPressed: (DateTime date, List<Event> events) {
        _handleDateSelection(date);
      },
      weekendTextStyle:
          const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      todayButtonColor: Colors.green,
      todayBorderColor: Colors.green,
      selectedDayButtonColor: Colors.blue,
      selectedDayBorderColor: Colors.blue,
      selectedDateTime: _selectedDate,
      daysHaveCircularBorder: true,
      weekdayTextStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      minSelectedDate: DateTime(2000),
      maxSelectedDate: DateTime.now(),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Registro de Ponto',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: calendarCarouselNoHeader,
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Center(
              child: LoadingIndicator(),
            ),
          if (_showError && _errorMessage != null)
            ErrorMessageWidget(
              message: _errorMessage!,
              onShow: () {},
              onHide: _hideErrorMessage,
            ),
          if (_showSuccess && _successMessage != null)
            SuccessMessageWidget(
              message: _successMessage!,
              onShow: () {},
              onHide: _hideSuccessMessage,
            ),
        ],
      ),
    );
  }
}
