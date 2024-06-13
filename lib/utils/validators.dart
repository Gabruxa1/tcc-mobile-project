bool isFieldNotEmpty(String? value) {
  return value != null && value.isNotEmpty;
}

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

String? validatePassword(String? value) {
  if (!isFieldNotEmpty(value)) {
    return 'Por favor, insira sua senha';
  }
  if (value!.length < 6) {
    return 'A senha deve ter pelo menos 6 caracteres';
  }

  return null;
}

bool validateRememberMe(bool value) {
  return value;
}
