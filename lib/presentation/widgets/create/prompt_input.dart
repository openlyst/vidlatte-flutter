import 'package:flutter/material.dart';

import '../../../config/constants.dart';

class PromptInput extends StatelessWidget {
  final TextEditingController controller;
  final int maxLength;

  const PromptInput({
    super.key,
    required this.controller,
    this.maxLength = 2000,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Prompt', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: ThemeConstants.spacingSmall),
        TextField(
          controller: controller,
          maxLength: maxLength,
          maxLines: 4,
          minLines: 3,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(
            hintText: 'Describe the image you want to generate...',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}
