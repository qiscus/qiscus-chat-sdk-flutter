import 'dart:async';
import 'dart:collection';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';

import 'errors.dart';

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object> get props => [];
}

const noParams = NoParams();

abstract class UseCase<Repository, ReturnType, Params> {
  final Repository _repository;

  const UseCase(this._repository);

  Repository get repository => _repository;

  Task<Either<QError, ReturnType>> call(Params params);
}

abstract class SubscriptionUseCase<Repository, ReturnType, Params> {
  final Repository _repository;

  const SubscriptionUseCase(this._repository);

  Repository get repository => _repository;

  Stream<ReturnType> subscribe(Params params);

  void unsubscribe(Params params);
}

/// A helper mixin for handling subscription based
/// usecase, please ensure [params] implement
/// both == equality method and hashCode method.
mixin Subscription<Repository extends IRealtimeService, Params, Response> {
  final _controller = StreamController<Response>.broadcast();
  final _subscriptions = HashMap<Params, StreamSubscription<Response>>();

  Stream<Response> get stream => _controller.stream;

  Task<Stream<Response>> subscribe(Params params) {
    return Task.delay(() => topic(params))
        .bind((topic) => topic.fold(
              () => Task.delay(() {}),
              (topic) => repository.subscribe(topic),
            ))
        .andThen(Task.delay(() => _subscriptions.putIfAbsent(params,
            () => mapStream(params).listen((res) => _controller.add(res)))))
        .andThen(Task.delay(() => _controller.stream));
  }

  Task<void> unsubscribe(Params params) {
    if (!_subscriptions.containsKey(params)) return Task.delay(() {});
    return Task.delay(() => topic(params))
        .bind((topic) => topic.fold(
            () => Task.delay(() {}), (topic) => repository.unsubscribe(topic)))
        .andThen(Task.delay(() => _subscriptions.remove(params)?.cancel()));
  }

  Task<StreamSubscription<Response>> listen(
    void Function(Response) onResponse, {
    Function onError,
    bool cancelOnError,
    void Function() onDone,
  }) {
    return Task.delay(
      () => _controller.stream.listen(
        onResponse,
        onError: onError,
        cancelOnError: cancelOnError,
        onDone: onDone,
      ),
    );
  }

  /// Getter method for repository which this usecase hold
  Repository get repository;

  /// Stream mapper
  Stream<Response> mapStream(Params p);

  Option<String> topic(Params p);
}
