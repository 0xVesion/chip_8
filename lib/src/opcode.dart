class Opcode {
  final int value;

  int get instruction => (value & 0xF000) >> 12;
  int get x => (value & 0x0F00) >> 8;
  int get y => (value & 0x00F0) >> 4;
  int get n => value & 0x000F;
  int get nn => value & 0x00FF;
  int get nnn => value & 0x0FFF;

  Opcode.decode(this.value);

  @override
  String toString() =>
      'Opcode{0x${value.toRadixString(16).padLeft(4, '0').toUpperCase()}}';
}
