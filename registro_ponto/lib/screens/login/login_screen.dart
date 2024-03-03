import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const LoginPage({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _rememberMe = false;
  bool _isDarkTheme = false;
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = _isDarkTheme
        ? ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF1b1e23),
            primaryColor: Colors.white,
            switchTheme: SwitchThemeData(
              trackColor: MaterialStateProperty.all(Colors.blue),
              thumbColor: MaterialStateProperty.all(Colors.blue),
            ),
          )
        : ThemeData.light().copyWith(
            primaryColor: Colors.black,
            switchTheme: SwitchThemeData(
              thumbColor: MaterialStateProperty.all(Colors.white),
            ),
          );

    return Theme(
      data: themeData,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: _isDarkTheme,
                        activeTrackColor: Colors.blue,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.white.withOpacity(0.7),
                        onChanged: (value) {
                          setState(() {
                            _isDarkTheme = value;
                          });
                          widget.toggleTheme();
                        },
                      ),
                      Icon(
                        _isDarkTheme ? Icons.nightlight_round : Icons.wb_sunny,
                        color: _isDarkTheme ? Colors.white : Colors.black,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  "Bem Vindo Novamente",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Informe o Usuário e Senha",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Usuário'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu usuário';
                          }
                          return null;
                        },
                        onSaved: (value) => _username = value!,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          suffixIcon: IconButton(
                            icon: Icon(_showPassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira sua senha';
                          }
                          return null;
                        },
                        onSaved: (value) => _password = value!,
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  if (kDebugMode) {
                                    print(
                                        'Usuário: $_username, Senha: $_password');
                                  }
                                  // Navegar para a próxima tela ao clicar no botão de login
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/registroPonto',
                                    (route) => true,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                side: const BorderSide(
                                    color: Colors.blue, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text('LOGIN'),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value!;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          const Text("Lembrar-Me"),
                          //TODO: Adicionar login automatico quando inserido
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
