class Display {
  static const black = 0;
  static const white = 1;

  static const width = 64;
  static const height = 32;

  List<List<int>> _data = [];

  List<List<int>> get data => _data;

  Display() {
    clear();
  }

  void clear() => _data =
      List.generate(height + 1, (_) => List.generate(width + 1, (_) => black));

  int get(int x, int y) => _data[y][x];

  void set(int x, int y, int color) => _data[y][x] = color;
}
