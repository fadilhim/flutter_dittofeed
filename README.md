# Dittofeed Dart SDK

**Note:** This is **not an official** SDK.

A Dart implementation of the Dittofeed SDK for Flutter applications.

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_dittofeed: ^0.0.4
```

Then run:

```bash
flutter pub get
```

## Usage

Dittofeed's Dart SDK can be used to send events about your application and users to Dittofeed.

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dittofeed/flutter_dittofeed.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
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
    await DittofeedSDK.init(
      InitParams(writeKey: "Basic abcdefg..."),
    );

    // Lets you tie a user to their actions and record traits about them. It
    // includes a unique User ID and any optional traits you know about the
    // user, like their email, name, and more.
    DittofeedSDK.identify(
      IdentifyData(
        userId: "123",
        traits: {
          "email": "john@email.com",
          "firstName": "John"
        },
      ),
    );

    // The track call is how you record any actions your users perform, along
    // with any properties that describe the action.
    DittofeedSDK.track(
      TrackData(
        userId: "123",
        event: "Made Purchase",
        properties: {
          "itemId": "abc",
        },
      ),
    );

    // Lets you record whenever a user sees a screen in your mobile app,
    // along with any properties about the screen.
    DittofeedSDK.screen(
      ScreenData(
        userId: "123",
        name: "Recipe Screen",
        properties: {
          "recipeType": "Soup",
        },
      ),
    );

    // Records page navigation events with properties
    DittofeedSDK.page(
      PageData(
        userId: "123",
        name: "Settings Page",
        properties: {
          "source": "main_menu",
        },
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
        appBar: AppBar(
          title: Text('Dittofeed Example'),
        ),
        body: Center(
          child: Text('My App'),
        ),
      ),
    );
  }
}
```

## API Reference

### Initialization

```dart
await DittofeedSDK.init(
  InitParams(
    writeKey: "Your Dittofeed Write Key",
    host: "https://dittofeed.com", // Optional, defaults to https://dittofeed.com
  ),
);
```

### Identify

The `identify` method lets you tie a user to their actions and record traits about them:

```dart
DittofeedSDK.identify(
  IdentifyData(
    userId: "unique_user_id",
    traits: {
      "email": "user@example.com",
      "name": "John Doe",
      "plan": "premium",
      // Add any other user traits
    },
  ),
);
```

You can also identify anonymous users:

```dart
DittofeedSDK.identify(
  IdentifyData(
    anonymousId: "anonymous_user_id",
    traits: {
      "referrer": "google",
      "landing_page": "/features",
    },
  ),
);
```

### Track

The `track` method lets you record user actions:

```dart
DittofeedSDK.track(
  TrackData(
    userId: "unique_user_id",
    event: "Button Clicked",
    properties: {
      "buttonName": "signup",
      "buttonColor": "green",
      "referrer": "welcome_email",
    },
  ),
);
```

### Page

The `page` method lets you record when a user views a page:

```dart
DittofeedSDK.page(
  PageData(
    userId: "unique_user_id",
    name: "Home Page",
    properties: {
      "url": "/home",
      "referrer": "/login",
      "search": "integration docs",
    },
  ),
);
```

### Screen

The `screen` method lets you record when a user views a screen in a mobile app:

```dart
DittofeedSDK.screen(
  ScreenData(
    userId: "unique_user_id",
    name: "Product Screen",
    properties: {
      "productId": "123",
      "productCategory": "Electronics",
    },
  ),
);
```

### Flush

The `flush` method ensures that any queued events are sent immediately:

```dart
await DittofeedSDK.flush();
```

## Configuration

The SDK batches events by default to minimize network requests. Events are sent:

1. When the batch size reaches 5 events
2. When the timeout of 500ms is reached
3. When `flush()` is called explicitly

## Context Property

All event types support an optional `context` property that lets you specify metadata about the event:

```dart
DittofeedSDK.track(
  TrackData(
    userId: "unique_user_id",
    event: "Button Clicked",
    context: {
      "app": {
        "name": "My Flutter App",
        "version": "1.2.3",
      },
      "device": {
        "id": "device_id",
        "manufacturer": "Apple",
        "model": "iPhone 13",
      },
    },
    properties: {
      "buttonName": "signup",
    },
  ),
);
```

## Anonymous IDs

For users who aren't identified, you can use anonymous IDs:

```dart
DittofeedSDK.track(
  TrackData(
    anonymousId: "anonymous_user_id",
    event: "App Opened",
    properties: {
      "firstOpen": true,
    },
  ),
);
```

## Error Handling

The SDK includes built-in error handling and will log errors to the console without crashing your application.

## License

This project is licensed under the MIT License - see the LICENSE file for details.