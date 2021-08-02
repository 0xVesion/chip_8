class Stack {
  static const size = 0xF;

  final List<int> _data = [];
  List<int> get data => List.unmodifiable(_data);

  void clear() {
    _data.clear();
  }

  void push(int frame) {
    if (_data.length == size) throw Exception('Stack overflow');
    _data.add(frame);
  }

  int pop() {
    if (_data.isEmpty) throw Exception('Trying to pop empty stack');

    return _data.removeLast();
  }
}
