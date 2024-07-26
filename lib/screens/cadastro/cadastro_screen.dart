import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:registro_ponto/widgets/menu_drawer.dart';
import 'package:registro_ponto/widgets/indicador_carregamento.dart';
import 'package:registro_ponto/widgets/mensagem_sucesso.dart';
import 'package:registro_ponto/widgets/mensagem_erro.dart';
import 'package:email_validator/email_validator.dart';
import 'package:registro_ponto/services/cadastro_service.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  _CadastroScreenState createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _passwordError;
  bool _isLoading = false;
  bool _showSuccessMessage = false;
  bool _showErrorMessage = false;
  String _message = '';

  final CadastroService _cadastroService = CadastroService();

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePasswords() {
    setState(() {
      if (_passwordController.text != _confirmPasswordController.text) {
        _passwordError = 'Senhas não coincidem';
      } else {
        _passwordError = null;
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _cadastroService.criarFuncionario(
          nome: _nomeController.text,
          cpf: _cpfController.text,
          email: _emailController.text,
          senha: _passwordController.text,
        );

        final responseBody = jsonDecode(response.body);

        setState(() {
          if (response.statusCode == 200) {
            _message = responseBody['message'] ??
                'Funcionário cadastrado com sucesso!';
            _showSuccessMessage = true;
            _showErrorMessage = false;
          } else {
            _message = responseBody['message'] ?? 'Erro desconhecido';
            _showSuccessMessage = false;
            _showErrorMessage = true;
          }
        });
      } catch (e) {
        setState(() {
          _message = 'Erro ao cadastrar funcionário: $e';
          _showSuccessMessage = false;
          _showErrorMessage = true;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue),
      ),
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
      ),
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    decoration: _inputDecoration('Nome'),
                    maxLength: 50,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu nome';
                      }
                      return null;
                    },
                    controller: _nomeController,
                  ),
                  TextFormField(
                    decoration: _inputDecoration('CPF'),
                    maxLength: 14,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _CpfInputFormatter(),
                    ],
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu CPF';
                      }
                      if (value.length != 14) {
                        return 'CPF deve conter 11 dígitos';
                      }
                      return null;
                    },
                    controller: _cpfController,
                  ),
                  TextFormField(
                    decoration: _inputDecoration('Email'),
                    maxLength: 50,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu email';
                      }
                      if (!EmailValidator.validate(value)) {
                        return 'Por favor, insira um email válido';
                      }
                      return null;
                    },
                    controller: _emailController,
                  ),
                  TextFormField(
                    decoration: _inputDecoration('Senha'),
                    maxLength: 20,
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira sua senha';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: _inputDecoration('Confirmar Senha'),
                    maxLength: 20,
                    obscureText: true,
                    controller: _confirmPasswordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, confirme sua senha';
                      }
                      if (_passwordError != null) {
                        return _passwordError;
                      }
                      return null;
                    },
                    onChanged: (value) => _validatePasswords(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text('Cadastrar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading) const LoadingIndicator(),
          if (_showSuccessMessage)
            SuccessMessageWidget(
              message: _message,
              onShow: () {},
              onHide: () {
                setState(() {
                  _showSuccessMessage = false;
                });
              },
            ),
          if (_showErrorMessage)
            ErrorMessageWidget(
              message: _message,
              onShow: () {},
              onHide: () {
                setState(() {
                  _showErrorMessage = false;
                });
              },
            ),
        ],
      ),
    );
  }
}

class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.length > 11) return oldValue;

    var newText = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 6) {
        newText += '.';
      } else if (i == 9) {
        newText += '-';
      }
      newText += text[i];
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
