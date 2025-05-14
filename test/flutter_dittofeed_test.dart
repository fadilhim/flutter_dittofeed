import 'dart:convert';
import 'package:flutter_dittofeed/flutter_dittofeed.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;

@GenerateMocks([http.Client])
import 'flutter_dittofeed_test.mocks.dart';

class FakeUri extends Fake implements Uri {}

void main() {
  late MockClient mockClient;
  final testWriteKey = 'test-write-key';
  final testHost = 'https://test-host.com';

  // Utility function to initialize SDK with mocked HTTP client
  Future<void> initSdkWithMockedClient(MockClient client) async {
    // Add a way to inject the mock client into the SDK
    // This requires modifying the SDK to accept a client in initialization
    await DittofeedSDK.init(
      InitParams(writeKey: testWriteKey, host: testHost),
      httpClient: client, // Add this parameter to your SDK
    );
  }

  setUp(() {
    mockClient = MockClient();
    // Reset the singleton between tests
    // Add a reset method to your SDK for testing
    DittofeedSDK.reset();
  });

  group('DittofeedSDK Initialization Tests', () {
    test('init should create a singleton instance', () async {
      final sdk1 = await DittofeedSDK.init(
        InitParams(writeKey: testWriteKey, host: testHost),
      );

      final sdk2 = await DittofeedSDK.init(
        InitParams(writeKey: 'different-key', host: 'different-host'),
      );

      // Both calls should return the same instance
      expect(identical(sdk1, sdk2), true);

      // Second init call shouldn't change parameters
      expect(sdk1.writeKey, testWriteKey);
      expect(sdk1.host, testHost);
    });
  });

  group('DittofeedSDK Event Tests', () {
    setUp(() async {
      // Configure mock to return success for all requests
      when(
        mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response('{"success": true}', 200));

      await initSdkWithMockedClient(mockClient);
    });

    test('identify should submit correct data', () async {
      // Call identify
      DittofeedSDK.identify(
        IdentifyData(
          userId: 'user123',
          traits: {'name': 'Test User', 'email': 'test@example.com'},
        ),
      );

      // Flush to ensure the request is sent
      await DittofeedSDK.flush();

      // Verify HTTP request was made with correct data
      verify(
        mockClient.post(
          argThat(equals(Uri.parse('$testHost/api/public/apps/batch'))),
          headers: argThat(
            equals({
              'Content-Type': 'application/json',
              'Authorization': testWriteKey,
            }),
          ),
          body: argThat(
            predicate<String>((body) {
              final json = jsonDecode(body);
              final batch = json['batch'] as List;

              return batch.length == 1 &&
                  batch[0]['type'] == 'identify' &&
                  batch[0]['userId'] == 'user123' &&
                  batch[0]['traits']['name'] == 'Test User';
            }),
          ),
        ),
      ).called(1);
    });

    test('track should submit correct data', () async {
      // Call track
      DittofeedSDK.track(
        TrackData(
          event: 'button_click',
          userId: 'user123',
          properties: {'buttonId': 'signup', 'timestamp': 1619111111},
        ),
      );

      // Flush to ensure the request is sent
      await DittofeedSDK.flush();

      // Verify HTTP request was made with correct data
      verify(
        mockClient.post(
          argThat(equals(Uri.parse('$testHost/api/public/apps/batch'))),
          headers: argThat(
            equals({
              'Content-Type': 'application/json',
              'Authorization': testWriteKey,
            }),
          ),
          body: argThat(
            predicate<String>((body) {
              final json = jsonDecode(body);
              final batch = json['batch'] as List;

              return batch.length == 1 &&
                  batch[0]['type'] == 'track' &&
                  batch[0]['event'] == 'button_click' &&
                  batch[0]['userId'] == 'user123' &&
                  batch[0]['properties']['buttonId'] == 'signup';
            }),
          ),
        ),
      ).called(1);
    });

    test('page should submit correct data', () async {
      // Call page
      DittofeedSDK.page(
        PageData(
          name: 'Home Page',
          userId: 'user123',
          properties: {'referrer': 'google.com'},
        ),
      );

      // Flush to ensure the request is sent
      await DittofeedSDK.flush();

      // Verify HTTP request
      verify(
        mockClient.post(
          argThat(equals(Uri.parse('$testHost/api/public/apps/batch'))),
          headers: argThat(isA<Map<String, String>>()),
          body: argThat(
            predicate<String>((body) {
              final json = jsonDecode(body);
              final batch = json['batch'] as List;

              return batch.length == 1 &&
                  batch[0]['type'] == 'page' &&
                  batch[0]['name'] == 'Home Page';
            }),
          ),
        ),
      ).called(1);
    });

    test('should batch multiple events', () async {
      // Submit 3 events
      DittofeedSDK.track(TrackData(event: 'event1', userId: 'user123'));
      DittofeedSDK.track(TrackData(event: 'event2', userId: 'user123'));
      DittofeedSDK.track(TrackData(event: 'event3', userId: 'user123'));
      DittofeedSDK.track(TrackData(event: 'event4', userId: 'user123'));
      DittofeedSDK.track(TrackData(event: 'event5', userId: 'user123'));

      // Verify that a batch was automatically sent after reaching batch size
      await Future.delayed(Duration(milliseconds: 100));

      // Verify HTTP request for first batch
      verify(
        mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: argThat(
            predicate<String>((body) {
              final json = jsonDecode(body);
              final batch = json['batch'] as List;

              return batch.length == 5;
            }),
          ),
        ),
      ).called(1);
    });

    test('should handle HTTP error', () async {
      // Configure mock to return an error
      when(
        mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer(
        (_) async => http.Response('{"error": "Something went wrong"}', 400),
      );

      // Call identify (should not throw)
      DittofeedSDK.identify(IdentifyData(userId: 'user123'));

      // Flush to ensure the request is sent
      await DittofeedSDK.flush();

      // Verify HTTP request was attempted
      verify(
        mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).called(1);

      // Should not throw an exception
    });
  });

  group('DittofeedSDK UUID Generation', () {
    test(
      'should generate UUIDs for events when messageId is not provided',
      () async {
        // Configure mock
        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('{"success": true}', 200));

        await initSdkWithMockedClient(mockClient);

        // Call identify without messageId
        DittofeedSDK.identify(IdentifyData(userId: 'user123'));

        // Flush to ensure the request is sent
        await DittofeedSDK.flush();

        // Verify UUID was generated
        verify(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: argThat(
              predicate<String>((body) {
                final json = jsonDecode(body);
                final batch = json['batch'] as List;

                return batch[0]['messageId'] != null &&
                    batch[0]['messageId'].toString().isNotEmpty;
              }),
            ),
          ),
        ).called(1);
      },
    );
  });
}
