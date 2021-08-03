import 'instructions.dart';

String instructionToName(Instructions i) =>
    i.toString().split('.').last.substring(2);

String intTo16Bit(int i) =>
    '0x' + i.toRadixString(16).padLeft(4, '0').toUpperCase();
