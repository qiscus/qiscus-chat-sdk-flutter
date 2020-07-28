# Qiscus Chat SDK

> Qiscus Chat SDK for Flutter

![Coverage](https://raw.githubusercontent.com/{you}/{repo}/master/coverage_badge.svg?sanitize=true)

## Introduction

Qiscus Chat SDK (Software Development Kit) is a product provided by Qiscus
that enables you to embed an in-app chat/chat feature in your applications
quickly and easily. With our chat SDK, you can implement chat feature
without dealing with the complexity of real-time communication infrastructure.
We provide a powerful API to let you implement chat feature into your
apps in the most seamless development process.

## Usage

A simple usage example:

```dart
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MyHomepage();
}

class MyHomepage extends StatefulWidget {
  @override
  _MyHomepageState createState() => _MyHomepageState();
}

class _MyHomepageState extends State<MyHomepage> {
  QiscusSDK _qiscusSDK;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _qiscusSDK = QiscusSDK.withAppId('sdksample', callback: (error) {
        if (error != null) {
          return print('Error happend while initializing qiscus sdk: $error');
        }
        print('Qiscus SDK Ready to use');
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _qiscusSDK?.clearUser(callback: (error) {
      // ignore error
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/qiscus/qiscus-chat-sdk-flutter/issues
