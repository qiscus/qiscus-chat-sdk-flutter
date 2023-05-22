import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';
import 'package:flutter/material.dart';

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
  QiscusSDK? _qiscusSDK;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      _qiscusSDK = await QiscusSDK.withAppId('sdksample');
      var account =
          await _qiscusSDK!.setUser(userId: 'guest-1001', userKey: 'passkey');
      var room = await _qiscusSDK!.chatUser(userId: 'guest-2002');
      var message =
          _qiscusSDK!.generateMessage(chatRoomId: room.id, text: 'Hi there');
      message = await _qiscusSDK!.sendMessage(message: message);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _qiscusSDK?.clearUser().ignore();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: Container(),
      ),
    );
  }
}
