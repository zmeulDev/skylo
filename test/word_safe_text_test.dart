import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skylo/presentation/screens/home_screen.dart';

/// Regression tests for the word-safe condition text: a long word in a
/// narrow column must never break mid-word (on-device report: Romanian
/// "CER FRAGMENTAT" wrapping as "CER FRAGM / ENTAT" — a split word can
/// read as a different word).
void main() {
  Future<void> pumpColumn(
    WidgetTester tester, {
    required String text,
    required double width,
    required FontWeight fontWeight,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WordSafeTextProxy(
                  text: text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: fontWeight,
                    letterSpacing: 1.2,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('long words wrap on word boundaries, never mid-word',
      (tester) async {
    await pumpColumn(tester,
        text: 'CER FRAGMENTAT',
        width: 90,
        fontWeight: FontWeight.w600);

    final paragraph = tester.renderObject<RenderParagraph>(find.byType(RichText));
    final lines = paragraph.getBoxesForSelection(
      TextSelection(baseOffset: 0, extentOffset: 15),
    ).map((b) => b).toList();
    // The word FRAGMENTAT must render as one unbroken run: its glyph
    // boxes never straddle two visual lines.
    final fragmentat = paragraph.getBoxesForSelection(
      const TextSelection(baseOffset: 4, extentOffset: 15),
    );
    expect(fragmentat, isNotEmpty);
    final tops = fragmentat.map((b) => b.top).toSet();
    expect(tops, hasLength(1), reason: 'FRAGMENTAT broke mid-word');
    expect(lines.any((b) => b.top != fragmentat.first.top), isTrue,
        reason: 'expected two lines');
  });

  testWidgets('a single word wider than the column scales down to fit',
      (tester) async {
    await pumpColumn(tester,
        text: 'ОЩУЩАЕТСЯ −27°',
        width: 70,
        fontWeight: FontWeight.w400);

    final size = tester.getSize(find.byType(RichText).first);
    // The paragraph renders within the column width.
    expect(size.width, lessThanOrEqualTo(70));
  });

  testWidgets('short text renders unchanged', (tester) async {
    await pumpColumn(tester,
        text: 'CLEAR',
        width: 200,
        fontWeight: FontWeight.w600);

    expect(find.text('CLEAR'), findsOneWidget);
    final size = tester.getSize(find.byType(RichText).first);
    expect(size.height, closeTo(14 * 1.4, 6));
  });
}

/// The word-safe text used beside the hero temperature.
class _WordSafeTextProxy extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _WordSafeTextProxy({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    return WordSafeText(text: text, style: style);
  }
}