import 'package:flutter/material.dart';

import '../../../i18n/app_strings.dart';

class PromptInput extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController? negativeController;
  final int maxLength;

  const PromptInput({
    super.key,
    required this.controller,
    this.negativeController,
    this.maxLength = 2000,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          maxLength: maxLength,
          maxLines: 4,
          minLines: 3,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: s.describeImage,
            alignLabelWithHint: true,
          ),
        ),
        if (negativeController != null) ...[
          const SizedBox(height: 8),
          TextField(
            controller: negativeController,
            maxLines: 2,
            minLines: 1,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              labelText: s.negativePrompt,
              hintText: s.negativePromptHint,
              alignLabelWithHint: true,
              isDense: true,
              prefixIcon: const Icon(Icons.block, size: 18),
            ),
          ),
        ],
      ],
    );
  }
}
