// lib/vibe_language/vibe_options.dart

/// Набор настроек для трансляции вибросигналов
class VibeOptions {
  /// С чего начинается последовательность кодов
  String codePrefix    = '~';
  /// Пауза между сигналами внутри символа
  int    internalPause = 200;
}