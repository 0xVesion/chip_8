import 'dart:async';
import 'dart:io';

import 'package:chip_8/src/delay_timer.dart';
import 'package:chip_8/src/mod.dart';

import 'display.dart';
import 'font.dart';
import 'opcode.dart';
import 'stack.dart';

class Chip8 {
  static const int romStart = 0x200;

  // clock in instructions per second
  static const int clock = 700;

  // size of ram in bytes
  static const ramSize = 4096;

  // byte array initialized with 0
  final List<int> ram = List.filled(ramSize, 0);

  final Display display = Display();

  // program counter
  // points at current instruction in ram
  int pc = romStart;

  // index register
  // used to point at locations in ram
  int ir = 0;

  final Stack stack = Stack();

  static const vSize = 0xF;

  // general purpose variable registers
  // initialized with 0
  final List<int> v = List.filled(vSize + 1, 0);

  final DelayTimer delayTimer = DelayTimer();
  final DelayTimer soundTimer = DelayTimer();

  final List<Mod> mods;

  Chip8(List<int> rom, {this.mods = const []}) {
    Font.load(ram);

    // load rom into ram
    for (var i = romStart; i < romStart + rom.length; i++) {
      ram[i] = rom[i - romStart];
    }
  }

  void start() {
    Timer.periodic(Duration(milliseconds: 1000 ~/ clock), (timer) {
      tick();
    });
  }

  void tick() {
    final rawOpcode = fetch();
    final op = Opcode.decode(rawOpcode);

    mods.forEach((x) => x.before(this, op));
    execute(op);
    mods.forEach((x) => x.after(this, op));
  }

  // fetches an instruction from ram and increments the program counter
  // fetches 2 bytes as the instructions are 16-bit
  int fetch() {
    final a = ram[pc];
    final b = ram[pc + 1];

    pc += 2;

    return (a << 8) + b;
  }

  void execute(Opcode op) {
    if (op.value == 0x00E0) {
      op00E0();
    } else if (op.instruction == 0x1) {
      op1NNN(op);
    } else if (op.instruction == 0x6) {
      op6XNN(op);
    } else if (op.instruction == 0x7) {
      op7XNN(op);
    } else if (op.instruction == 0xA) {
      opANNN(op);
    } else if (op.instruction == 0xD) {
      opDXYN(op);
    } else if (op.value == 0x00EE) {
      op00EE();
    } else if (op.instruction == 0x2) {
      op00EE();
    } else {
      throw Exception('Unknown opcode: $op');
    }
  }

  // return from a subroutine
  void op00EE() {
    pc = stack.pop();
  }

  // call subroutine at NNN
  void op2NNN(Opcode op) {
    stack.push(pc);
    op1NNN(op);
  }

  void op00E0() {
    display.clear();
  }

  // jump to NNN
  void op1NNN(Opcode op) => pc = op.nnn;

  // set register VX to NN
  void op6XNN(Opcode op) => v[op.x] = op.nn;

  // add NN to register VX
  void op7XNN(Opcode op) => v[op.x] += op.nn;

  // set index register to NNN
  void opANNN(Opcode op) => ir = op.nnn;

  // draw sprite at position VX, VY with height N
  void opDXYN(Opcode op) {
    // reset VF to 0
    v[0xF] = 0;

    // fetch x and y coordinates from registers
    // coordinates should wrap around the screen
    final x = v[op.x] % Display.width;
    final y = v[op.y] % Display.height;

    final height = op.n;

    // iterate through each row (byte) of the sprite
    for (var yLine = 0; yLine < height; yLine++) {
      final row = ram[ir + yLine];

      // iterate through each pixel (bit) of the sprite row (byte)
      for (var xLine = 0; xLine < 8; xLine++) {
        final spritePixel = (row >> (7 - xLine)) & 1;
        final displayPixel = display.get(x + xLine, y + yLine);

        if (spritePixel == Display.black && displayPixel == Display.black) {
          // set VF to 1 if any pixels where turned black
          v[0xF] = 1;
          display.set(x + xLine, y + yLine, Display.black);
        }

        if (spritePixel == Display.white && displayPixel == Display.black) {
          display.set(x + xLine, y + yLine, Display.white);
        }

        // stop drawing if the edge of the screen has been reached
        if (x == Display.width) break;
      }
    }
  }
}
