import 'package:flutter/material.dart';
import 'package:registro_ponto/services/auth_service.dart';
import 'package:registro_ponto/widgets/loading_indicator.dart';
import 'package:registro_ponto/widgets/error_message_widget.dart';
import 'package:registro_ponto/widgets/theme_switch.dart';
import 'package:registro_ponto/utils/validators.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const LoginPage({super.key, required this.toggleTheme});

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
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  void _loadCredentials() async {
    final credentials = await _authService.getSavedCredentials();
    if (credentials != null) {
      setState(() {
        _email = credentials['email']!;
        _password = credentials['senha']!;
        _rememberMe = true;
      });
      print(
          'Saved Credentials: ${credentials.toString()}'); // Adicionado print para verificar no console

      await _autoLogin();
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

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: ThemeSwitch(
                          isDarkMode:
                              Theme.of(context).brightness == Brightness.dark,
                          onToggle: widget.toggleTheme,
                        ),
                      ),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading) // Mostrar indicador de carregamento se estiver carregando
            const LoadingIndicator(),
          if (_errorMessage != null && _errorMessage!.isNotEmpty)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ErrorMessageWidget(message: _errorMessage!),
              ),
            ),
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
        onPressed: _onLoginPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
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
          shape: const CircleBorder(),
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

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }
}
