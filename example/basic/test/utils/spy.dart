import 'dart:async';

import 'package:matcher/matcher.dart';

/// Definition of a predicate function
typedef Predicate<T> = bool Function(T);

typedef VoidCallback = void Function();
typedef ValueChanged<T> = void Function(T value);

class CallbackSpy {
  CallbackSpy() : callCount = 0 {
    callback = () {
      callCount++;
      _invocationStreamController.add(null);
    };
  }
  VoidCallback callback;
  int callCount;

  @override
  String toString() => 'CallbackSpy(callCount: $callCount)';

  final StreamController<Null> _invocationStreamController =
      StreamController.broadcast();

  Future untilCalled() => _invocationStreamController.stream.first;
  Future untilCalledN(int n) =>
      _invocationStreamController.stream.skip(n - 1).first;
}

class ValueCallbackSpy<V> {
  ValueCallbackSpy()
      : callCount = 0,
        calls = [] {
    callback = (v) {
      callCount++;
      calls.add(v);
      _invocationStreamController.add(v);
    };
  }

  @override
  String toString() => 'ValueCallbackSpy(callCount: $callCount, calls $calls)';

  final StreamController<V> _invocationStreamController =
      StreamController.broadcast();
  ValueChanged<V> callback;
  int callCount;
  List<V> calls;

  Future<V> untilCalled() => _invocationStreamController.stream.first;
  Future<V> untilCalledN(int n) =>
      _invocationStreamController.stream.skip(n - 1).first;
}

class _SpyWasCalled extends Matcher {
  const _SpyWasCalled();

  @override
  Description describe(Description description) =>
      description.add('was called');

  @override
  bool matches(dynamic item, Map matchState) =>
      (item is CallbackSpy && item.callCount > 0) ||
      (item is ValueCallbackSpy && item.callCount > 0);
}

/// Matches if the given spy was called at least once
const Matcher wasCalled = _SpyWasCalled();

class _SpyWasNotCalled extends Matcher {
  const _SpyWasNotCalled();

  @override
  Description describe(Description description) =>
      description.add('was not called');

  @override
  bool matches(dynamic item, Map matchState) =>
      (item is CallbackSpy && item.callCount == 0) ||
      (item is ValueCallbackSpy && item.callCount == 0);
}

/// Matches if the given spy was called at least once
const Matcher wasNotCalled = _SpyWasNotCalled();

class _SpyWasCalledOnce extends Matcher {
  const _SpyWasCalledOnce();

  @override
  Description describe(Description description) =>
      description.add('was called exactly once');

  @override
  bool matches(dynamic item, Map matchState) =>
      (item is CallbackSpy && item.callCount == 1) ||
      (item is ValueCallbackSpy && item.callCount == 1);
}

/// Matches if the given spy was called at least once
const Matcher wasCalledOnce = _SpyWasCalledOnce();

class _SpyWasCalledNTimes extends Matcher {
  const _SpyWasCalledNTimes(this.n);

  final int n;

  @override
  Description describe(Description description) =>
      description.add('was called exactly $n times');

  @override
  bool matches(dynamic item, Map matchState) =>
      (item is CallbackSpy && item.callCount == n) ||
      (item is ValueCallbackSpy && item.callCount == n);
}

/// Matches if the given spy was called exactly n times
Matcher wasCalledNTimes(int n) => _SpyWasCalledNTimes(n);

class _SpyWasCalledWith<T> extends Matcher {
  const _SpyWasCalledWith(this.value);

  final T value;

  @override
  Description describe(Description description) =>
      description.add('was called with argument $value');

  @override
  bool matches(dynamic item, Map matchState) =>
      item is ValueCallbackSpy &&
      item.callCount > 0 &&
      item.calls.contains(value);
}

/// Matches if the given spy was called at least once
Matcher wasCalledWith<V>(V value) => _SpyWasCalledWith(value);

class _SpyMatchesCall<T> extends Matcher {
  const _SpyMatchesCall(this.matcher);

  final Predicate<T> matcher;

  @override
  Description describe(Description description) =>
      description.add('was called with matching argument');

  @override
  bool matches(dynamic item, Map matchState) =>
      item is ValueCallbackSpy && item.callCount > 0 && item.calls.any(matcher);
}

/// Matches if the given spy was called at least once
Matcher matchesCall<V>(Predicate<V> matcher) => _SpyMatchesCall(matcher);
