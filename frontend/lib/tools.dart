class RecToList<T> {
  RecToList(this.value, this.depth);

  final T value;
  final int depth;
}

Iterable<RecToList<T>> recToList<T>(T t, Iterable<T> Function(T) f,
    {int depth = 0}) sync* {
  yield RecToList(t, depth);
  yield* f(t).expand((e) => recToList(depth: depth + 1, e, f));
}
