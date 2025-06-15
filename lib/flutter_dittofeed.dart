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

  /// Whether to enable logging.
  final bool logging;

  /// The single instance of [DittofeedSDK].
  static DittofeedSDK? _instance;

  /// The batch queue.
  final BatchQueue<BatchItem> _batchQueue;

  final Function(String)? customLog;

  /// The UUID generator.
  final Uuid _uuid = Uuid();

  /// The stored user ID from identify call.
  String? _storedUserId;

  /// The stored anonymous ID for when identify hasn't been called.
  String? _storedAnonymousId;

  /// Generates a new UUIDv4.
  String _uuidv4() => _uuid.v4();

  /// Gets or generates the anonymous ID.
  String _getAnonymousId() {
    _storedAnonymousId ??= _uuidv4();
    return _storedAnonymousId!;
  }

  /// Creates a new instance of [DittofeedSDK].
  DittofeedSDK._({
    required this.writeKey,
    required this.apiKey,
    required this.host,
    required this.logging,
    this.customLog,
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
        final url = '$host/api/public/apps/batch';

        if (logging) {
          final msg = '''
                    Dittofeed: Making API request to $url:
                    Headers: ${jsonEncode(headers)}
                    Data: ${jsonEncode(data.toJson())}
                 ''';
          _customLog(
              msg,
            customLog: (message) {
              customLog?.call(message);
            }
          );
        }

        final response = await client.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(data.toJson()),
        );

        if (response.statusCode >= 400) {
          if (logging) {
            debugPrint(
              'Dittofeed Error: ${response.statusCode} ${response.body}',
            );
          }
        } else {
          if (logging) {
            debugPrint(
              'Dittofeed: Successfully sent ${batch.length} items (${response
                  .statusCode})',
            );
          }
        }
      } catch (error) {
        if (logging) {
          debugPrint('Dittofeed Error: unknown ${error.toString()}');
        }
      }
    },
  );

  /// Initializes the [DittofeedSDK].
  static Future<DittofeedSDK> init(InitParams params, {
    http.Client? httpClient,
    bool logging = false,
    Function(String)? customLog,
  }) async {
    _instance ??= DittofeedSDK._(
      writeKey: params.writeKey,
      apiKey: params.apiKey,
      host: params.host,
      logging: logging,
      httpClient: httpClient,
      customLog: customLog,
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

    // Store the userId for future track/page calls
    _instance!._storedUserId = params.userId;

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

    // Use provided userId, or fall back to stored userId, or use anonymousId
    String? userId = params.userId ?? _instance!._storedUserId;
    String? anonymousId = params.anonymousId;

    // If no userId is available, use anonymousId
    if (userId == null) {
      anonymousId ??= _instance!._getAnonymousId();
    }

    final data = BatchTrackData(
      messageId: params.messageId ?? _instance!._uuidv4(),
      event: params.event,
      userId: userId,
      anonymousId: anonymousId,
      properties: params.properties,
    );

    _instance!._batchQueue.submit(data);
  }

  /// Tracks page changes.
  static void page(PageData params) {
    if (_instance == null) {
      throw Exception('DittofeedSDK must be initialized before calling page');
    }

    // Use provided userId, or fall back to stored userId, or use anonymousId
    String? userId = params.userId ?? _instance!._storedUserId;
    String? anonymousId = params.anonymousId;

    // If no userId is available, use anonymousId
    if (userId == null) {
      anonymousId ??= _instance!._getAnonymousId();
    }

    final data = BatchPageData(
      messageId: params.messageId ?? _instance!._uuidv4(),
      userId: userId,
      anonymousId: anonymousId,
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

  static void _customLog(String message, {Function(String)? customLog}) {
    debugPrint(message);
    if (customLog != null) {
      customLog(message);
    }
  }
}
