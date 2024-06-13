bool isFieldNotEmpty(String? value) {
  return value != null && value.isNotEmpty;
}

String? validateEmail(String? value) {
  if (!isFieldNotEmpty(value)) {
    return 'Por favor, insira seu email';
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
