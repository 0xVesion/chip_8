class DelayTimer {
  int value = 0;

  bool get isZero => value == 0;

  void update() {
    if (isZero) return;

    value--;
  }
}
