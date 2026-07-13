import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/comfy_server.dart';
import '../../data/models/generated_image.dart';
import '../../data/models/llm_model.dart';
import '../../data/models/llm_server.dart';
import '../../services/comfyui_service.dart';
import '../../services/llm_service.dart';
import '../../services/storage_service.dart';
import 'autogen_event.dart';
import 'autogen_state.dart';

export 'autogen_event.dart';
export 'autogen_state.dart';

class AutoGenBloc extends Bloc<AutoGenEvent, AutoGenState> {
  final StorageService _storage;
  final LlmService _llm;
  final ComfyService _comfy;
  final Uuid _uuid;

  bool _cancelToken = false;

  AutoGenBloc({
    required StorageService storage,
    LlmService? llm,
    ComfyService? comfy,
    Uuid? uuid,
  })  : _storage = storage,
        _llm = llm ?? LlmService(),
        _comfy = comfy ?? ComfyService(),
        _uuid = uuid ?? const Uuid(),
        super(const AutoGenState()) {
    on<AutoGenStarted>(_onStarted);
    on<AutoGenStopped>(_onStopped);
    on<AutoGenReset>(_onReset);
    on<AutoGenConfigChanged>(_onConfigChanged);
    on<AutoGenImageUpdated>(_onImageUpdated);
    on<AutoGenPromptGenerated>(_onPromptGenerated);
    on<AutoGenImageStarted>(_onImageStarted);
    on<AutoGenErrorOccurred>(_onErrorOccurred);
    on<AutoGenCompleted>(_onCompleted);
  }

  void _onConfigChanged(AutoGenConfigChanged event, Emitter<AutoGenState> emit) {
    emit(state.copyWith(
      mode: event.mode,
      topic: event.topic,
      basePrompt: event.basePrompt,
      mustIncludeTags: event.mustIncludeTags,
      maxImages: event.maxImages,
      selectedLoras: event.selectedLoras,
      imageModel: event.imageModel,
      llmServerId: event.llmServerId,
      llmModel: event.llmModel,
      imageServerId: event.imageServerId,
    ));
  }

  Future<void> _onStarted(AutoGenStarted event, Emitter<AutoGenState> emit) async {
    debugPrint('[AutoGenBloc] AutoGenStarted received, isRunning=${state.isRunning}');
    if (state.isRunning) return;
    _cancelToken = false;
    emit(state.copyWith(isRunning: true, status: AutoGenStatus.generatingPrompt));

    await _runLoop(emit);
  }

  void _onStopped(AutoGenStopped event, Emitter<AutoGenState> emit) {
    _cancelToken = true;
    emit(state.copyWith(isRunning: false, status: AutoGenStatus.paused));
  }

  void _onReset(AutoGenReset event, Emitter<AutoGenState> emit) {
    _cancelToken = true;
    emit(const AutoGenState());
  }

  void _onImageUpdated(AutoGenImageUpdated event, Emitter<AutoGenState> emit) {
    final images = state.images.map((img) {
      if (img.id == event.id) {
        return img.copyWith(status: event.status, localPath: event.localPath);
      }
      return img;
    }).toList();
    final completedCount = images.where((i) => i.status == ImageStatus.completed).length;
    emit(state.copyWith(images: images, generatedCount: completedCount));
  }

  void _onPromptGenerated(AutoGenPromptGenerated event, Emitter<AutoGenState> emit) {
    emit(state.copyWith(currentPrompt: event.prompt, status: AutoGenStatus.generatingImage));
  }

  void _onImageStarted(AutoGenImageStarted event, Emitter<AutoGenState> emit) {
    final images = [event.image, ...state.images];
    final completedCount = images.where((i) => i.status == ImageStatus.completed).length;
    emit(state.copyWith(images: images, generatedCount: completedCount));
  }

  void _onErrorOccurred(AutoGenErrorOccurred event, Emitter<AutoGenState> emit) {
    debugPrint('[AutoGenBloc] AutoGenErrorOccurred: ${event.message}');
    emit(state.copyWith(
      status: AutoGenStatus.error,
      errorMessage: event.message,
      isRunning: false,
    ));
  }

