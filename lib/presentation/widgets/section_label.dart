import 'package:flutter/material.dart';
import 'package:skylo/presentation/theme/app_theme.dart';

/// Thin hairline section label with a red tick — the only ornament.
class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          color: context.skylo.accent,
        ),
        const SizedBox(width: 10),
        Text(text.toUpperCase(), style: AppText.label(context)),
      ],
    );
  }
}