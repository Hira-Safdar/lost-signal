import 'package:flutter/material.dart';

import '../../../shared/theme/app_theme.dart';

class ChoiceButton extends StatelessWidget {
  const ChoiceButton({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.signalGreen,
          side: const BorderSide(color: Color(0xFF2D8C73)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}
