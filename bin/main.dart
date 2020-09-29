import 'dart:async';

Stream<int> makeSS() async* {
  var i = 0;
  while (true) {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    yield i++;
  }
}

Stream<int> makeStream() async* {
  StreamController<int> controller;
  StreamSubscription<int> subscription;

  controller = StreamController<int>(
    onListen: () {
      print('on listen');
      subscription = makeSS().listen(controller.sink.add);
    },
    onCancel: () {
      print('on cancel');
      subscription?.cancel();
    },
  );

  yield* controller.stream;
}

void main() async {
  var count = 1;
  await for (var data in makeStream()) {
    print('got data: $data');
    count++;

    if (count > 5) break;
  }
}
