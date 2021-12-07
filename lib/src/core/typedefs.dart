part of qiscus_chat_sdk.core;

typedef Json = Map<String, dynamic>;
typedef Callback0 = void Function(Error error);
typedef Callback1<Data1> = void Function(Data1, Error error);
typedef Callback2<Data1, Data2> = void Function(Data1, Data2, Error error);
typedef SubscriptionFn = void Function();

typedef UserPresenceHandler = void Function(String, bool, DateTime);
typedef UserTypingHandler = void Function(String, int, bool);

typedef ReaderTask<D, R> = Reader<D, Task<R>>;
typedef ReaderTaskEither<D, L, R> = Reader<D, TaskEither<L, R>>;
typedef RTE<R> = ReaderTaskEither<Dio, String, R>;
