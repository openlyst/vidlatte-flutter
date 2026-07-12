import 'package:flutter_test/flutter_test.dart';
import 'package:vidlatte/data/models/comfy_server.dart';
import 'package:vidlatte/services/comfy_workflow.dart';

void main() {
  group('ComfyWorkflow.generate', () {
    test('creates base workflow with all required nodes', () {
      final workflow = ComfyWorkflow.generate(WorkflowInputs(
        prompt: 'a cat',
        model: 'sd_xl.safetensors',
        seed: 42,
      ));

      expect(workflow['1']['class_type'], 'CheckpointLoaderSimple');
      expect(workflow['2']['class_type'], 'CLIPTextEncode');
      expect(workflow['3']['class_type'], 'CLIPTextEncode');
      expect(workflow['4']['class_type'], 'EmptyLatentImage');
      expect(workflow['5']['class_type'], 'KSampler');
      expect(workflow['6']['class_type'], 'VAEDecode');
      expect(workflow['7']['class_type'], 'SaveImage');
    });

    test('sets prompt in positive CLIPTextEncode', () {
      final workflow = ComfyWorkflow.generate(WorkflowInputs(
        prompt: 'a beautiful sunset',
        model: 'model.safetensors',
        seed: 1,
      ));
      final positive = (workflow['2'] as Map<String, dynamic>)['inputs'] as Map<String, dynamic>;
      expect(positive['text'], 'a beautiful sunset');
    });

    test('sets empty negative prompt', () {
      final workflow = ComfyWorkflow.generate(WorkflowInputs(
        prompt: 'test',
        model: 'model.safetensors',
        seed: 1,
      ));
      final negative = (workflow['3'] as Map<String, dynamic>)['inputs'] as Map<String, dynamic>;
      expect(negative['text'], '');
    });

    test('sets model name in CheckpointLoaderSimple', () {
      final workflow = ComfyWorkflow.generate(WorkflowInputs(
        prompt: 'test',
        model: 'my_model.safetensors',
        seed: 1,
      ));
      final loader = (workflow['1'] as Map<String, dynamic>)['inputs'] as Map<String, dynamic>;
      expect(loader['ckpt_name'], 'my_model.safetensors');
    });

    test('sets seed in KSampler', () {
      final workflow = ComfyWorkflow.generate(WorkflowInputs(
        prompt: 'test',
        model: 'model.safetensors',
        seed: 12345,
      ));
      final ksampler = (workflow['5'] as Map<String, dynamic>)['inputs'] as Map<String, dynamic>;
      expect(ksampler['seed'], 12345);
    });

    test('uses creativity cfg scale', () {
      final workflow = ComfyWorkflow.generate(WorkflowInputs(
        prompt: 'test',
        model: 'model.safetensors',
        seed: 1,
        creativity: Creativity.low,
      ));
      final ksampler = (workflow['5'] as Map<String, dynamic>)['inputs'] as Map<String, dynamic>;
      expect(ksampler['cfg'], 11);
    });

    test('uses custom cfg when provided', () {
      final workflow = ComfyWorkflow.generate(WorkflowInputs(
        prompt: 'test',
        model: 'model.safetensors',
        seed: 1,
        cfg: 9.5,
      ));
      final ksampler = (workflow['5'] as Map<String, dynamic>)['inputs'] as Map<String, dynamic>;
      expect(ksampler['cfg'], 9.5);
    });

    test('sets dimensions in EmptyLatentImage', () {
      final workflow = ComfyWorkflow.generate(WorkflowInputs(
        prompt: 'test',
        model: 'model.safetensors',
        seed: 1,
        width: 512,
        height: 768,
      ));
      final latent = (workflow['4'] as Map<String, dynamic>)['inputs'] as Map<String, dynamic>;
      expect(latent['width'], 512);
      expect(latent['height'], 768);
    });

    test('sets steps in KSampler', () {
      final workflow = ComfyWorkflow.generate(WorkflowInputs(
        prompt: 'test',
        model: 'model.safetensors',
        seed: 1,
        steps: 40,
      ));
      final ksampler = (workflow['5'] as Map<String, dynamic>)['inputs'] as Map<String, dynamic>;
      expect(ksampler['steps'], 40);
    });

    test('adds LoRA loader nodes when loras provided', () {
      final workflow = ComfyWorkflow.generate(WorkflowInputs(
        prompt: 'test',
        model: 'model.safetensors',
        seed: 1,
        loras: ['lora1.safetensors', 'lora2.safetensors'],
      ));

      expect(workflow.containsKey('8'), true);
      expect(workflow.containsKey('9'), true);
      final lora1 = (workflow['8'] as Map<String, dynamic>)['inputs'] as Map<String, dynamic>;
      expect(lora1['lora_name'], 'lora1.safetensors');
      expect(lora1['strength_model'], 0.8);

      final lora2 = (workflow['9'] as Map<String, dynamic>)['inputs'] as Map<String, dynamic>;
      expect(lora2['lora_name'], 'lora2.safetensors');
    });

    test('chains LoRA references correctly', () {
      final workflow = ComfyWorkflow.generate(WorkflowInputs(
        prompt: 'test',
        model: 'model.safetensors',
        seed: 1,
        loras: ['lora1.safetensors'],
      ));

      final lora1 = (workflow['8'] as Map<String, dynamic>)['inputs'] as Map<String, dynamic>;
      expect(lora1['model'], ['1', 0]);

      final positive = (workflow['2'] as Map<String, dynamic>)['inputs'] as Map<String, dynamic>;
      expect(positive['clip'], ['8', 1]);

      final ksampler = (workflow['5'] as Map<String, dynamic>)['inputs'] as Map<String, dynamic>;
      expect(ksampler['model'], ['8', 0]);
    });

    test('does not add LoRA nodes when no loras', () {
      final workflow = ComfyWorkflow.generate(WorkflowInputs(
        prompt: 'test',
        model: 'model.safetensors',
        seed: 1,
      ));
      expect(workflow.containsKey('8'), false);
    });
  });

  group('ComfyWorkflow.addHiresFix', () {
    test('adds upscale, vae encode, ksampler, vae decode, and save nodes', () {
      var workflow = ComfyWorkflow.generate(WorkflowInputs(
        prompt: 'test',
        model: 'model.safetensors',
        seed: 1,
      ));
      final baseCount = workflow.length;
      workflow = ComfyWorkflow.addHiresFix(workflow, 1.5, 10);

      expect(workflow.length, baseCount + 5);
    });

    test('uses nearest-exact upscale method', () {
      var workflow = ComfyWorkflow.generate(WorkflowInputs(
        prompt: 'test',
        model: 'model.safetensors',
        seed: 1,
      ));
      workflow = ComfyWorkflow.addHiresFix(workflow, 2.0, 15);

      final nodeIds = workflow.keys.map(int.parse).toList()..sort();
      final upscaleNode = workflow[nodeIds[nodeIds.length - 5].toString()];
      final inputs = (upscaleNode as Map<String, dynamic>)['inputs'] as Map<String, dynamic>;
      expect(inputs['upscale_method'], 'nearest-exact');
      expect(inputs['scale_by'], 2.0);
    });

    test('uses ImageScaleBy node type (not ImageUpscaleWith)', () {
      var workflow = ComfyWorkflow.generate(WorkflowInputs(
        prompt: 'test',
        model: 'model.safetensors',
        seed: 1,
      ));
      workflow = ComfyWorkflow.addHiresFix(workflow, 1.5, 10);

      final nodeIds = workflow.keys.map(int.parse).toList()..sort();
      final upscaleNode = workflow[nodeIds[nodeIds.length - 5].toString()];
      final classType = (upscaleNode as Map<String, dynamic>)['class_type'];
      expect(classType, 'ImageScaleBy');
    });

    test('uses denoise 0.5 for hires fix ksampler', () {
      var workflow = ComfyWorkflow.generate(WorkflowInputs(
        prompt: 'test',
        model: 'model.safetensors',
        seed: 1,
      ));
      workflow = ComfyWorkflow.addHiresFix(workflow, 1.5, 10);

      final nodeIds = workflow.keys.map(int.parse).toList()..sort();
      final ksamplerNode = workflow[nodeIds[nodeIds.length - 3].toString()];
      final inputs = (ksamplerNode as Map<String, dynamic>)['inputs'] as Map<String, dynamic>;
      expect(inputs['denoise'], 0.5);
      expect(inputs['steps'], 10);
    });
  });

  group('ComfyWorkflow.upscale', () {
    test('uses UpscaleModelLoader and ImageUpscaleWithModel nodes', () {
      final workflow = ComfyWorkflow.upscale('test.png', '', 'output');

      expect(workflow['2']['class_type'], 'UpscaleModelLoader');
      expect(workflow['3']['class_type'], 'ImageUpscaleWithModel');
    });

    test('does not use non-existent UpscaleImage node', () {
      final workflow = ComfyWorkflow.upscale('test.png', '', 'output');

      for (final node in workflow.values) {
        expect((node as Map<String, dynamic>)['class_type'], isNot('UpscaleImage'));
      }
    });

    test('wires upscale model loader into ImageUpscaleWithModel', () {
      final workflow = ComfyWorkflow.upscale('test.png', '', 'output',
          model: '4x_NMKD-Siax_200k.pth');

      final loaderInputs = workflow['2']['inputs'] as Map<String, dynamic>;
      expect(loaderInputs['model_name'], '4x_NMKD-Siax_200k.pth');

      final upscaleInputs = workflow['3']['inputs'] as Map<String, dynamic>;
      expect(upscaleInputs['upscale_model'], ['2', 0]);
      expect(upscaleInputs['image'], ['1', 0]);
    });

    test('skips ImageScaleBy when scale matches model native scale', () {
      final workflow = ComfyWorkflow.upscale('test.png', '', 'output',
          model: '4x_NMKD-Siax_200k.pth', scale: 4.0);

      expect(workflow['4']['class_type'], 'SaveImage');
      final saveInputs = workflow['4']['inputs'] as Map<String, dynamic>;
      expect(saveInputs['images'], ['3', 0]);
    });

    test('adds ImageScaleBy when scale differs from model native scale', () {
      final workflow = ComfyWorkflow.upscale('test.png', '', 'output',
          model: '4x_NMKD-Siax_200k.pth', scale: 2.0);

      expect(workflow['4']['class_type'], 'ImageScaleBy');
      final scaleInputs = workflow['4']['inputs'] as Map<String, dynamic>;
      expect(scaleInputs['scale_by'], 0.5);
      expect(scaleInputs['image'], ['3', 0]);

      expect(workflow['5']['class_type'], 'SaveImage');
      final saveInputs = workflow['5']['inputs'] as Map<String, dynamic>;
      expect(saveInputs['images'], ['4', 0]);
    });
  });
}
