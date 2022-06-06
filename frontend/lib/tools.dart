class RecAsList<T> {
  RecAsList(this.value, this.depth);

  final T value;
  final int depth;
}

Iterable<RecAsList<T>> recToList<T>(T t, Iterable<T> Function(T) f,
    {int depth = 0}) sync* {
  yield RecAsList(t, depth);
  yield* f(t).expand((e) => recToList(depth: depth + 1, e, f));
}

Iterable<T> listToRec<T>(
    Iterable<RecAsList<T>> xs, T Function(T, Iterable<T> newChildren) f) sync* {
  if (xs.length <= 1) {
    if (xs.isNotEmpty) yield xs.first.value;
    return;
  }
  final first = xs.first;
  final restIter = xs.skip(1).takeWhile((e) => e.depth > first.depth);
  final restRec = listToRec(restIter, f);
  yield f(first.value, restRec);
  if (restIter.length + 1 < xs.length) {
    yield* listToRec(xs.skip(restIter.length + 1), f);
  }
}
