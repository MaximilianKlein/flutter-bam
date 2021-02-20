import 'package:tuple/tuple.dart';

extension ZipIterable<T, S> on Iterable<T> {
  Iterable<Tuple2<T, S>> zip(Iterable<S> other) sync* {
    var it1 = this.iterator;
    var it2 = other.iterator;
    while (true) {
      final cur1 = it1.moveNext() ? it1.current : null;
      final cur2 = it2.moveNext() ? it2.current : null;
      if (cur1 == null && cur2 == null) {
        break;
      }
      yield Tuple2(cur1, cur2);
    }
  }
}
