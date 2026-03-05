import 'dart:io';
import 'dart:convert';

import 'package:vibe_echo/core/failures.dart';

class VibrosymbolsRepository {
  // Анонимный конструктор, чтобы обеспечить синглтон.
  VibrosymbolsRepository._();
  
  // Публичный единственный экземпляр
  static final instance = VibrosymbolsRepository._();

  final Map<String, String> data = {};

  /// Бросает исключения.
  static Future<VibrosymbolsRepository> create({
    required String fullPath
  }) async {
    await instance._load(fullPath);
    return instance;
  }
    
  Future<void> _load(String fullPath) async {
    final file = File(fullPath);
    if (! await file.exists()) {
      throw FileNotFoundFailure(filename: fullPath);
    }

    final content = await file.readAsString();
    final trimmedContent = content.trim();

    if (trimmedContent.isEmpty) {
      throw DataIsEmptyFailure('File $fullPath is empty.');
    }

    data.clear();
    data.addAll(
      Map<String, String>.from(
        jsonDecode(trimmedContent)
      )
    );
  }
}