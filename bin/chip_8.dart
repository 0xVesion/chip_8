import 'dart:io';

import 'package:chip_8/chip_8.dart';

import 'src/debug_mod.dart';

Future<void> main(List<String> arguments) async {
  final rom = await loadRom(arguments[0]);
  final chip8 = Chip8(rom, mods: [DebugMod()]);

  chip8.start();
}

Future<List<int>> loadRom(String romLocation) async {
  final romFile = File(romLocation);
  if (!await romFile.exists()) {
    throw Exception('ROM not found: ' + romLocation);
  }

  return await romFile.readAsBytes();
}
