import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

export 'generation_event.dart';
export 'generation_state.dart';

import '../../data/models/generated_image.dart';
import '../../data/models/generation_job.dart';
import '../../services/comfyui_service.dart';
import '../../services/storage_service.dart';
import 'generation_event.dart';
import 'generation_state.dart';

class GenerationBloc extends Bloc<GenerationEvent, GenerationState> {
  final StorageService _storage;
  final ComfyService _comfy;
  final Uuid _uuid;
  bool _processing = false;

  GenerationBloc({
    required this._storage,
    ComfyService? comfy,
    Uuid? uuid,
  })  : _comfy = comfy ?? ComfyService(),
        _uuid = uuid ?? const Uuid(),
        super(const GenerationState()) {
    on<GenerationSubmitted>(_onSubmitted);
    on<GenerationCancelled>(_onCancelled);
    on<GenerationCleared>(_onCleared);
    on<GenerationImageDeleted>(_onImageDeleted);
    on<GenerationImageFavoriteToggled>(_onFavoriteToggled);
    on<GenerationReordered>(_onReordered);
    on<GenerationRetried>(_onRetried);
  }

  Future<void> _onSubmitted(GenerationSubmitted event, Emitter<GenerationState> emit) async {
    final jobId = _uuid.v4();
    final now = DateTime.now();

    final job = GenerationJob(
      id: jobId,
      prompt: event.prompt,
      negativePrompt: event.negativePrompt,
      model: event.model,
      loras: event.loras,
      loraWeights: event.loraWeights,
      creativity: event.creativity,
      cfg: event.cfg,
      steps: event.steps ?? event.server.steps,
      hiresFix: event.hiresFix ?? event.server.hiresFix,
      width: event.width,
      height: event.height,
      seed: event.seed ?? _uuid.v4().hashCode,
      refImageFilename: event.refImageFilename,
      refImageSubfolder: event.refImageSubfolder,
      refImageType: event.refImageType,
      denoise: event.denoise,
      controlnetModel: event.controlnetModel,
      controlImageFilename: event.controlImageFilename,
      controlImageSubfolder: event.controlImageSubfolder,
      controlImageType: event.controlImageType,
      controlnetStrength: event.controlnetStrength,
      serverId: event.server.id,
      serverUrl: event.server.url,
      status: JobStatus.queued,
      createdAt: now,
    );

    final newQueue = [...state.queue, job];
    emit(state.copyWith(
      queue: newQueue,
      status: GenerationStatus.generating,
      errorMessage: null,
    ));

    await _processQueue(emit);
  }

  Future<void> _processQueue(Emitter<GenerationState> emit) async {
    if (_processing) return;
    _processing = true;

    while (state.queue.isNotEmpty && !state.isProcessing) {
      final job = state.queue.first;
      final remaining = state.queue.skip(1).toList();

      emit(state.copyWith(
        currentJob: job.copyWith(
          status: JobStatus.executing,
          startedAt: DateTime.now(),
        ),
        queue: remaining,
        status: GenerationStatus.generating,
      ));

      await _runJob(job, emit);

      if (state.currentJob?.isFailed == true) break;
    }

    if (state.queue.isEmpty && (state.currentJob == null || state.currentJob!.isDone)) {
      final hasError = state.currentJob?.isFailed == true;
      emit(state.copyWith(
        status: hasError ? GenerationStatus.error : GenerationStatus.idle,
        currentJob: null,
      ));
    }

    _processing = false;
  }

