import 'package:flutter/material.dart';

class ExplanationCard extends StatelessWidget {
  final bool isCorrect;
  final String correctAnswer;
  final String explanation;
  final VoidCallback onNext;

  const ExplanationCard({
    super.key,
    required this.isCorrect,
    required this.correctAnswer,
    required this.explanation,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final title = isCorrect ? 'Correct' : 'Incorrect';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Correct answer: $correctAnswer',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (explanation.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                explanation,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNext,
                child: const Text('Next Question'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}