// Uma função genérica para validar se o campo é vazio
bool isFieldNotEmpty(String? value) {
  return value != null && value.isNotEmpty;
}

// Validação específica para o nome de usuário
String? validateEmail(String? value) {
  String pattern =
      r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+(\.[a-zA-Z]+)?$';
  RegExp regex = RegExp(pattern);

  if (value == null || value.isEmpty) {
    return 'Por favor, insira seu email';
  } else if (!regex.hasMatch(value)) {
    return 'Por favor, insira um e-mail válido';
  }

  return null;
}

// Validação específica para a senha
String? validatePassword(String? value) {
  if (!isFieldNotEmpty(value)) {
    return 'Por favor, insira sua senha';
  }
  if (value!.length < 6) {
    // Supondo que a senha deve ter pelo menos 6 caracteres
    return 'A senha deve ter pelo menos 6 caracteres';
  }
  // Adicione aqui outras regras específicas para a senha, se necessário
  return null;
}

// Validação para o campo Lembrar-Me, se aplicável
bool validateRememberMe(bool value) {
  // Aqui você pode adicionar lógica para validar se o usuário quer ser lembrado ou não
  return value;
}
