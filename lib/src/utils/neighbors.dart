import 'package:meta/meta.dart';

class Neighbors<T> {
  const Neighbors({
    @required this.prev,
    @required this.next,
  });

  final T prev;
  final T next;
}

extension IterateNeighbors<T> on Iterable<T> {
  Iterable<S> neighbors<S>(S f(T prev, T next)) sync* {
    for (var i = 1; i < this.length; i++) {
      yield f(this.elementAt(i - 1), this.elementAt(i));
    }
  }

  Iterable<S> neighborsExpand<S>(Iterable<S> f(T prev, T next)) sync* {
    for (var i = 1; i < this.length; i++) {
      final resIterable = f(this.elementAt(i - 1), this.elementAt(i));
      for (final res in resIterable) {
        yield res;
      }
    }
  }
}
