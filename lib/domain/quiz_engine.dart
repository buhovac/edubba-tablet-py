import '../services/question_repository.dart';
import 'level_rules.dart';
import 'quiz_state.dart';

class QuizEngine {
  final QuestionRepository _repo;

  QuizState? _state;

  QuizEngine({QuestionRepository? repo}) : _repo = repo ?? QuestionRepository();

  QuizState get state {
    final s = _state;
    if (s == null) throw StateError('Quiz not started');
    return s;
  }

  Future<QuizState> start({
    required int level,
    required int categoryId,
  }) async {
    final count = LevelRules.questionsCount(level);
    final questions = await _repo.forGame(
      level: level,
      categoryId: categoryId,
      count: count,
    );

    _state = QuizState(
      level: level,
      categoryId: categoryId,
      questions: questions,
      currentIndex: 0,
      correct: 0,
      answered: 0,
      finished: false,
      showingFeedback: false,
      selectedChoiceIndex: null,
      lastAnswerCorrect: null,
    );

    return state;
  }

  QuizState answer(int choiceIndex) {
    final s = state;
    if (s.finished || s.showingFeedback) return s;

    final q = s.current;
    final isCorrect = choiceIndex == q.correctIndex;

    _state = s.copyWith(
      answered: s.answered + 1,
      correct: s.correct + (isCorrect ? 1 : 0),
      showingFeedback: true,
      selectedChoiceIndex: choiceIndex,
      lastAnswerCorrect: isCorrect,
    );

    return state;
  }

  QuizState nextQuestion() {
    final s = state;
    if (s.finished) return s;
    if (!s.showingFeedback) return s;

    final isLast = s.currentIndex >= s.questions.length - 1;

    if (isLast) {
      _state = s.copyWith(
        finished: true,
        showingFeedback: false,
      );
      return state;
    }

    _state = s.copyWith(
      currentIndex: s.currentIndex + 1,
      showingFeedback: false,
      clearSelectedChoice: true,
      clearLastAnswerCorrect: true,
    );

    return state;
  }

  QuizResult finish() {
    final s = state;
    if (!s.finished) throw StateError('Quiz not finished');

    final total = s.questions.length;
    final threshold = LevelRules.passThreshold(s.level);
    final passed = s.correct >= threshold;

    return QuizResult(
      level: s.level,
      categoryId: s.categoryId,
      correct: s.correct,
      total: total,
      passed: passed,
    );
  }
}