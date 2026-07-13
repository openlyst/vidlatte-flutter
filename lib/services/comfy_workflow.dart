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
  final String? controlnetModel;
  final String? controlImageFilename;
  final String? controlImageSubfolder;
  final String? controlImageType;
  final double controlnetStrength;

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
    this.controlnetModel,
    this.controlImageFilename,
    this.controlImageSubfolder,
    this.controlImageType,
    this.controlnetStrength = 1.0,
  }) : seed = seed ?? Random().nextInt(2147483647);

  bool get isImg2Img => refImageFilename != null;
  bool get hasControlNet => controlnetModel != null && controlImageFilename != null;
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

    if (inputs.hasControlNet) {
      final loadControlImageInputs = <String, dynamic>{
        'image': inputs.controlImageFilename!,
      };
      if (inputs.controlImageSubfolder != null && inputs.controlImageSubfolder!.isNotEmpty) {
        loadControlImageInputs['subfolder'] = inputs.controlImageSubfolder;
      }
      if (inputs.controlImageType != null) {
        loadControlImageInputs['type'] = inputs.controlImageType;
      }

      workflow[nodeId.toString()] = {
        'inputs': loadControlImageInputs,
        'class_type': 'LoadImage',
      };
      final controlImageRef = [nodeId.toString(), 0];
      nodeId++;

      final currentModelRef = (workflow['5']['inputs']['model'] as List);

      workflow[nodeId.toString()] = {
        'inputs': {
          'control_net_name': inputs.controlnetModel,
          'image': controlImageRef,
          'strength': inputs.controlnetStrength,
          'model': currentModelRef,
        },
        'class_type': 'ControlNetApply',
      };
      (workflow['5'] as Map<String, dynamic>)['inputs']['model'] = [nodeId.toString(), 0];
      nodeId++;
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

  static Map<String, dynamic> faceRestore(
    String filename,
    String subfolder,
    String type, {
    double strength = 0.7,
    bool useCodeFormer = false,
  }) {
    final loadImageInputs = <String, dynamic>{
      'image': filename,
    };
    if (subfolder.isNotEmpty) loadImageInputs['subfolder'] = subfolder;
    if (type.isNotEmpty) loadImageInputs['type'] = type;

    return {
      '1': {
        'inputs': loadImageInputs,
        'class_type': 'LoadImage',
      },
      '2': {
        'inputs': {
          'image': ['1', 0],
          'strength': strength,
        },
        'class_type': useCodeFormer ? 'CodeFormerReconstruction' : 'GFPGAN',
      },
      '3': {
        'inputs': {
          'filename_prefix': 'vidlatte_face',
          'images': ['2', 0],
        },
        'class_type': 'SaveImage',
      },
    };
  }

  static Map<String, dynamic> upscale(
    String filename,
    String subfolder,
    String type, {
    String model = 'RealESRGAN_x4plus.pth',
    double scale = 2.0,
  }) {
    final loadImageInputs = <String, dynamic>{
      'image': filename,
    };
    if (subfolder.isNotEmpty) loadImageInputs['subfolder'] = subfolder;
    if (type.isNotEmpty) loadImageInputs['type'] = type;

    final modelScale = _parseModelScale(model);
    final adjustRatio = scale / modelScale;

    if ((adjustRatio - 1.0).abs() < 0.01) {
      return {
        '1': {
          'inputs': loadImageInputs,
          'class_type': 'LoadImage',
        },
        '2': {
          'inputs': {
            'model_name': model,
          },
          'class_type': 'UpscaleModelLoader',
        },
        '3': {
          'inputs': {
            'upscale_model': ['2', 0],
            'image': ['1', 0],
          },
          'class_type': 'ImageUpscaleWithModel',
        },
        '4': {
          'inputs': {
            'filename_prefix': 'vidlatte_upscale',
            'images': ['3', 0],
          },
          'class_type': 'SaveImage',
        },
      };
    }

    return {
      '1': {
        'inputs': loadImageInputs,
        'class_type': 'LoadImage',
      },
      '2': {
        'inputs': {
          'model_name': model,
        },
        'class_type': 'UpscaleModelLoader',
      },
      '3': {
        'inputs': {
          'upscale_model': ['2', 0],
          'image': ['1', 0],
        },
        'class_type': 'ImageUpscaleWithModel',
      },
      '4': {
        'inputs': {
          'upscale_method': 'lanczos',
          'scale_by': adjustRatio,
          'image': ['3', 0],
        },
        'class_type': 'ImageScaleBy',
      },
      '5': {
        'inputs': {
          'filename_prefix': 'vidlatte_upscale',
          'images': ['4', 0],
        },
        'class_type': 'SaveImage',
      },
    };
  }

  static double _parseModelScale(String modelName) {
    final match = RegExp(r'^(\d+)x[_-]').firstMatch(modelName);
    if (match != null) return double.parse(match.group(1)!);
    final match2 = RegExp(r'[_-](\d+)x[_-]').firstMatch(modelName);
    if (match2 != null) return double.parse(match2.group(1)!);
    return 4.0;
  }

  static Map<String, dynamic> inpaint(
    String imageFilename,
    String imageSubfolder,
    String imageType,
    String maskFilename,
    String maskSubfolder,
    String maskType, {
    required String prompt,
    String negativePrompt = '',
    required String model,
    List<String> loras = const [],
    Map<String, double> loraWeights = const {},
    int seed = 0,
    int steps = 20,
    double cfg = 7.0,
    double denoise = 0.75,
  }) {
    final loadImageInputs = <String, dynamic>{
      'image': imageFilename,
    };
    if (imageSubfolder.isNotEmpty) loadImageInputs['subfolder'] = imageSubfolder;
    if (imageType.isNotEmpty) loadImageInputs['type'] = imageType;

    final loadMaskInputs = <String, dynamic>{
      'image': maskFilename,
    };
    if (maskSubfolder.isNotEmpty) loadMaskInputs['subfolder'] = maskSubfolder;
    if (maskType.isNotEmpty) loadMaskInputs['type'] = maskType;

    final workflow = <String, dynamic>{
      '1': {
        'inputs': {'ckpt_name': model},
        'class_type': 'CheckpointLoaderSimple',
      },
      '2': {
        'inputs': {
          'text': prompt,
          'clip': ['1', 1],
        },
        'class_type': 'CLIPTextEncode',
      },
      '3': {
        'inputs': {
          'text': negativePrompt,
          'clip': ['1', 1],
        },
        'class_type': 'CLIPTextEncode',
      },
      '10': {
        'inputs': loadImageInputs,
        'class_type': 'LoadImage',
      },
      '11': {
        'inputs': loadMaskInputs,
        'class_type': 'LoadImage',
      },
      '12': {
        'inputs': {
          'pixels': ['10', 0],
          'vae': ['1', 2],
        },
        'class_type': 'VAEEncode',
      },
      '13': {
        'inputs': {
          'samples': ['12', 0],
          'mask': ['11', 1],
        },
        'class_type': 'SetLatentNoiseMask',
      },
      '5': {
        'inputs': {
          'seed': seed,
          'steps': steps,
          'cfg': cfg,
          'sampler_name': 'euler',
          'scheduler': 'normal',
          'denoise': denoise,
          'model': ['1', 0],
          'positive': ['2', 0],
          'negative': ['3', 0],
          'latent_image': ['13', 0],
        },
        'class_type': 'KSampler',
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
          'filename_prefix': 'vidlatte_inpaint',
          'images': ['6', 0],
        },
        'class_type': 'SaveImage',
      },
    };

    if (loras.isNotEmpty) {
      var currentModelRef = ['1', 0];
      var currentClipRef = ['1', 1];
      var nodeId = 20;
      for (final lora in loras) {
        final weight = loraWeights[lora] ?? 0.8;
        workflow[nodeId.toString()] = {
          'inputs': {
            'lora_name': lora,
            'strength_model': weight,
            'strength_clip': weight,
            'model': currentModelRef,
            'clip': currentClipRef,
          },
          'class_type': 'LoraLoader',
        };
        currentModelRef = [nodeId.toString(), 0];
        currentClipRef = [nodeId.toString(), 1];
        nodeId++;
      }
      workflow['5']['inputs']['model'] = currentModelRef;
      workflow['2']['inputs']['clip'] = currentClipRef;
      workflow['3']['inputs']['clip'] = currentClipRef;
    }

    return workflow;
  }
}
