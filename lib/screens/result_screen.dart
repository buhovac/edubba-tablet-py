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

  String _buildResultTitle() {
    return result.passed ? 'You mastered this level.' : 'Keep practicing.';
  }

  String _buildInsight() {
    final accuracy = result.correct / result.total;

    if (accuracy >= 0.95) {
      return 'You show strong understanding of core concepts and consistent answer quality.';
    }
    if (accuracy >= 0.75) {
      return 'You have a solid foundation. Focus on weak spots to improve speed and precision.';
    }
    return 'You are building familiarity with the topic. Repetition and explanation review will help.';
  }

  String _buildNextStep() {
    if (hasNextLevel) {
      return 'Advance to the next level to tackle more complex questions.';
    }

    if (isCategoryComplete) {
      return 'This category is complete. Move to another category to expand your skill profile.';
    }

    return 'Replay this level and aim for a stronger score and higher consistency.';
  }

  @override
  Widget build(BuildContext context) {
    final categoryTitle =
        appQuizConfig.getCategoryById(result.categoryId)?.title ??
        'Category ${result.categoryId}';

    final accuracy = ((result.correct / result.total) * 100).toStringAsFixed(1);
    final levelLabel = LevelRules.label(result.level);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      appQuizConfig.appTitle,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF4F378B),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sharpen your coding skills',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF7A6A8F),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          children: [
                            Text(
                              'Performance Summary',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '$categoryTitle / $levelLabel',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: const Color(0xFF6F4FD8),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              _buildResultTitle(),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 18),
                            const Divider(),
                            const SizedBox(height: 8),
                            _MetricRow(
                              icon: Icons.check_circle,
                              label: 'Score',
                              value: '${result.correct}/${result.total}',
                            ),
                            const SizedBox(height: 12),
                            _MetricRow(
                              icon: Icons.percent,
                              label: 'Accuracy',
                              value: '$accuracy%',
                            ),
                            const SizedBox(height: 12),
                            _MetricRow(
                              icon: Icons.local_fire_department,
                              label: 'Consistency',
                              value: '${result.correct}/${result.total}',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.lightbulb,
                                  color: Color(0xFFE5A73B),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Insight',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _buildInsight(),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    height: 1.5,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF6F4FD8),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Next Step',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF6F4FD8),
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _buildNextStep(),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    height: 1.5,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (hasNextLevel) ...[
                ElevatedButton(
                  onPressed: () => _goToNextLevel(context),
                  child: const Text('Start Next Level'),
                ),
                const SizedBox(height: 12),
              ],
              ElevatedButton(
                onPressed: () => _playAgain(context),
                child: const Text('Play Again'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _shareResult,
                child: const Text('Share Result'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF6F4FD8),
          size: 28,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}