import 'package:flutter/material.dart';
import 'package:flutter_dittofeed/flutter_dittofeed.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initDittofeed();
  }

  Future<void> _initDittofeed() async {
    // Initialize the SDK with a writeKey, which is used to identify your
    // workspace. This key can be found at
    // https://dittofeed.com/dashboard/settings
    await DittofeedSDK.init(InitParams(writeKey: "Basic abcdefg..."));

    // Lets you tie a user to their actions and record traits about them. It
    // includes a unique User ID and any optional traits you know about the
    // user, like their email, name, and more.
    DittofeedSDK.identify(
      IdentifyData(
        userId: "123",
        traits: {"email": "john@email.com", "firstName": "John"},
      ),
    );

    // The track call is how you record any actions your users perform, along
    // with any properties that describe the action.
    DittofeedSDK.track(
      TrackData(
        userId: "123",
        event: "Made Purchase",
        properties: {"itemId": "abc"},
      ),
    );

    // Lets you record whenever a user sees a screen in your mobile app,
    // along with any properties about the screen.
    DittofeedSDK.screen(
      ScreenData(
        userId: "123",
        name: "Recipe Screen",
        properties: {"recipeType": "Soup"},
      ),
    );

    // Records page navigation events with properties
    DittofeedSDK.page(
      PageData(
        userId: "123",
        name: "Settings Page",
        properties: {"source": "main_menu"},
      ),
    );

    // Ensures that asynchronously submitted events are flushed synchronously
    // to Dittofeed's API.
    await DittofeedSDK.flush();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Dittofeed Example')),
        body: Center(child: Text('My App')),
      ),
    );
  }
}
