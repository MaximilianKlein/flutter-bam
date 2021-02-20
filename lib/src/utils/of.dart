extension OfIterable<T> on Iterable<T> {
  // this simply returns a list where we only have the specified type
  // this can be useful if you want to remove all null values from a nullable
  // list. Otherwise you would always have to use `where(...).cast<T>()`
  Iterable<S> of<S extends T>() sync* {
    for (final element in this) {
      if (element != null && element is S) yield element;
    }
  }
}
