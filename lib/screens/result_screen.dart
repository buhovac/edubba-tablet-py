import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../config/app_quiz_config.dart';
import '../domain/level_rules.dart';
import '../domain/quiz_state.dart';
import '../services/share_text_builder.dart';
import 'quiz_screen.dart';

class ResultScreen extends StatelessWidget {
  final QuizResult result;

  const ResultScreen({
    super.key,
    required this.result,
  });

  bool get hasNextLevel => result.passed && result.level < 3;
  bool get isCategoryComplete => result.passed && result.level == 3;

  Future<void> _shareResult() async {
    final text = ShareTextBuilder.build(
      result: result,
      config: appQuizConfig,
    );

    await SharePlus.instance.share(
      ShareParams(text: text),
    );
  }

  void _playAgain(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          level: result.level,
          categoryId: result.categoryId,
        ),
      ),
    );
  }

  void _goToNextLevel(BuildContext context) {
    if (!hasNextLevel) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          level: result.level + 1,
          categoryId: result.categoryId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryTitle =
        appQuizConfig.getCategoryById(result.categoryId)?.title ??
        'Category ${result.categoryId}';
    final accuracy = ((result.correct / result.total) * 100).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      '$categoryTitle / ${LevelRules.label(result.level)}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      result.passed ? 'PASSED' : 'FAILED',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Score: ${result.correct}/${result.total}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Accuracy: $accuracy%',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (hasNextLevel) ...[
              ElevatedButton(
                onPressed: () => _goToNextLevel(context),
                child: const Text('Next Level'),
              ),
              const SizedBox(height: 10),
            ],
            if (isCategoryComplete) ...[
              const Text(
                'Category Complete',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
            ],
            ElevatedButton(
              onPressed: () => _playAgain(context),
              child: const Text('Play Again'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _shareResult,
              child: const Text('Share Result'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}