import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/platform_interface.dart';

// ignore: implementation_imports
import 'package:webview_flutter/src/webview_method_channel.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'android_view.dart';

void main() {
  assert(window.locale != null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _incrementCounter() {}

  @override
  Widget build(BuildContext context) {
    // FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: AdPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Drawer Header'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NativeWebView extends StatelessWidget {
  const NativeWebView({Key key}) : super(key: key);

  Widget build(BuildContext context) {
    final CreationParams creationParams = CreationParams(
      initialUrl: 'https://flutter.dev',
      webSettings: WebSettings(
        javascriptMode: JavascriptMode.unrestricted,
        hasNavigationDelegate: false,
        debuggingEnabled: false,
        gestureNavigationEnabled: false,
        userAgent: WebSetting<String>.of(null),
      ),
      javascriptChannelNames: Set<String>(),
      autoMediaPlaybackPolicy:
          AutoMediaPlaybackPolicy.require_user_action_for_all_media_types,
    );

    return AndroidPlatformView(
      viewType: 'plugins.flutter.io/webview',
      creationParams:
          MethodChannelWebViewPlatform.creationParamsToMap(creationParams),
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}

class AdPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(itemBuilder: _itemBuilder),
    );
  }

  Widget _itemBuilder(BuildContext context, index) {
    if (index % 10 == 0) {
      return Container(
        width: 500,
        height: 300,
        color: Colors.orange,
        child: Stack(
          children: <Widget>[
            const NativeWebView(),
            // Transform.translate(
            //   offset: const Offset(50.0, 280.0),
            //   child: const RotationContainer(),
            // )
          ],
        ),
      );
    }
    return ListTile(title: Text('Item $index'));
  }
}

class RotationContainer extends StatefulWidget {
  const RotationContainer({Key key}) : super(key: key);

  @override
  _RotationContainerState createState() => _RotationContainerState();
}

class _RotationContainerState extends State<RotationContainer>
    with SingleTickerProviderStateMixin {
  AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      value: 1,
    );
    _rotationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween<double>(begin: 0.0, end: 1.0).animate(_rotationController),
      child: Container(
        color: Colors.purple,
        width: 50.0,
        height: 50.0,
      ),
    );
  }
}
