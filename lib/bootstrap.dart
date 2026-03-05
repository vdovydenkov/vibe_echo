// lib/bootstrap.dart

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import 'package:vibe_echo/core/logger_config.dart';
import 'package:vibe_echo/features/vibe_translator/haptics/haptic_factory.dart';
import 'package:vibe_echo/features/vibe_translator/haptics/haptic_interface.dart';
import 'package:vibe_echo/config/configurator.dart';


void registerLogger(GetIt getIt) {
  final logger = initLogger();  
  logger.i('Starting...');
  getIt.registerSingleton<Logger>(logger);
}

Future registerVibeDevice(GetIt getIt) async {
  final vibeDevice = await createHapticEngine();
  final logger = getIt<Logger>();
  vibeDevice.selfLogger = logger;
  getIt.registerSingleton<HapticEngine>(vibeDevice);
  logger.i('Vibration mode: ${vibeDevice.mode}');

  vibeDevice.vibratePreset(preset: VibePreset.launched);
}

Future registerConfig(GetIt getIt) async {
  final Config cfg = Config.instance;
  await cfg.load();
  getIt.registerSingleton<Config>(cfg);
}