  Future<void> _runJob(GenerationJob job, Emitter<GenerationState> emit) async {
    final servers = _storage.getServers();
    final server = servers.where((s) => s.id == job.serverId).firstOrNull;
    if (server == null) {
      emit(state.copyWith(
        currentJob: job.copyWith(
          status: JobStatus.failed,
          errorMessage: 'Server not found',
          completedAt: DateTime.now(),
        ),
        status: GenerationStatus.error,
      ));
      return;
    }

    try {
      final result = await _comfy.generateImage(
        server,
        prompt: job.prompt,
        negativePrompt: job.negativePrompt,
        model: job.model,
        loras: job.loras,
        loraWeights: job.loraWeights,
        creativity: job.creativity,
        cfg: job.cfg,
        steps: job.steps,
        hiresFix: job.hiresFix,
        width: job.width,
        height: job.height,
        seed: job.seed,
        refImageFilename: job.refImageFilename,
        refImageSubfolder: job.refImageSubfolder,
        refImageType: job.refImageType,
        denoise: job.denoise,
        controlnetModel: job.controlnetModel,
        controlImageFilename: job.controlImageFilename,
        controlImageSubfolder: job.controlImageSubfolder,
        controlImageType: job.controlImageType,
        controlnetStrength: job.controlnetStrength,
        onPreview: (msg) {
          if (state.currentJob?.id != job.id) return;
          emit(state.copyWith(
            currentJob: state.currentJob!.copyWith(
              status: msg.type == 'progress'
                  ? JobStatus.progress
                  : msg.type == 'executing'
                      ? JobStatus.executing
                      : state.currentJob!.status,
              progressValue: msg.progressValue,
              progressMax: msg.progressMax,
              currentNode: msg.node,
            ),
          ));
        },
      );

      if (result.success && result.imageBytes != null) {
        final filename = '${_uuid.v4()}.png';
        final localPath = await _storage.saveImageFile(result.imageBytes!, filename);

        final image = GeneratedImage(
          id: _uuid.v4(),
          prompt: job.prompt,
          negativePrompt: job.negativePrompt,
          model: job.model,
          loras: job.loras,
          loraWeights: job.loraWeights,
          creativity: job.creativity,
          steps: job.steps,
          hiresFix: job.hiresFix,
          width: job.width,
          height: job.height,
          seed: job.seed,
          status: ImageStatus.completed,
          localPath: localPath,
          serverUrl: job.serverUrl,
          comfyFilename: result.filename,
          comfySubfolder: result.subfolder,
          comfyType: result.type,
          createdAt: job.createdAt,
          completedAt: DateTime.now(),
        );

        await _storage.saveImage(image);

        emit(state.copyWith(
          status: GenerationStatus.success,
          currentJob: job.copyWith(
            status: JobStatus.completed,
            completedAt: DateTime.now(),
          ),
          images: [image, ...state.images],
        ));
      } else {
        emit(state.copyWith(
          status: GenerationStatus.error,
          currentJob: job.copyWith(
            status: JobStatus.failed,
            errorMessage: result.error ?? 'Unknown error',
            completedAt: DateTime.now(),
          ),
          errorMessage: result.error,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: GenerationStatus.error,
        currentJob: job.copyWith(
          status: JobStatus.failed,
          errorMessage: e.toString(),
          completedAt: DateTime.now(),
        ),
        errorMessage: e.toString(),
      ));
    }
  }

  void _onCancelled(GenerationCancelled event, Emitter<GenerationState> emit) {
    if (state.currentJob?.id == event.jobId) {
      emit(state.copyWith(
        currentJob: state.currentJob!.copyWith(
          status: JobStatus.cancelled,
          completedAt: DateTime.now(),
        ),
        status: GenerationStatus.idle,
      ));
    } else {
      emit(state.copyWith(
        queue: state.queue.where((j) => j.id != event.jobId).toList(),
        status: state.queue.length <= 1 ? GenerationStatus.idle : state.status,
      ));
    }
  }

  void _onCleared(GenerationCleared event, Emitter<GenerationState> emit) {
    _processing = false;
    emit(state.copyWith(
      status: GenerationStatus.idle,
      queue: [],
      currentJob: null,
      errorMessage: null,
    ));
  }

  void _onReordered(GenerationReordered event, Emitter<GenerationState> emit) {
    emit(state.copyWith(queue: event.queue));
  }

  Future<void> _onRetried(GenerationRetried event, Emitter<GenerationState> emit) async {
    if (state.currentJob?.id == event.jobId && state.currentJob!.isFailed) {
      final retriedJob = state.currentJob!.copyWith(
        status: JobStatus.queued,
        errorMessage: null,
        progressValue: null,
        progressMax: null,
        currentNode: null,
        startedAt: null,
        completedAt: null,
      );
      emit(state.copyWith(
        currentJob: null,
        queue: [retriedJob, ...state.queue],
        status: GenerationStatus.generating,
      ));
      await _processQueue(emit);
    }
  }

  Future<void> _onImageDeleted(GenerationImageDeleted event, Emitter<GenerationState> emit) async {
    await _storage.deleteImage(event.imageId);
    emit(state.copyWith(
      images: state.images.where((img) => img.id != event.imageId).toList(),
    ));
  }

  Future<void> _onFavoriteToggled(GenerationImageFavoriteToggled event, Emitter<GenerationState> emit) async {
    await _storage.toggleFavorite(event.imageId);
    final images = state.images.map((img) {
      if (img.id != event.imageId) return img;
      return img.copyWith(isFavorite: !img.isFavorite);
    }).toList();
    emit(state.copyWith(images: images));
  }
}
