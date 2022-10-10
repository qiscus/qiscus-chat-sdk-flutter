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
  QiscusSDK? _qiscusSDK;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      _qiscusSDK = await QiscusSDK.withAppId('sdksample');
    });
  }

  @override
  void dispose() {
    super.dispose();
    _qiscusSDK?.clearUser().ignore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
