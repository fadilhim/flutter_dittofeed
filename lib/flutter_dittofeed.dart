import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dittofeed/dittofeed_model.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'batch_queue.dart';

export 'package:flutter_dittofeed/dittofeed_model.dart';

/// A class representing the Dittofeed SDK.
class DittofeedSDK {
  /// The write key.
  final String writeKey;

  /// The API key.
  final String apiKey;

  /// The host.
  final String host;

  /// The single instance of [DittofeedSDK].
  static DittofeedSDK? _instance;

  /// The batch queue.
  final BatchQueue<BatchItem> _batchQueue;

  /// The UUID generator.
  final Uuid _uuid = Uuid();

  /// Generates a new UUIDv4.
  String _uuidv4() => _uuid.v4();

  /// Creates a new instance of [DittofeedSDK].
  DittofeedSDK._({
    required this.writeKey,
    required this.apiKey,
    required this.host,
    http.Client? httpClient,
  }) : _batchQueue = BatchQueue<BatchItem>(
         batchSize: 5,
         timeout: 500,
         executeBatch: (batch) async {
           final data = BatchAppData(batch: batch);

           try {
             final client = httpClient ?? http.Client();
             final headers = {
               'Content-Type': 'application/json',
               'PublicWriteKey': apiKey,
               'authorization': writeKey,
             };
             final response = await client.post(
               Uri.parse('$host/api/public/apps/batch'),
               headers: headers,
               body: jsonEncode(data.toJson()),
             );

             if (response.statusCode >= 400) {
               debugPrint(
                 'Dittofeed Error: ${response.statusCode} ${response.body}',
               );
             }
           } catch (error) {
             debugPrint('Dittofeed Error: unknown ${error.toString()}');
           }
         },
       );

  /// Initializes the [DittofeedSDK].
  static Future<DittofeedSDK> init(
    InitParams params, {
    http.Client? httpClient,
  }) async {
    _instance ??= DittofeedSDK._(
      writeKey: params.writeKey,
      apiKey: params.apiKey,
      host: params.host,
      httpClient: httpClient,
    );
    return _instance!;
  }

  /// Resets the [DittofeedSDK].
  static void reset() {
    _instance = null;
  }

  /// Identifies a user.
  static void identify(IdentifyData params) {
    if (_instance == null) {
      throw Exception(
        'DittofeedSDK must be initialized before calling identify',
      );
    }

    final data = BatchIdentifyData(
      messageId: params.messageId ?? _instance!._uuidv4(),
      userId: params.userId,
      traits: params.traits,
    );

    _instance!._batchQueue.submit(data);
  }

  /// Tracks an event.
  static void track(TrackData params) {
    if (_instance == null) {
      throw Exception('DittofeedSDK must be initialized before calling track');
    }

    final data = BatchTrackData(
      messageId: params.messageId ?? _instance!._uuidv4(),
      event: params.event,
      userId: params.userId,
      anonymousId: params.anonymousId,
      properties: params.properties,
    );

    _instance!._batchQueue.submit(data);
  }

  /// Tracks page changes.
  static void page(PageData params) {
    if (_instance == null) {
      throw Exception('DittofeedSDK must be initialized before calling page');
    }

    final data = BatchPageData(
      messageId: params.messageId ?? _instance!._uuidv4(),
      userId: params.userId,
      anonymousId: params.anonymousId,
      name: params.name,
      properties: params.properties,
    );

    _instance!._batchQueue.submit(data);
  }

  /// Flushes the batch queue.
  static Future<void> flush() async {
    if (_instance == null) {
      throw Exception('DittofeedSDK must be initialized before calling flush');
    }

    await _instance!._batchQueue.flush();
  }
}
