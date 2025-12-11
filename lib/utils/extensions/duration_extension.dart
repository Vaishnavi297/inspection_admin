extension DurationExtension on Duration {
  Future<void> delay() => Future.delayed(this);
}
