import 'package:flutter/material.dart';

import '../config/app_quiz_config.dart';
import '../domain/level_rules.dart';
import '../domain/quiz_engine.dart';
import '../domain/quiz_state.dart';
import '../services/progress_service.dart';
import '../widgets/answer_button.dart';
import '../widgets/progress_bar.dart';
import '../widgets/question_card.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final int level;
  final int categoryId;

  const QuizScreen({
    super.key,
    required this.level,
    required this.categoryId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizEngine _engine = QuizEngine();
  final ProgressService _progressService = ProgressService();

  QuizState? _state;
  Object? _error;

  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final s = await _engine.start(
        level: widget.level,
        categoryId: widget.categoryId,
      );

      if (!mounted) return;

      setState(() {
        _state = s;
        _error = null;
        _locked = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e;
        _locked = false;
      });
    }
  }

  void _openResultScreen(QuizResult result) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          result: result,
        ),
      ),
    );
  }

  void _answer(int choiceIndex) {
    if (_locked) return;
    _locked = true;

    try {
      final s = _engine.answer(choiceIndex);

      if (s.finished) {
        final r = _engine.finish();

        _progressService.updateAfterQuiz(r).then((_) {
          if (!mounted) return;

          setState(() {
            _state = s;
            _locked = false;
          });

          _openResultScreen(r);
        }).catchError((e) {
          if (!mounted) return;

          setState(() {
            _error = e;
            _locked = false;
          });
        });

        return;
      }

      setState(() {
        _state = s;
        _locked = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _locked = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      );
    }

    if (_state == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final s = _state!;
    final q = s.current;
    final categoryTitle =
        appQuizConfig.getCategoryById(s.categoryId)?.title ??
        'Category ${s.categoryId}';

    final hasCodeBlock =
        q.questionFormat == 'code' && q.codeSnippet.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$categoryTitle - ${LevelRules.label(s.level)} (${s.currentIndex + 1}/${s.questions.length})',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            QuizProgressBar(
              currentIndex: s.currentIndex,
              total: s.questions.length,
            ),
            const SizedBox(height: 16),
            QuestionCard(
              questionText: q.question,
              codeSnippet: q.codeSnippet,
              showCodeBlock: hasCodeBlock,
            ),
            const SizedBox(height: 16),
            ...List.generate(4, (i) {
              final choiceText = q.choices[i].trim().isEmpty
                  ? '(empty choice)'
                  : q.choices[i];

              return AnswerButton(
                text: choiceText,
                onPressed: _locked ? null : () => _answer(i),
              );
            }),
            const Spacer(),
            Text(
              'Correct: ${s.correct} / Answered: ${s.answered}',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}