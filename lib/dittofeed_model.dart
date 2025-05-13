/// An enum representing different event types.
enum EventType {
  identify,
  track,
  page;

  /// Returns the string representation of the event type.
  String get value {
    return toString();
  }
}

/// A type alias for a map of string to dynamic.
typedef AppDataContext = Map<String, dynamic>;

/// An abstract class representing a batch item.
abstract class BatchItem {
  /// Converts the batch item to a JSON representation.
  Map<String, dynamic> toJson();
}

/// A class representing the base application data.
class BaseAppData extends BatchItem {
  /// The message ID.
  String? messageId;

  /// The timestamp.
  String? timestamp;

  /// Creates a new instance of [BaseAppData].
  BaseAppData({this.messageId, this.timestamp});

  @override
  /// Converts the base application data to a JSON representation.
  Map<String, dynamic> toJson() {
    return {
      if (messageId != null) 'messageId': messageId,
      if (timestamp != null) 'timestamp': timestamp,
    };
  }
}

/// A class representing the base identify data.
class BaseIdentifyData extends BaseAppData {
  /// The context.
  AppDataContext? context;

  /// The traits.
  Map<String, dynamic>? traits;

  /// Creates a new instance of [BaseIdentifyData].
  BaseIdentifyData({
    super.messageId,
    super.timestamp,
    this.context,
    this.traits,
  });

  @override
  /// Converts the base identify data to a JSON representation.
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      if (context != null) 'context': context,
      if (traits != null) 'traits': traits,
    };
  }
}

/// A class representing identify data.
class IdentifyData extends BaseIdentifyData {
  /// The user ID.
  String userId;

  /// Creates a new instance of [IdentifyData].
  IdentifyData({
    required this.userId,
    super.messageId,
    super.timestamp,
    super.context,
    super.traits,
  });

  @override
  /// Converts the identify data to a JSON representation.
  Map<String, dynamic> toJson() {
    return {...super.toJson(), 'userId': userId};
  }
}

/// A class representing the base batch identify data.
class BaseBatchIdentifyData extends BaseAppData {
  /// The type of the batch identify data.
  EventType type = EventType.identify;

  /// The traits.
  Map<String, dynamic>? traits;

  /// Creates a new instance of [BaseBatchIdentifyData].
  BaseBatchIdentifyData({super.messageId, super.timestamp, this.traits});

  @override
  /// Converts the base batch identify data to a JSON representation.
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'type': type.value,
      if (traits != null) 'traits': traits,
    };
  }
}

/// A class representing batch identify data.
class BatchIdentifyData extends BaseBatchIdentifyData {
  /// The user ID.
  String? userId;

  /// The anonymous ID.
  String? anonymousId;

  /// Creates a new instance of [BatchIdentifyData].
  BatchIdentifyData({
    this.userId,
    this.anonymousId,
    super.messageId,
    super.timestamp,
    super.traits,
  });

  @override
  /// Converts the batch identify data to a JSON representation.
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      if (userId != null) 'userId': userId,
      if (anonymousId != null) 'anonymousId': anonymousId,
    };
  }
}

/// A class representing the base track data.
class BaseTrackData extends BaseAppData {
  /// The context.
  AppDataContext? context;

  /// The event.
  String event;

  /// The properties.
  Map<String, dynamic>? properties;

  /// Creates a new instance of [BaseTrackData].
  BaseTrackData({
    required this.event,
    super.messageId,
    super.timestamp,
    this.context,
    this.properties,
  });

  @override
  /// Converts the base track data to a JSON representation.
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'event': event,
      if (context != null) 'context': context,
      if (properties != null) 'properties': properties,
    };
  }
}

/// A class representing track data.
class TrackData extends BaseTrackData {
  /// The user ID.
  String? userId;

  /// The anonymous ID.
  String? anonymousId;

  /// Creates a new instance of [TrackData].
  TrackData({
    required super.event,
    this.userId,
    this.anonymousId,
    super.messageId,
    super.timestamp,
    super.context,
    super.properties,
  });

  @override
  /// Converts the track data to a JSON representation.
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      if (userId != null) 'userId': userId,
      if (anonymousId != null) 'anonymousId': anonymousId,
    };
  }
}

/// A class representing the base batch track data.
class BaseBatchTrackData extends BaseAppData {
  /// The type of the batch track data.
  EventType type = EventType.track;

  /// The event.
  String event;

  /// The properties.
  Map<String, dynamic>? properties;

  /// Creates a new instance of [BaseBatchTrackData].
  BaseBatchTrackData({
    required this.event,
    super.messageId,
    super.timestamp,
    this.properties,
  });

  @override
  /// Converts the base batch track data to a JSON representation.
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'type': type.value,
      'event': event,
      if (properties != null) 'properties': properties,
    };
  }
}

