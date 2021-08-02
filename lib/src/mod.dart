import 'package:chip_8/src/opcode.dart';

import 'chip_8.dart';

abstract class Mod {
  void before(Chip8 chip8, Opcode op);
  void after(Chip8 chip8, Opcode op);
}
