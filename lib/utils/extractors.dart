// lib/utils/extractors.dart
/// Набор функций для извлечения значений
library;

/// Извлекает целое число из строки
/// after  - последовательность символов, после которой ожидается число;
/// source - исходная строка.
int? extractInt({
  required String after,
  required String source,
}) {
  // Вытаскиваем число после экранированного after
  final match = RegExp('${RegExp.escape(after)}(\\d+)')
      .firstMatch(source);
  return match != null ? int.tryParse(match.group(1)!) : null;
}