/// A class representing batch track data.
class BatchTrackData extends BaseBatchTrackData {
  /// The user ID.
  String? userId;

  /// The anonymous ID.
  String? anonymousId;

  /// Creates a new instance of [BatchTrackData].
  BatchTrackData({
    required super.event,
    this.userId,
    this.anonymousId,
    super.messageId,
    super.timestamp,
    super.properties,
  });

  @override
  /// Converts the batch track data to a JSON representation.
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      if (userId != null) 'userId': userId,
      if (anonymousId != null) 'anonymousId': anonymousId,
    };
  }
}

/// A class representing the base page data.
class BasePageData extends BaseAppData {
  /// The context.
  AppDataContext? context;

  /// The name.
  String? name;

  /// The properties.
  Map<String, dynamic>? properties;

  /// Creates a new instance of [BasePageData].
  BasePageData({
    super.messageId,
    super.timestamp,
    this.context,
    this.name,
    this.properties,
  });

  @override
  /// Converts the base page data to a JSON representation.
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      if (context != null) 'context': context,
      if (name != null) 'name': name,
      if (properties != null) 'properties': properties,
    };
  }
}

/// A class representing page data.
class PageData extends BasePageData {
  /// The user ID.
  String? userId;

  /// The anonymous ID.
  String? anonymousId;

  /// Creates a new instance of [PageData].
  PageData({
    this.userId,
    this.anonymousId,
    super.messageId,
    super.timestamp,
    super.context,
    super.name,
    super.properties,
  });

  @override
  /// Converts the page data to a JSON representation.
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      if (userId != null) 'userId': userId,
      if (anonymousId != null) 'anonymousId': anonymousId,
    };
  }
}

/// A class representing the base batch page data.
class BaseBatchPageData extends BaseAppData {
  /// The type of the batch page data.
  EventType type = EventType.page;

  /// The name.
  String? name;

  /// The properties.
  Map<String, dynamic>? properties;

  /// Creates a new instance of [BaseBatchPageData].
  BaseBatchPageData({
    super.messageId,
    super.timestamp,
    this.name,
    this.properties,
  });

  @override
  /// Converts the base batch page data to a JSON representation.
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'type': type.value,
      if (name != null) 'name': name,
      if (properties != null) 'properties': properties,
    };
  }
}

/// A class representing batch page data.
class BatchPageData extends BaseBatchPageData {
  /// The user ID.
  String? userId;

  /// The anonymous ID.
  String? anonymousId;

  /// Creates a new instance of [BatchPageData].
  BatchPageData({
    this.userId,
    this.anonymousId,
    super.messageId,
    super.timestamp,
    super.name,
    super.properties,
  });

  @override
  /// Converts the batch page data to a JSON representation.
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      if (userId != null) 'userId': userId,
      if (anonymousId != null) 'anonymousId': anonymousId,
    };
  }
}

/// A class representing the base screen data.
class BaseScreenData extends BaseAppData {
  /// The context.
  AppDataContext? context;

  /// The name.
  String? name;

  /// The properties.
  Map<String, dynamic>? properties;

  /// Creates a new instance of [BaseScreenData].
  BaseScreenData({
    super.messageId,
    super.timestamp,
    this.context,
    this.name,
    this.properties,
  });

  @override
  /// Converts the base screen data to a JSON representation.
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      if (context != null) 'context': context,
      if (name != null) 'name': name,
      if (properties != null) 'properties': properties,
    };
  }
}

/// A class representing screen data.
class ScreenData extends BaseScreenData {
  /// The user ID.
  String? userId;

  /// The anonymous ID.
  String? anonymousId;

  /// Creates a new instance of [ScreenData].
  ScreenData({
    this.userId,
    this.anonymousId,
    super.messageId,
    super.timestamp,
    super.context,
    super.name,
    super.properties,
  });

  @override
  /// Converts the screen data to a JSON representation.
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      if (userId != null) 'userId': userId,
      if (anonymousId != null) 'anonymousId': anonymousId,
    };
  }
}

/// A class representing batch application data.
class BatchAppData {
  /// The batch items.
  List<BatchItem> batch;

  /// The context.
  AppDataContext? context;

  /// Creates a new instance of [BatchAppData].
  BatchAppData({required this.batch, this.context});

  /// Converts the batch application data to a JSON representation.
  Map<String, dynamic> toJson() {
    return {
      'batch': batch.map((item) => item.toJson()).toList(),
      if (context != null) 'context': context,
    };
  }
}

/// A class representing init parameters.
class InitParams {
  /// The write key.
  final String writeKey;

  /// The host.
  final String host;

  /// Creates a new instance of [InitParams].
  InitParams({required this.writeKey, this.host = 'https://dittofeed.com'});
}
