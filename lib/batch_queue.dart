import 'dart:async';

typedef BatchFunction<T> = Future<void> Function(List<T> tasks);

class BatchQueue<T> {
  List<T> _queue = []; // The queue to hold the tasks
  final int batchSize; // The maximum size of a batch
  final int timeout; // The timeout in milliseconds
  Timer? _timeoutHandle; // Handle for the timeout, null when there's no active timeout
  final BatchFunction<T> executeBatch; // The function to execute a batch of tasks

  BatchQueue({
    required this.batchSize,
    this.timeout = 500, // unit is in ms
    required this.executeBatch,
  });

  // Method to add a task to the queue
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

  // Process the queue by executing the batch function with the current batch, then remove the batch from the queue
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