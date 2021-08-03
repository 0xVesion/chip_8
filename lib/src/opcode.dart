import 'package:chip_8/src/instructions.dart';

import 'utils.dart';

class Opcode {
  final int value;

  int get i => (value & 0xF000) >> 12;
  int get x => (value & 0x0F00) >> 8;
  int get y => (value & 0x00F0) >> 4;
  int get n => value & 0x000F;
  int get nn => value & 0x00FF;
  int get nnn => value & 0x0FFF;

  Instructions get instruction {
    if (value == 0x00E0) return Instructions.op00E0;
    if (i == 0x1) return Instructions.op1NNN;
    if (i == 0x6) return Instructions.op6XNN;
    if (i == 0x7) return Instructions.op7XNN;
    if (i == 0xA) return Instructions.opANNN;
    if (i == 0xD) return Instructions.opDXYN;
    if (value == 0x00EE) return Instructions.op00EE;
    if (i == 0x2) return Instructions.op2NNN;

    throw Exception('Unknown instruction: $this');
  }

  Opcode.decode(this.value);

  @override
  String toString() =>
      'Opcode{${instructionToName(instruction)}, 0x${value.toRadixString(16).padLeft(4, '0').toUpperCase()}}';
}
