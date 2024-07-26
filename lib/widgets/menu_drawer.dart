import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:registro_ponto/services/auth_service.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String _version = '';
  final AuthService _authService = AuthService();
  String _email = '';

  @override
  void initState() {
    super.initState();
    _fetchVersion();
    _fetchEmail();
  }

  Future<void> _fetchVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
    });
  }

  Future<void> _fetchEmail() async {
    final credentials = await _authService.getSavedCredentials();
    if (credentials != null) {
      setState(() {
        _email = credentials['email']!;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.clearCredentials();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    String currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    return Drawer(
      child: Column(
        children: [
          CustomDrawerHeader(
            email: _email,
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Registro de Ponto'),
                  tileColor: currentRoute == '/registroPonto'
                      ? Colors.blue[100]
                      : null,
                  onTap: () {
                    if (currentRoute != '/registroPonto') {
                      Navigator.pushNamed(context, '/registroPonto');
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: const Text('Gerar Relatório'),
                  tileColor: currentRoute == '/gerarRelatorio'
                      ? Colors.blue[100]
                      : null,
                  onTap: () {
                    if (currentRoute != '/gerarRelatorio') {
                      Navigator.pushNamed(context, '/gerarRelatorio');
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Configurações'),
                  tileColor: currentRoute == '/configuracoes'
                      ? Colors.blue[100]
                      : null,
                  onTap: () {
                    if (currentRoute != '/configuracoes') {
                      Navigator.pushNamed(context, '/configuracoes');
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_add),
                  title: const Text('Cadastro'),
                  tileColor:
                      currentRoute == '/cadastro' ? Colors.blue[100] : null,
                  onTap: () {
                    if (currentRoute != '/cadastro') {
                      Navigator.pushNamed(context, '/cadastro');
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.red),
                  title: const Text(
                    'Sair',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: _logout,
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Versão $_version',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomDrawerHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final String? email;

  const CustomDrawerHeader({super.key, this.email});

  @override
  Size get preferredSize {
    return const Size.fromHeight(200);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      height: preferredSize.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.blue,
            child: Column(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 60,
                  child: Icon(Icons.person, size: 90, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(
                  email ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
