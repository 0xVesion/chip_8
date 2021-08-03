import 'instructions.dart';

String instructionToName(Instructions i) =>
    i.toString().split('.').last.substring(2);