  void _onCompleted(AutoGenCompleted event, Emitter<AutoGenState> emit) {
    emit(state.copyWith(
      status: AutoGenStatus.completed,
      isRunning: false,
    ));
  }

  Future<void> _runLoop(Emitter<AutoGenState> emit) async {
    while (!_cancelToken) {
      final maxImages = state.maxImages;
      if (maxImages != null && state.generatedCount >= maxImages) {
        final hasPending = state.images.any(
          (img) => img.status == ImageStatus.pending || img.status == ImageStatus.processing,
        );
        if (!hasPending) {
          add(const AutoGenCompleted());
          return;
        }
        await Future.delayed(const Duration(seconds: 2));
        continue;
      }

      // Generate prompt
      String prompt;
      try {
        emit(state.copyWith(status: AutoGenStatus.generatingPrompt));
        prompt = await _generatePrompt();
      } catch (e) {
        add(AutoGenErrorOccurred('Failed to generate prompt: $e'));
        return;
      }
      if (_cancelToken) return;
      add(AutoGenPromptGenerated(prompt));

      // Generate image
      final ({String id, String localPath}) imageResult;
      try {
        emit(state.copyWith(status: AutoGenStatus.generatingImage));
        imageResult = await _generateImage(prompt);
      } catch (e) {
        add(AutoGenErrorOccurred('Failed to generate image: $e'));
        return;
      }
      if (_cancelToken) return;

      final autoImage = AutoGenImage(
        id: imageResult.id,
        prompt: prompt,
        status: ImageStatus.completed,
        localPath: imageResult.localPath,
        createdAt: DateTime.now(),
      );
      add(AutoGenImageStarted(autoImage));

      // Wait before next iteration
      if (!_cancelToken) {
        emit(state.copyWith(status: AutoGenStatus.waiting));
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  Future<String> _generatePrompt() async {
    final llmServerId = state.llmServerId;
    final llmModel = state.llmModel;
    if (llmServerId == null || llmModel == null) {
      throw Exception('LLM server or model not configured (serverId=$llmServerId, model=$llmModel)');
    }

    final server = _storage.getLlmServer(llmServerId);
    if (server == null) {
      throw Exception('LLM server $llmServerId not found in storage');
    }

    final systemPrompt = _buildSystemPrompt();
    final userPrompt = _buildUserPrompt();
    debugPrint('[AutoGenBloc] _generatePrompt: calling ${server.url} with model $llmModel');

    final result = await _llm.chatCompletion(
      server: server,
      model: llmModel,
      messages: [
        LlmChatMessage.system(systemPrompt),
        LlmChatMessage.user(userPrompt),
      ],
      temperature: 0.8,
      maxTokens: 1024,
    );
    debugPrint('[AutoGenBloc] _generatePrompt: chatCompletion result success=${result.success}, error=${result.error}, contentLength=${result.content.length}');

    if (!result.success) {
      throw Exception('LLM request failed: ${result.error ?? 'unknown error'}');
    }
    final cleaned = _cleanPrompt(result.content);
    debugPrint('[AutoGenBloc] _generatePrompt: success, prompt=$cleaned');
    return cleaned;
  }

  String _buildSystemPrompt() {
    final loraContext = state.selectedLoras.isNotEmpty
        ? state.selectedLoras.map((l) => '- $l').join('\n')
        : '(No LoRAs selected)';

    final mustInclude = state.mustIncludeTags.trim().isNotEmpty
        ? '\n\nMANDATORY REQUIREMENTS - YOU MUST FOLLOW THESE EXACTLY:\nThe following tags MUST be included in your prompt word-for-word:\n"${state.mustIncludeTags.trim()}"\n\nYou are NOT allowed to censor, remove, or alter these required elements.'
        : '';

    return '''You are a prompt engineer for AI image generation using ComfyUI/Stable Diffusion.

Available LoRAs (incorporate these naturally into your prompt):
$loraContext$mustInclude

CRITICAL RULES:
1. Generate ONLY the final prompt text - NOTHING ELSE
2. NO headers, NO "Prompt Text:", NO bullet points
3. NO word definitions or explanations
4. NO repetitive variations of the same concept
5. Output must be ONE continuous flowing paragraph
6. Use tags naturally within the description
7. Start with quality tags when appropriate: "masterpiece, best quality, highres, ..."
8. Describe: subject, artistic style, lighting, composition, color palette, mood
9. Be vivid and artistic - use evocative language, cinematic terms
10. Include technical quality markers: "8k", "hyper-realistic", "cinematic"
11. Length: 50-200 words of flowing descriptive text
12. NEVER repeat the same tag or word multiple times
13. Keep the prompt under 500 characters''';
  }

  String _buildUserPrompt() {
    if (state.mode == AutoGenMode.variation) {
      final base = state.basePrompt.trim().isEmpty
          ? 'A creative image'
          : state.basePrompt.trim();
      return 'Create a variation of this prompt. Keep the core subject but change artistic style, lighting, composition, and mood:\n\n"$base"';
    }
    final topic = state.topic.trim();
    return topic.isNotEmpty
        ? 'Generate a creative image prompt for: $topic'
        : 'Generate a creative, varied image prompt';
  }

  String _cleanPrompt(String raw) {
    var p = raw.trim();
    // Remove thinking tags and their contents
    final thinkRegex = RegExp(r'<think(?:ing)?>.*?</(?:think(?:ing)?)>', caseSensitive: false, dotAll: true);
    p = p.replaceAll(thinkRegex, '');
    // Remove unclosed thinking tags
    p = p.replaceAll(RegExp(r'</?think(?:ing)?>', caseSensitive: false), '');
    // Remove excessive asterisks
    p = p.replaceAll(RegExp(r'\*{3,}'), '');
    // Remove multiple newlines
    p = p.replaceAll(RegExp(r'\n+'), ' ');
    // Remove quotes at start/end
    if (p.startsWith('"') || p.startsWith("'")) p = p.substring(1);
    if (p.endsWith('"') || p.endsWith("'")) p = p.substring(0, p.length - 1);
    // Clean up whitespace
    p = p.replaceAll(RegExp(r'\s+'), ' ');
    if (p.length > 1500) p = p.substring(0, 1500).trim();
    return p.trim();
  }

  Future<({String id, String localPath})> _generateImage(String prompt) async {
    final imageServerId = state.imageServerId;
    ComfyServer? server;
    if (imageServerId != null) {
      server = _storage.getServer(imageServerId);
    }
    server ??= _storage.getDefaultServer();
    if (server == null) {
      throw Exception('No image server configured or found in storage');
    }

    final seed = DateTime.now().microsecondsSinceEpoch % 2147483647;
    debugPrint('[AutoGenBloc] _generateImage: calling ${server.url} with model ${state.imageModel}');
    final result = await _comfy.generateImage(
      server,
      prompt: prompt,
      model: state.imageModel,
      loras: state.selectedLoras,
      seed: seed,
    );

    if (!result.success) {
      throw Exception('Image generation failed: ${result.error ?? 'unknown error'}');
    }
    if (result.imageBytes == null) {
      throw Exception('Image generation succeeded but returned no image bytes');
    }

    final filename = 'auto_${_uuid.v4()}.png';
    final localPath = await _storage.saveImageFile(result.imageBytes!, filename);

    // Save to gallery
    final image = GeneratedImage(
      id: _uuid.v4(),
      prompt: prompt,
      model: state.imageModel,
      loras: state.selectedLoras,
      creativity: Creativity.normal,
      steps: server.steps,
      hiresFix: server.hiresFix,
      width: 1024,
      height: 1024,
      seed: seed,
      status: ImageStatus.completed,
      localPath: localPath,
      serverUrl: server.url,
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
    );
    await _storage.saveImage(image);

    return (id: image.id, localPath: localPath);
  }

  @override
  Future<void> close() {
    _cancelToken = true;
    return super.close();
  }
}
