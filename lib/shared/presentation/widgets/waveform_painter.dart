import 'dart:math' as math;
import 'package:flutter/material.dart';

class WaveformVisualizer extends StatefulWidget {
  const WaveformVisualizer({
    this.isActive = true,
    this.color,
    super.key,
  });

  final bool isActive;
  final Color? color;

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant WaveformVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final waveColor = widget.color ?? Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(double.infinity, 80),
          painter: _WaveformPainter(
            animationValue: _controller.value,
            isActive: widget.isActive,
            color: waveColor,
          ),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.animationValue,
    required this.isActive,
    required this.color,
  });

  final double animationValue;
  final bool isActive;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final barCount = 28;
    final spacing = size.width / (barCount - 1);
    final centerY = size.height / 2;

    for (int i = 0; i < barCount; i++) {
      final x = i * spacing;
      
      // Generate a beautiful organic wave using multiple sine waves combined with animation value
      double heightMultiplier = 0.15;
      if (isActive) {
        // Create a envelope to keep the ends shorter than the middle
        final normalizedPosition = i / (barCount - 1);
        final envelope = math.sin(normalizedPosition * math.pi); // 0 at ends, 1 in middle

        final phase1 = animationValue * 2 * math.pi;
        final phase2 = animationValue * 4 * math.pi + (i * 0.5);
        
        heightMultiplier = 0.15 + 0.85 * (
          (math.sin(phase1 + i * 0.4) * 0.5 + 0.5) * 0.6 +
          (math.cos(phase2) * 0.5 + 0.5) * 0.4
        ) * envelope;
      }

      final maxBarHeight = size.height - 8;
      final barHeight = maxBarHeight * heightMultiplier;

      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isActive != isActive ||
        oldDelegate.color != color;
  }
}
