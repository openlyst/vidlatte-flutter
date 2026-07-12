import 'dart:math';

import '../data/models/comfy_server.dart';

class WorkflowInputs {
  final String prompt;
  final String negativePrompt;
  final String model;
  final List<String> loras;
  final Map<String, double> loraWeights;
  final int width;
  final int height;
  final int seed;
  final int steps;
  final double? cfg;
  final Creativity creativity;
  final String? refImageFilename;
  final String? refImageSubfolder;
  final String? refImageType;
  final double denoise;

  WorkflowInputs({
    required this.prompt,
    required this.model,
    this.negativePrompt = '',
    this.loras = const [],
    this.loraWeights = const {},
    this.width = 768,
    this.height = 768,
    int? seed,
    this.steps = 20,
    this.cfg,
    this.creativity = Creativity.normal,
    this.refImageFilename,
    this.refImageSubfolder,
    this.refImageType,
    this.denoise = 0.5,
  }) : seed = seed ?? Random().nextInt(2147483647);

  bool get isImg2Img => refImageFilename != null;
}

class ComfyWorkflow {
  ComfyWorkflow._();

  static Map<String, dynamic> generate(WorkflowInputs inputs) {
    final cfgScale = inputs.cfg ?? inputs.creativity.cfgScale;
    var nodeId = 8;

    final workflow = <String, dynamic>{
      '1': {
        'inputs': {'ckpt_name': inputs.model},
        'class_type': 'CheckpointLoaderSimple',
      },
      '2': {
        'inputs': {
          'text': inputs.prompt,
          'clip': ['1', 1],
        },
        'class_type': 'CLIPTextEncode',
      },
      '3': {
        'inputs': {
          'text': inputs.negativePrompt,
          'clip': ['1', 1],
        },
        'class_type': 'CLIPTextEncode',
      },
      '5': {
        'inputs': {
          'seed': inputs.seed,
          'steps': inputs.steps,
          'cfg': cfgScale,
          'sampler_name': 'euler',
          'scheduler': 'normal',
          'denoise': inputs.isImg2Img ? inputs.denoise : 1,
          'model': ['1', 0],
          'positive': ['2', 0],
          'negative': ['3', 0],
          'latent_image': ['4', 0],
        },
        'class_type': 'KSampler',
      },
      '4': inputs.isImg2Img
          ? {
              'inputs': {
                'pixels': ['9', 0],
                'vae': ['1', 2],
              },
              'class_type': 'VAEEncode',
            }
          : {
              'inputs': {
                'width': inputs.width,
                'height': inputs.height,
                'batch_size': 1,
              },
              'class_type': 'EmptyLatentImage',
            },
      '6': {
        'inputs': {
          'samples': ['5', 0],
          'vae': ['1', 2],
        },
        'class_type': 'VAEDecode',
      },
      '7': {
        'inputs': {
          'filename_prefix': 'vidlatte',
          'images': ['6', 0],
        },
        'class_type': 'SaveImage',
      },
    };

    if (inputs.isImg2Img) {
      final loadImageInputs = <String, dynamic>{
        'image': inputs.refImageFilename!,
      };
      if (inputs.refImageSubfolder != null && inputs.refImageSubfolder!.isNotEmpty) {
        loadImageInputs['subfolder'] = inputs.refImageSubfolder;
      }
      if (inputs.refImageType != null) {
        loadImageInputs['type'] = inputs.refImageType;
      }
      workflow['9'] = {
        'inputs': loadImageInputs,
        'class_type': 'LoadImage',
      };
    }

    if (inputs.loras.isNotEmpty) {
      var currentModelRef = ['1', 0];
      var currentClipRef = ['1', 1];
      for (final lora in inputs.loras) {
        final strength = inputs.loraWeights[lora] ?? 0.8;
        workflow[nodeId.toString()] = {
          'inputs': {
            'lora_name': lora,
            'strength_model': strength,
            'strength_clip': strength,
            'model': currentModelRef,
            'clip': currentClipRef,
          },
          'class_type': 'LoraLoader',
        };
        currentModelRef = [nodeId.toString(), 0];
        currentClipRef = [nodeId.toString(), 1];
        nodeId++;
      }

      (workflow['2'] as Map<String, dynamic>)['inputs']['clip'] = currentClipRef;
      (workflow['3'] as Map<String, dynamic>)['inputs']['clip'] = currentClipRef;
      (workflow['5'] as Map<String, dynamic>)['inputs']['model'] = currentModelRef;
    }

    return workflow;
  }

  static Map<String, dynamic> addHiresFix(
    Map<String, dynamic> workflow,
    double scale,
    int steps,
  ) {
    final lastNodeId = int.parse(
      workflow.keys.reduce((a, b) => int.parse(a) > int.parse(b) ? a : b),
    );

    final upscaleId = (lastNodeId + 1).toString();
    final latentId = (lastNodeId + 2).toString();
    final ksamplerId = (lastNodeId + 3).toString();
    final vaeDecodeId = (lastNodeId + 4).toString();
    final saveId = (lastNodeId + 5).toString();

    workflow[upscaleId] = {
      'inputs': {
        'upscale_method': 'nearest-exact',
        'scale_by': scale,
        'image': ['6', 0],
      },
      'class_type': 'ImageScaleBy',
    };

    workflow[latentId] = {
      'inputs': {
        'vae': ['1', 2],
        'pixels': [upscaleId, 0],
      },
      'class_type': 'VAEEncode',
    };

    workflow[ksamplerId] = {
      'inputs': {
        'seed': (workflow['5'] as Map<String, dynamic>)['inputs']['seed'],
        'steps': steps,
        'cfg': (workflow['5'] as Map<String, dynamic>)['inputs']['cfg'],
        'sampler_name': 'euler',
        'scheduler': 'normal',
        'denoise': 0.5,
        'model': (workflow['5'] as Map<String, dynamic>)['inputs']['model'],
        'positive': ['2', 0],
        'negative': ['3', 0],
        'latent_image': [latentId, 0],
      },
      'class_type': 'KSampler',
    };

    workflow[vaeDecodeId] = {
      'inputs': {
        'samples': [ksamplerId, 0],
        'vae': ['1', 2],
      },
      'class_type': 'VAEDecode',
    };

    workflow[saveId] = {
      'inputs': {
        'filename_prefix': 'vidlatte_hires',
        'images': [vaeDecodeId, 0],
      },
      'class_type': 'SaveImage',
    };

    return workflow;
  }
}
