import 'package:flutter/material.dart';

import '../../../config/constants.dart';
import '../../../i18n/app_strings.dart';

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
    return TextField(
      controller: controller,
      maxLength: maxLength,
      maxLines: 4,
      minLines: 3,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        hintText: AppStrings.of(context).describeImage,
        alignLabelWithHint: true,
      ),
    );
  }
}
