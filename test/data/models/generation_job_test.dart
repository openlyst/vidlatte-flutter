import 'package:flutter_test/flutter_test.dart';
import 'package:vidlatte/data/models/comfy_server.dart';
import 'package:vidlatte/data/models/generation_job.dart';

void main() {
  group('JobStatus', () {
    test('name returns correct string', () {
      expect(JobStatus.queued.name, 'queued');
      expect(JobStatus.executing.name, 'executing');
      expect(JobStatus.progress.name, 'progress');
      expect(JobStatus.completed.name, 'completed');
      expect(JobStatus.failed.name, 'failed');
      expect(JobStatus.cancelled.name, 'cancelled');
    });

    test('fromString parses correctly', () {
      expect(JobStatusExtension.fromString('queued'), JobStatus.queued);
      expect(JobStatusExtension.fromString('completed'), JobStatus.completed);
      expect(JobStatusExtension.fromString('unknown'), JobStatus.queued);
    });
  });

  group('GenerationJob', () {
    final now = DateTime(2025, 1, 1);
    final job = GenerationJob(
      id: 'job-1',
      prompt: 'test prompt',
      model: 'model.safetensors',
      loras: ['lora1'],
      creativity: Creativity.normal,
      steps: 20,
      serverId: 'server-1',
      status: JobStatus.progress,
      progressValue: 5,
      progressMax: 20,
      createdAt: now,
    );

    test('progressFraction calculates correctly', () {
      expect(job.progressFraction, 0.25);
    });

    test('progressFraction returns null when max is 0', () {
      final j = job.copyWith(progressMax: 0);
      expect(j.progressFraction, isNull);
    });

    test('progressFraction returns null when value is null', () {
      final j = GenerationJob(
        id: 'job-null',
        prompt: 'test',
        model: 'model',
        serverId: 's1',
        progressValue: null,
        progressMax: 20,
        createdAt: now,
      );
      expect(j.progressFraction, isNull);
    });

    test('isComplete, isFailed, isCancelled, isDone, isActive', () {
      expect(job.isComplete, false);
      expect(job.isFailed, false);
      expect(job.isCancelled, false);
      expect(job.isDone, false);
      expect(job.isActive, true);

      final completed = job.copyWith(status: JobStatus.completed);
      expect(completed.isComplete, true);
      expect(completed.isDone, true);
      expect(completed.isActive, false);

      final failed = job.copyWith(status: JobStatus.failed);
      expect(failed.isFailed, true);
      expect(failed.isDone, true);

      final cancelled = job.copyWith(status: JobStatus.cancelled);
      expect(cancelled.isCancelled, true);
      expect(cancelled.isDone, true);
    });

    test('copyWith creates modified copy', () {
      final modified = job.copyWith(
        status: JobStatus.completed,
        progressValue: 20,
        completedAt: now.add(const Duration(seconds: 5)),
      );
      expect(modified.status, JobStatus.completed);
      expect(modified.progressValue, 20);
      expect(modified.prompt, job.prompt);
    });
  });
}
