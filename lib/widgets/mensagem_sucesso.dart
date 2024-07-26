import 'dart:async';
import 'package:flutter/material.dart';

class SuccessMessageWidget extends StatefulWidget {
  final String message;
  final double fontSize;
  final Duration duration;
  final VoidCallback onShow;
  final VoidCallback onHide;

  const SuccessMessageWidget({
    super.key,
    required this.message,
    required this.onShow,
    required this.onHide,
    this.fontSize = 14.0,
    this.duration = const Duration(seconds: 3),
  });

  @override
  _SuccessMessageWidgetState createState() => _SuccessMessageWidgetState();
}

class _SuccessMessageWidgetState extends State<SuccessMessageWidget> {
  late Timer _timer;
  double _progress = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onShow();
    });
    _startTimer();
  }

  void _startTimer() {
    const tick = Duration(milliseconds: 100);
    final totalTicks = widget.duration.inMilliseconds ~/ tick.inMilliseconds;
    int ticksElapsed = 0;

    _timer = Timer.periodic(tick, (timer) {
      setState(() {
        _progress = 1 - (ticksElapsed / totalTicks);
        ticksElapsed++;
      });

      if (ticksElapsed >= totalTicks) {
        timer.cancel();
        _dismissWidget();
      }
    });
  }

  void _dismissWidget() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        widget.onHide();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.green.withOpacity(0.9),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.message,
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.fontSize,
                decoration: TextDecoration.none,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
