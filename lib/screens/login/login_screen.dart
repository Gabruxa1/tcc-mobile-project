import 'package:flutter/material.dart';
import 'package:registro_ponto/services/auth_service.dart';
import 'package:registro_ponto/widgets/loading_indicator.dart';
import 'package:registro_ponto/widgets/error_message_widget.dart';
import 'package:registro_ponto/utils/validators.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _rememberMe = false;
  bool _showPassword = false;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isButtonDisabled = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  void _loadCredentials() async {
    final credentials = await _authService.getSavedCredentials();
    final rememberMe = await _authService.getRememberMe();
    if (credentials != null) {
      setState(() {
        _email = credentials['email']!;
        _password = credentials['senha']!;
        _rememberMe = rememberMe;
      });
      if (rememberMe) {
        await _autoLogin();
      }
    }
  }

  Future<void> _autoLogin() async {
    setState(() {
      _isLoading = true;
    });
    final result =
        await _authService.login(_email, _password, rememberMe: _rememberMe);
    setState(() {
      _isLoading = false;
    });
    if (result.containsKey('token')) {
      Navigator.of(context).pushReplacementNamed('/registroPonto');
    } else if (result.containsKey('error')) {
      _showError(result['error']);
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _isButtonDisabled = true; // Desabilitar o botão ao mostrar o erro
    });

    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _errorMessage = null;
        _isButtonDisabled = false; // Habilitar o botão após ocultar o erro
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Form(
                        key: _formKey,
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                                  primary: Colors.blueAccent,
                                ),
                            checkboxTheme: CheckboxThemeData(
                              fillColor:
                                  WidgetStateProperty.resolveWith<Color?>(
                                      (states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Colors.blueAccent;
                                }
                                return Colors.white;
                              }),
                              checkColor:
                                  WidgetStateProperty.resolveWith<Color?>(
                                      (states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Colors.white;
                                }
                                return null;
                              }),
                              side: const BorderSide(color: Colors.blueAccent),
                            ),
                            inputDecorationTheme: const InputDecorationTheme(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blueAccent, width: 2.0),
                              ),
                              labelStyle: TextStyle(color: Colors.black87),
                              floatingLabelStyle:
                                  TextStyle(color: Colors.blueAccent),
                              errorStyle: TextStyle(color: Colors.redAccent),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.redAccent, width: 2.0),
                              ),
                              focusedErrorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.redAccent, width: 2.0),
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              const Text(
                                "Bem Vindo Novamente",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 36),
                              _buildUsernameField(),
                              const SizedBox(height: 20),
                              _buildPasswordField(),
                              const SizedBox(height: 20),
                              _buildRememberMeCheckbox(),
                              _buildLoginButton(),
                              SizedBox(
                                height: bottomPadding == 0 ? 60 : bottomPadding,
                              ),
                            ],
                          ),
                        ),
                      ),
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
          if (_isLoading) const LoadingIndicator(),
        ],
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      initialValue: _email,
      decoration: const InputDecoration(labelText: 'Email'),
      validator: validateEmail,
      onSaved: (value) => _email = value ?? '',
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      initialValue: _password,
      obscureText: !_showPassword,
      decoration: InputDecoration(
        labelText: 'Senha',
        suffixIcon: IconButton(
          icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() => _showPassword = !_showPassword);
          },
        ),
      ),
      validator: validatePassword,
      onSaved: (value) => _password = value ?? '',
    );
  }

  Widget _buildLoginButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _isButtonDisabled ? null : _onLoginPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: _isButtonDisabled ? Colors.grey : Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
        ),
        child: const Text(
          'LOGIN',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (bool? value) {
            setState(() {
              _rememberMe = value ?? false;
            });
          },
        ),
        const Text("Lembrar-Me"),
      ],
    );
  }

  void _onLoginPressed() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _errorMessage = null;
        _isLoading = true;
      });
      final result =
          await _authService.login(_email, _password, rememberMe: _rememberMe);
      setState(() {
        _isLoading = false;
      });
      if (result.containsKey('token')) {
        Navigator.of(context).pushReplacementNamed('/registroPonto');
      } else if (result.containsKey('error')) {
        _showError(result['error']);
      }
    }
  }
}
