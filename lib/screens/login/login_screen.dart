import 'package:flutter/material.dart';
import 'package:registro_ponto/services/auth_service.dart';
import 'package:registro_ponto/widgets/loading_indicator.dart';
import 'package:registro_ponto/widgets/error_message_widget.dart';
import 'package:registro_ponto/utils/validators.dart';

// Classe que representa a tela de login
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

// Estado da tela de login
class _LoginPageState extends State<LoginPage> {
  // Chave global para o formulário
  final _formKey = GlobalKey<FormState>();

  // Variáveis para armazenar o email e a senha
  String _email = '';
  String _password = '';

  // Variáveis para controle do estado da UI
  bool _rememberMe = false; // Estado do checkbox "lembrar-me"
  bool _showPassword = false; // Controle da visibilidade da senha
  String? _errorMessage; // Mensagem de erro
  bool _isLoading = false; // Estado de carregamento
  bool _isButtonDisabled = false; // Controle do estado do botão
  final AuthService _authService =
      AuthService(); // Instância do serviço de autenticação

  @override
  void initState() {
    super.initState();
    _loadCredentials(); // Carrega as credenciais salvas ao iniciar a tela
  }

  // Método para carregar as credenciais salvas
  void _loadCredentials() async {
    final credentials =
        await _authService.getSavedCredentials(); // Obtém credenciais salvas
    final rememberMe =
        await _authService.getRememberMe(); // Obtém estado do "lembrar-me"
    if (credentials != null) {
      setState(() {
        // Atualiza as variáveis de estado com as credenciais carregadas
        _email = credentials['email']!;
        _password = credentials['senha']!;
        _rememberMe = rememberMe;
      });
    }
  }

  // Método chamado ao pressionar o botão de login
  Future<void> _onLoginPressed() async {
    if (_formKey.currentState!.validate()) {
      // Valida o formulário
      _formKey.currentState!.save(); // Salva os valores do formulário
      setState(() {
        _errorMessage = null; // Limpa a mensagem de erro
        _isLoading = true; // Inicia o loading
      });

      try {
        // Chama o método de login do AuthService
        final result = await _authService.login(_email, _password,
            rememberMe: _rememberMe);

        if (result.containsKey('token')) {
          // Se o login for bem-sucedido, navega para a próxima tela
          Navigator.of(context).pushReplacementNamed('/registroPonto');
        } else if (result.containsKey('error')) {
          // Mostra a mensagem de erro caso ocorra
          _showError(result['error']);
        }
      } catch (e) {
        // Mostra mensagem de erro em caso de exceção
        _showError('Erro ao fazer login: ${e.toString()}');
      } finally {
        setState(() {
          _isLoading = false; // Para o loading, mesmo em caso de erro
        });
      }
    }
  }

  // Método para exibir mensagem de erro
  void _showError(String message) {
    setState(() {
      _errorMessage = message; // Define a mensagem de erro
      _isButtonDisabled = true; // Desabilita o botão
    });

    // Limpa a mensagem de erro após 5 segundos
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _errorMessage = null; // Reseta a mensagem de erro
        _isButtonDisabled = false; // Reabilita o botão
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calcula o padding inferior para evitar sobreposição do teclado
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
                        key: _formKey, // Define a chave do formulário
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            // Configura o tema da tela de login
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                                  primary: Colors.blueAccent,
                                ),
                            checkboxTheme: CheckboxThemeData(
                              fillColor:
                                  WidgetStateProperty.resolveWith<Color?>(
                                      // Define a cor do checkbox
                                      (states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Colors.blueAccent;
                                }
                                return Colors.white;
                              }),
                              checkColor:
                                  WidgetStateProperty.resolveWith<Color?>(
                                      // Define a cor do check
                                      (states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Colors.white;
                                }
                                return null;
                              }),
                              side: const BorderSide(
                                  color: Colors
                                      .grey), // Define a borda do checkbox
                            ),
                            inputDecorationTheme: const InputDecorationTheme(
                              // Configura a aparência dos campos de entrada
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
                                "Bem Vindo Novamente", // Título da tela
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 36),
                              _buildUsernameField(), // Campo de entrada para o email
                              const SizedBox(height: 20),
                              _buildPasswordField(), // Campo de entrada para a senha
                              const SizedBox(height: 20),
                              _buildRememberMeCheckbox(), // Checkbox para "lembrar-me"
                              _buildLoginButton(), // Botão de login
                              SizedBox(
                                height: bottomPadding == 0 ? 60 : bottomPadding,
                              ), // Espaço inferior para o teclado
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Exibe mensagem de erro, se houver
              if (_errorMessage != null && _errorMessage!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: ErrorMessageWidget(
                    message: _errorMessage!, // Mensagem de erro a ser exibida
                    fontSize: 16.0,
                    onShow: () {
                      setState(() {
                        _isButtonDisabled =
                            true; // Desabilita botão ao mostrar erro
                      });
                    },
                    onHide: () {
                      setState(() {
                        _isButtonDisabled =
                            false; // Reabilita botão ao esconder erro
                      });
                    },
                  ),
                ),
            ],
          ),
          // Indicador de carregamento
          if (_isLoading) const LoadingIndicator(),
        ],
      ),
    );
  }

  // Método para construir o campo de entrada do email
  Widget _buildUsernameField() {
    return TextFormField(
      initialValue: _email, // Define o valor inicial como o email carregado
      decoration: const InputDecoration(labelText: 'Email'), // Texto do rótulo
      validator: validateEmail, // Valida o email
      onSaved: (value) => _email = value ?? '', // Salva o email
    );
  }

  // Método para construir o campo de entrada da senha
  Widget _buildPasswordField() {
    return TextFormField(
      initialValue: _password, // Define o valor inicial como a senha carregada
      obscureText: !_showPassword, // Oculta a senha se necessário
      decoration: InputDecoration(
        labelText: 'Senha', // Texto do rótulo
        suffixIcon: IconButton(
          icon: Icon(_showPassword
              ? Icons.visibility
              : Icons.visibility_off), // Ícone para alternar visibilidade
          onPressed: () {
            setState(() => _showPassword =
                !_showPassword); // Alterna o estado de visibilidade
          },
        ),
      ),
      validator: validatePassword, // Valida a senha
      onSaved: (value) => _password = value ?? '', // Salva a senha
    );
  }

  // Método para construir o botão de login
  Widget _buildLoginButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _isButtonDisabled
            ? null
            : _onLoginPressed, // Desabilita botão se necessário
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor:
              _isButtonDisabled ? Colors.grey : Colors.blue, // Cor do botão
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Bordas arredondadas
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 100, vertical: 10), // Padding do botão
        ),
        child: const Text(
          'LOGIN', // Texto do botão
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  // Método para construir o checkbox "lembrar-me"
  Widget _buildRememberMeCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe, // Estado do checkbox
          onChanged: (bool? value) {
            setState(() {
              _rememberMe = value ?? false; // Atualiza o estado do checkbox
            });
          },
        ),
        const Text("Lembrar-Me"), // Texto do checkbox
      ],
    );
  }
}
