part of qiscus_chat_sdk.core;

typedef Callback0 = void Function(QError error);
typedef Callback1<Data1> = void Function(Data1, QError error);
typedef Callback2<Data1, Data2> = void Function(Data1, Data2, QError error);
typedef SubscriptionFn = void Function();

typedef UserPresenceHandler = void Function(String, bool, DateTime);
typedef UserTypingHandler = void Function(String, int, bool);
