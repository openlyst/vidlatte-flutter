import 'package:flutter/material.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';

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
    final ext = Theme.of(context).extension<AppColors>()!;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
        gradient: LinearGradient(
          colors: [
            ext.accent.withValues(alpha: 0.06),
            ext.accentGradientEnd.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: ext.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(4),
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        maxLines: 4,
        minLines: 3,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          hintText: 'Describe the image you want to generate...',
          hintStyle: TextStyle(color: ext.muted, fontSize: 15),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}
