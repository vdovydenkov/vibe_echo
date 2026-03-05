// lib/vibe_echo_app.dart

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:get_it/get_it.dart';

import 'package:vibe_echo/config/constants.dart';
import 'package:vibe_echo/features/home/ui/home_screen.dart';
import 'package:vibe_echo/config/configurator.dart';
import 'package:vibe_echo/features/vibe_translator/haptics/haptic_interface.dart';

class VibeEchoApp extends StatelessWidget {
  const VibeEchoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.instance;

    return MaterialApp(
      title: appTitle,
      home: HomeScreen(
        logger: getIt<Logger>(),
        vibeDevice: getIt<HapticEngine>(),
        cfg: getIt<Config>(),
      ),
    );
  }
}

