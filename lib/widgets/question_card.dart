import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class QuestionCard extends StatelessWidget {
  final String questionText;
  final String codeSnippet;
  final bool showCodeBlock;

  const QuestionCard({
    super.key,
    required this.questionText,
    required this.codeSnippet,
    required this.showCodeBlock,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionText,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            if (showCodeBlock) _CodeBlock(code: codeSnippet),
          ],
        ),
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  final String code;

  const _CodeBlock({
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.charcoalDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.charcoalOutline),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText(
          code,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}