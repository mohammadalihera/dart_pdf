import '../../widgets.dart';
import '../pdf/obj/ansi_converter.dart';

enum TextType { Default, ANSI }

extension AnsiConverter on TextSpan {
  TextSpan toAnsiOrUnicodeText(
      {required String text,
      TextType textType = TextType.Default,
      Font? ansiFont,
      Font? unicodeFont,
      TextStyle? textStyle}) {
    assert(ansiFont != null);
    assert(unicodeFont != null);

    final children = <InlineSpan>[];
    final srcText = text.trim();

    final englishCharRegex = RegExp(r'[A-Za-z0-9]');
    // RegExp(r'^[\u0980-\u09FF\u0964\u0965\u2018\u2019\u201C\u201D\u200C]+$');
    if (srcText.isNotEmpty && textType == TextType.Default) {
      final splitedText = srcText.split(' ');
      var wasBangla = false;
      var printableText = '';

      for (var words in splitedText) {
        final currentIsBangla = !englishCharRegex.hasMatch(words.trim());

        if (currentIsBangla) {
          if (!wasBangla) {
            if (printableText.isNotEmpty) {
              printableText = reArrangeText(printableText.trim());
              children.add(TextSpan(
                  text: printableText + ' ',
                  style: textStyle != null ? textStyle.copyWith(font: unicodeFont) : TextStyle(font: unicodeFont)));
            }
            printableText = '';
          }
          wasBangla = true;
        } else {
          if (wasBangla) {
            if (printableText.isNotEmpty) {
              printableText = convertToANSI(printableText);
              children.add(TextSpan(
                  text: printableText + ' ',
                  style: textStyle != null ? textStyle.copyWith(font: ansiFont) : TextStyle(font: ansiFont)));
            }
            printableText = '';
          }
          wasBangla = false;
        }

        printableText += words + ' ';
      }

      if (printableText.isNotEmpty) {
        if (wasBangla) {
          printableText = convertToANSI(printableText);
          children.add(TextSpan(
              text: printableText + ' ',
              style: textStyle != null ? textStyle.copyWith(font: ansiFont) : TextStyle(font: ansiFont)));
        } else {
          printableText = reArrangeText(printableText.trim());
          children.add(TextSpan(
              text: printableText + ' ',
              style: textStyle != null ? textStyle.copyWith(font: unicodeFont) : TextStyle(font: unicodeFont)));
        }
      }
    }

    if (srcText.isNotEmpty && textType == TextType.ANSI) {
      children.add(TextSpan(
          text: srcText, style: textStyle != null ? textStyle.copyWith(font: ansiFont) : TextStyle(font: ansiFont)));
    }

    final textSpan = TextSpan(children: children);
    return textSpan;
  }
}
