import 'package:flutter_dittofeed/batch_queue.dart';
import 'package:test/test.dart';

import 'dart:async';

void main() {
  group('BatchQueue Tests', () {
    late List<String> executedBatches;
    late BatchQueue<String> batchQueue;
    late Completer<void> batchExecuted;

    setUp(() {
      executedBatches = [];
      batchExecuted = Completer<void>();

      batchQueue = BatchQueue<String>(
        batchSize: 3,
        timeout: 500,
        executeBatch: (batch) async {
          executedBatches.add(batch.join(','));
          batchExecuted.complete();
          return;
        },
      );
    });

    test('should execute batch when batch size is reached', () async {
      // Submit 3 tasks (equals batch size)
      batchQueue.submit('task1');
      batchQueue.submit('task2');
      batchQueue.submit('task3');

      // Wait for batch execution
      await batchExecuted.future;

      // Verify batch was executed
      expect(executedBatches.length, 1);
      expect(executedBatches[0], 'task1,task2,task3');
    });

    test(
      'should execute batch when timeout is reached',
      () async {
        // Submit just 1 task (less than batch size)
        batchQueue.submit('task1');

        // Wait for timeout to trigger batch execution
        await batchExecuted.future;

        // Verify batch was executed after timeout
        expect(executedBatches.length, 1);
        expect(executedBatches[0], 'task1');
      },
      timeout: Timeout(Duration(seconds: 2)),
    );

    test('should clear timer when flushed manually', () async {
      // Submit a task
      batchQueue.submit('task1');

      // Manually flush before timeout is reached
      await batchQueue.flush();

      // Verify batch was executed
      expect(executedBatches.length, 1);
      expect(executedBatches[0], 'task1');

      // Wait a bit longer than the timeout
      await Future.delayed(Duration(milliseconds: 600));

      // Verify no additional batch was executed (timer was cleared)
      expect(executedBatches.length, 1);
    });

    test('should handle multiple batches', () async {
      final allBatchesCompleter = Completer<void>();
      int batchCount = 0;

      // Create a new batch queue for this test with a custom executeBatch
      final multiQueue = BatchQueue<String>(
        batchSize: 2,
        timeout: 500,
        executeBatch: (batch) async {
          executedBatches.add(batch.join(','));
          batchCount++;
          if (batchCount == 3) {
            allBatchesCompleter.complete();
          }
        },
      );

      // Submit 5 tasks (should result in 3 batches)
      multiQueue.submit('task1');
      multiQueue.submit('task2');
      multiQueue.submit('task3');
      multiQueue.submit('task4');
      multiQueue.submit('task5');

      // Wait for all batches to be executed
      await allBatchesCompleter.future;

      // Verify batches
      expect(executedBatches.length, 3);
      expect(executedBatches[0], 'task1,task2');
      expect(executedBatches[1], 'task3,task4');
      expect(executedBatches[2], 'task5');
    });

    test('flush should do nothing if queue is empty', () async {
      // Flush empty queue
      await batchQueue.flush();

      // Verify no batch was executed
      expect(executedBatches.length, 0);
    });
  });
}
