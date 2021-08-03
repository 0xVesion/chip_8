import 'dart:async';

import 'package:chip_8/src/delay_timer.dart';
import 'package:chip_8/src/mod.dart';

import 'display.dart';
import 'font.dart';
import 'instructions.dart';
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
  int I = 0;

  final Stack stack = Stack();

  static const vSize = 0xF;

  // general purpose variable registers
  // initialized with 0
  final List<int> V = List.filled(vSize + 1, 0);

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
    <Instructions, void Function()>{
      Instructions.op00E0: () => clearScreen(),
      Instructions.op1NNN: () => jumpNNN(op),
      Instructions.op6XNN: () => setVXtoNN(op),
      Instructions.op7XNN: () => addNNtoVX(op),
      Instructions.opANNN: () => setIndexToNNN(op),
      Instructions.opDXYN: () => draw(op),
      Instructions.op00EE: () => returnRoutine(),
      Instructions.op2NNN: () => callRoutine(op),
    }[op.instruction]!();
  }

  // return from a subroutine
  void returnRoutine() {
    pc = stack.pop();
  }

  // call subroutine at NNN
  void callRoutine(Opcode op) {
    stack.push(pc);
    jumpNNN(op);
  }

  void clearScreen() {
    display.clear();
  }

  // jump to NNN
  void jumpNNN(Opcode op) => pc = op.nnn;

  // set register VX to NN
  void setVXtoNN(Opcode op) => V[op.x] = op.nn;

  // add NN to register VX
  void addNNtoVX(Opcode op) => V[op.x] += op.nn;

  // set index register to NNN
  void setIndexToNNN(Opcode op) => I = op.nnn;

  // draw sprite at position VX, VY with height N
  void draw(Opcode op) {
    // reset VF to 0
    V[0xF] = 0;

    // fetch x and y coordinates from registers
    // coordinates should wrap around the screen
    final x = V[op.x] % Display.width;
    final y = V[op.y] % Display.height;

    final height = op.n;

    // iterate through each row (byte) of the sprite
    for (var yLine = 0; yLine < height; yLine++) {
      final row = ram[I + yLine];

      // iterate through each pixel (bit) of the sprite row (byte)
      for (var xLine = 0; xLine < 8; xLine++) {
        final spritePixel = (row >> (7 - xLine)) & 1;
        final displayPixel = display.get(x + xLine, y + yLine);

        if (spritePixel == Display.black && displayPixel == Display.black) {
          // set VF to 1 if any pixels where turned black
          V[0xF] = 1;
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
