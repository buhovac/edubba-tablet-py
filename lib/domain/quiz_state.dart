import '../models/question.dart';

class QuizState {
  final int level;
  final int categoryId;
  final List<Question> questions;
  final int currentIndex;
  final int correct;
  final int answered;
  final bool finished;

  final bool showingFeedback;
  final int? selectedChoiceIndex;
  final bool? lastAnswerCorrect;

  const QuizState({
    required this.level,
    required this.categoryId,
    required this.questions,
    required this.currentIndex,
    required this.correct,
    required this.answered,
    required this.finished,
    required this.showingFeedback,
    required this.selectedChoiceIndex,
    required this.lastAnswerCorrect,
  });

  Question get current => questions[currentIndex];

  QuizState copyWith({
    int? currentIndex,
    int? correct,
    int? answered,
    bool? finished,
    bool? showingFeedback,
    int? selectedChoiceIndex,
    bool? lastAnswerCorrect,
    bool clearSelectedChoice = false,
    bool clearLastAnswerCorrect = false,
  }) {
    return QuizState(
      level: level,
      categoryId: categoryId,
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      correct: correct ?? this.correct,
      answered: answered ?? this.answered,
      finished: finished ?? this.finished,
      showingFeedback: showingFeedback ?? this.showingFeedback,
      selectedChoiceIndex: clearSelectedChoice
          ? null
          : (selectedChoiceIndex ?? this.selectedChoiceIndex),
      lastAnswerCorrect: clearLastAnswerCorrect
          ? null
          : (lastAnswerCorrect ?? this.lastAnswerCorrect),
    );
  }
}

class QuizResult {
  final int level;
  final int categoryId;
  final int correct;
  final int total;
  final bool passed;

  const QuizResult({
    required this.level,
    required this.categoryId,
    required this.correct,
    required this.total,
    required this.passed,
  });
}