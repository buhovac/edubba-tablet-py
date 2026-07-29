import 'package:flutter/material.dart';

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
    Color? background;
    Color? foreground;
    OutlinedBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(999),
    );

    if (isLocked) {
      final colorScheme = Theme.of(context).colorScheme;

      if (isCorrectAnswer) {
        background = colorScheme.primary;
        foreground = colorScheme.onPrimary;
      } else if (isWrongSelected) {
        background = colorScheme.error;
        foreground = colorScheme.onError;
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
            shape: shape,
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