import 'package:flutter/material.dart';

class ErrorMessageWidget extends StatelessWidget {
  final String message;

  const ErrorMessageWidget({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) {
      return const SizedBox.shrink(); // Não mostra nada se não houver mensagem.
    }

    // Calcula a posição da caixa de mensagem de erro baseada na presença do teclado.
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    final double bottomPadding = isKeyboardOpen
        ? 60.0
        : 0.0; // 60.0 é um valor arbitrário, ajuste conforme a necessidade.

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomPadding,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.red,
        width: double.infinity,
        child: Text(
          message,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
