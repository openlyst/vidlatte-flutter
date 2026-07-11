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
  }

  Future<void> _onSubmitted(GenerationSubmitted event, Emitter<GenerationState> emit) async {
    final jobId = _uuid.v4();
    final now = DateTime.now();

    final job = GenerationJob(
      id: jobId,
      prompt: event.prompt,
      model: event.model,
      loras: event.loras,
      creativity: event.creativity,
      steps: event.steps ?? event.server.steps,
      hiresFix: event.hiresFix ?? event.server.hiresFix,
      width: event.width,
      height: event.height,
      seed: event.seed ?? _uuid.v4().hashCode,
      serverId: event.server.id,
      serverUrl: event.server.url,
      status: JobStatus.queued,
      createdAt: now,
      startedAt: now,
    );

    emit(state.copyWith(
      status: GenerationStatus.generating,
      activeJobs: [...state.activeJobs, job],
      errorMessage: null,
    ));

    try {
      final result = await _comfy.generateImage(
        event.server,
        prompt: event.prompt,
        model: event.model,
        loras: event.loras,
        creativity: event.creativity,
        cfg: event.cfg,
        steps: event.steps,
        hiresFix: event.hiresFix,
        width: event.width,
        height: event.height,
        seed: event.seed,
        onPreview: (msg) {
          final updatedJobs = state.activeJobs.map((j) {
            if (j.id != jobId) return j;
            return j.copyWith(
              status: msg.type == 'progress'
                  ? JobStatus.progress
                  : msg.type == 'executing'
                      ? JobStatus.executing
                      : j.status,
              progressValue: msg.progressValue,
              progressMax: msg.progressMax,
              currentNode: msg.node,
            );
          }).toList();
          emit(state.copyWith(activeJobs: updatedJobs));
        },
      );

      if (result.success && result.imageBytes != null) {
        final filename = '${_uuid.v4()}.png';
        final localPath = await _storage.saveImageFile(result.imageBytes!, filename);

        final image = GeneratedImage(
          id: _uuid.v4(),
          prompt: event.prompt,
          model: event.model,
          loras: event.loras,
          creativity: event.creativity,
          steps: event.steps ?? event.server.steps,
          hiresFix: event.hiresFix ?? event.server.hiresFix,
          width: event.width,
          height: event.height,
          seed: job.seed,
          status: ImageStatus.completed,
          localPath: localPath,
          serverUrl: event.server.url,
          comfyFilename: result.filename,
          comfySubfolder: result.subfolder,
          comfyType: result.type,
          createdAt: now,
          completedAt: DateTime.now(),
        );

        await _storage.saveImage(image);

        final updatedJobs = state.activeJobs.where((j) => j.id != jobId).toList();
        emit(state.copyWith(
          status: GenerationStatus.success,
          activeJobs: updatedJobs,
          images: [image, ...state.images],
        ));
      } else {
        final updatedJobs = state.activeJobs.map((j) {
          if (j.id != jobId) return j;
          return j.copyWith(
            status: JobStatus.failed,
            errorMessage: result.error ?? 'Unknown error',
            completedAt: DateTime.now(),
          );
        }).toList();
        emit(state.copyWith(
          status: GenerationStatus.error,
          activeJobs: updatedJobs,
          errorMessage: result.error,
        ));
      }
    } catch (e) {
      final updatedJobs = state.activeJobs.map((j) {
        if (j.id != jobId) return j;
        return j.copyWith(
          status: JobStatus.failed,
          errorMessage: e.toString(),
          completedAt: DateTime.now(),
        );
      }).toList();
      emit(state.copyWith(
        status: GenerationStatus.error,
        activeJobs: updatedJobs,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onCancelled(GenerationCancelled event, Emitter<GenerationState> emit) {
    final updatedJobs = state.activeJobs.where((j) => j.id != event.jobId).toList();
    emit(state.copyWith(
      activeJobs: updatedJobs,
      status: updatedJobs.isEmpty ? GenerationStatus.idle : state.status,
    ));
  }

  void _onCleared(GenerationCleared event, Emitter<GenerationState> emit) {
    emit(state.copyWith(
      status: GenerationStatus.idle,
      activeJobs: [],
      errorMessage: null,
    ));
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
