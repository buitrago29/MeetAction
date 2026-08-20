import 'dart:math';
import 'package:flutter/material.dart';
import 'package:meet_action/core/theme/meet_action_theme.dart';

class WaveformVisualizer extends StatefulWidget {
  final bool isRecording;
  final int barCount;
  final double height;

  const WaveformVisualizer({
    super.key,
    required this.isRecording,
    this.barCount = 20,
    this.height = 100,
  });

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        if (widget.isRecording) {
          setState(() {});
        }
      });

    if (widget.isRecording) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant WaveformVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isRecording && _controller.isAnimating) {
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
    return Container(
      key: const Key('waveform_container'),
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(widget.barCount, (index) {
          final double barHeight = widget.isRecording
              ? max(12.0, _random.nextDouble() * widget.height * 0.9)
              : 8.0;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 5,
            height: barHeight,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  MeetActionTheme.primaryColor,
                  MeetActionTheme.secondaryColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: widget.isRecording
                  ? [
                      BoxShadow(
                        color: MeetActionTheme.primaryColor.withValues(alpha: 0.4),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
          );
        }),
      ),
    );
  }
}
