import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AnswerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSelected;
  final bool isCorrectAnswer;
  final bool isWrongSelected;
  final bool isLocked;

  const AnswerButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSelected = false,
    this.isCorrectAnswer = false,
    this.isWrongSelected = false,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Neutral/outlined by default — both for the unanswered state and for a
    // wrong option the user didn't pick once answers are locked.
    Color background = Colors.transparent;
    Color foreground = colorScheme.onSurface;
    Color border = AppColors.charcoalOutline;

    if (isLocked) {
      if (isCorrectAnswer) {
        background = colorScheme.primary;
        foreground = colorScheme.onPrimary;
        border = colorScheme.primary;
      } else if (isWrongSelected) {
        background = colorScheme.error;
        foreground = colorScheme.onError;
        border = colorScheme.error;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: background,
            foregroundColor: foreground,
            disabledBackgroundColor: background,
            disabledForegroundColor: foreground,
            side: BorderSide(color: border, width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}