import 'dart:async';

/// A function type that processes a batch of tasks.
///
/// Takes a list of tasks of type [T] and returns a [Future] that completes when
/// the batch has been processed.
typedef BatchFunction<T> = Future<void> Function(List<T> tasks);

/// A queue that collects items and processes them in batches.
///
/// The [BatchQueue] accumulates items of type [T] and processes them in batches
/// either when:
/// * The number of items reaches [batchSize]
/// * A timeout of [timeout] milliseconds occurs after the first item is added
///
/// This is useful for optimizing operations that are more efficient when
/// performed in batches, such as database operations or API calls.
class BatchQueue<T> {
  List<T> _queue = []; // The queue to hold the tasks
  final int batchSize; // The maximum size of a batch
  final int timeout; // The timeout in milliseconds
  Timer?
  _timeoutHandle; // Handle for the timeout, null when there's no active timeout
  final BatchFunction<T>
  executeBatch; // The function to execute a batch of tasks

  /// Creates a new [BatchQueue].
  ///
  /// [batchSize] specifies the maximum number of items to process in a single batch.
  /// [timeout] specifies the time in milliseconds to wait before processing an
  /// incomplete batch. Defaults to 500ms.
  /// [executeBatch] is the function that will be called to process each batch of items.
  BatchQueue({
    required this.batchSize,
    this.timeout = 500, // unit is in ms
    required this.executeBatch,
  });

  /// Adds a task to the queue for batch processing.
  ///
  /// The task will be processed when either:
  /// * The number of queued tasks reaches [batchSize]
  /// * The [timeout] period elapses after this task is added (if this is the first task in the queue)
  void submit(T task) {
    _queue.add(task); // Add the task to the queue

    // If we've reached batch size, process the queue
    if (_queue.length >= batchSize) {
      flush();
    }
    // If this is the first task added after the queue was processed, start the timeout
    else if (_queue.length == 1) {
      _startTimer();
    }
  }

  // Start a timeout that will process the queue when it triggers
  void _startTimer() {
    _timeoutHandle = Timer(Duration(milliseconds: timeout), () => flush());
  }

  // Clear the current timeout
  void _clearTimer() {
    if (_timeoutHandle != null) {
      _timeoutHandle!.cancel();
      _timeoutHandle = null;
    }
  }

  /// Processes all pending tasks in the queue immediately.
  ///
  /// This method will:
  /// * Clear any existing timeout
  /// * Take up to [batchSize] items from the queue
  /// * Process them using the [executeBatch] function
  /// * Remove the processed items from the queue
  ///
  /// If the queue is empty, this method does nothing.
  Future<void> flush() async {
    _clearTimer(); // Clear any existing timeout

    // If the queue is empty, there's nothing to process
    if (_queue.isEmpty) {
      return;
    }

    // Create a batch from the queue and remove the processed tasks
    List<T> batch = _queue.take(batchSize).toList();
    if (batch.length >= batchSize) {
      _queue = _queue.sublist(batchSize);
    } else {
      _queue = [];
    }

    // Execute the batch function with the current batch
    await executeBatch(batch);
  }
}
