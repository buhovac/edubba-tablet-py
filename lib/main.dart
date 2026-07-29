import 'package:flutter/material.dart';

import 'config/app_quiz_config.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appQuizConfig.appTitle,
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}