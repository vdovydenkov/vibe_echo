// lib/main.dart

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// Собственные модули
import 'package:vibe_echo/vibe_echo_app.dart';
import 'package:vibe_echo/bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final getIt = GetIt.instance;
  registerLogger(getIt);
  await registerVibeDevice(getIt);
  await registerConfig(getIt);

  runApp(const VibeEchoApp());
}

