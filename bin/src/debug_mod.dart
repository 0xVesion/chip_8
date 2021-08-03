import 'dart:io';

import 'package:chip_8/chip_8.dart';

class DebugMod extends Mod {
  @override
  void before(Chip8 chip8, Opcode op) {
    print(op);
  }

  @override
  void after(Chip8 chip8, Opcode op) {
    exitIfEndlessLoop(op);
    drawScreen(chip8, op);
  }

  int sameOpCount = 0;
  int lastOp = 0;

  void exitIfEndlessLoop(Opcode op) {
    if (lastOp == op.value) {
      sameOpCount++;
      if (sameOpCount > 10) exit(0);
    } else {
      sameOpCount = 0;
      lastOp = op.value;
    }
  }

  void drawScreen(Chip8 chip8, Opcode op) {
    // do nothing if screen hasn't changed
    if (op.instruction != Instructions.opDXYN) return;

    for (final row in chip8.display.data) {
      for (final pixel in row) {
        stdout.write('${pixel == 0 ? '  ' : '⬜'}');
      }
      stdout.write('\n');
    }
  }
}
