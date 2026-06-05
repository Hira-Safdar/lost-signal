import 'package:flutter/material.dart';

import '../../../shared/theme/app_theme.dart';

class SignalMeter extends StatelessWidget {
  const SignalMeter({super.key, required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final safeValue = value.clamp(0.0, 1.0);

    return SizedBox(
      width: 46,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Icon(Icons.network_cell, color: AppTheme.signalGreen, size: 18),
          const SizedBox(height: 3),
          LinearProgressIndicator(
            value: safeValue,
            minHeight: 3,
            backgroundColor: const Color(0xFF26303D),
            color: safeValue < 0.35
                ? AppTheme.warningRed
                : AppTheme.signalGreen,
          ),
        ],
      ),
    );
  }
}
