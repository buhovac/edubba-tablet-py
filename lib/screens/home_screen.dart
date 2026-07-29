import 'package:flutter/material.dart';

import '../config/app_quiz_config.dart';
import '../models/app_progress.dart';
import '../services/progress_service.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProgressService _progressService = ProgressService();
  late Future<AppProgress> _progressFuture;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  void _loadProgress() {
    _progressFuture = _progressService.getProgress();
  }

  Future<void> _resetProgress() async {
    await _progressService.resetAll();
    setState(() {
      _loadProgress();
    });
  }

  String _levelLabel(int level) {
    switch (level) {
      case 1:
        return 'Novice';
      case 2:
        return 'Intermediate';
      case 3:
        return 'Advanced';
      default:
        return 'Unknown';
    }
  }

  String _skillRank(AppProgress progress) {
    final completedLevels = _completedLevelsCount(progress);
    final accuracy = progress.percentage;

    if (completedLevels == 0) return 'Unranked';
    if (completedLevels <= 2) return 'Starter';
    if (completedLevels <= 5) return 'Beginner';
    if (completedLevels <= 8) return 'Developing';
    if (completedLevels <= 11) return 'Intermediate';
    if (completedLevels <= 14) return 'Advanced';

    return accuracy >= 90 ? 'Master' : 'Advanced';
  }

  int _completedLevelsCount(AppProgress progress) {
    int total = 0;

    for (final category in appQuizConfig.categories) {
      final unlocked = progress.unlockedLevelForCategory(category.id);
      total += unlocked - 1;
    }

    return total.clamp(0, appQuizConfig.categories.length * 3);
  }

  int _totalLevelsCount() {
    return appQuizConfig.categories.length * 3;
  }

  void _openQuiz(int level, int categoryId) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => QuizScreen(
              level: level,
              categoryId: categoryId,
            ),
          ),
        )
        .then((_) {
          setState(() {
            _loadProgress();
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF6F4FD8);
    const accentSoft = Color(0xFFEDE7F8);
    const textMuted = Color(0xFF7A6A8F);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edubba Quiz'),
        centerTitle: false,
      ),
      body: FutureBuilder<AppProgress>(
        future: _progressFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Unable to load progress',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _loadProgress();
                        });
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final progress = snapshot.data ?? AppProgress.initial();
          final completedLevels = _completedLevelsCount(progress);
          final totalLevels = _totalLevelsCount();

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 4),
                Text(
                  'Edubba Quiz',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sharpen your coding skills through structured challenge levels.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: textMuted,
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Progress',
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _StatChip(
                              label: 'Rank',
                              value: _skillRank(progress),
                              icon: Icons.workspace_premium,
                              background: accentSoft,
                              foreground: accent,
                            ),
                            _StatChip(
                              label: 'Accuracy',
                              value:
                                  '${progress.percentage.toStringAsFixed(1)}%',
                              icon: Icons.percent,
                              background: accentSoft,
                              foreground: accent,
                            ),
                            _StatChip(
                              label: 'Levels',
                              value: '$completedLevels/$totalLevels',
                              icon: Icons.flag,
                              background: accentSoft,
                              foreground: accent,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: accentSoft,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Learning Profile',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: accent,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Answered: ${progress.totalAnswered}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Correct: ${progress.totalCorrect}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${appQuizConfig.masteryTitle}: ${progress.fanMasterUnlocked ? "Unlocked" : "Not yet"}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Categories',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete levels category by category to build a stronger skill profile.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: textMuted,
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 16),
                ...appQuizConfig.categories.map((category) {
                  final unlockedLevel =
                      progress.unlockedLevelForCategory(category.id);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category.description,
                              style:
                                  Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        height: 1.45,
                                      ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: accentSoft,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.auto_awesome,
                                    size: 20,
                                    color: accent,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Unlocked up to ${_levelLabel(unlockedLevel)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: accent,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...List.generate(3, (index) {
                              final level = index + 1;
                              final unlocked = level <= unlockedLevel;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: unlocked
                                    ? ElevatedButton(
                                        onPressed: () =>
                                            _openQuiz(level, category.id),
                                        child: Text(
                                          'Start ${category.title} · ${_levelLabel(level)}',
                                        ),
                                      )
                                    : ElevatedButton(
                                        onPressed: null,
                                        child: Text(
                                          '${category.title} · ${_levelLabel(level)} Locked',
                                        ),
                                      ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _resetProgress,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset Progress'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color background;
  final Color foreground;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 140),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: foreground,
            size: 22,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}