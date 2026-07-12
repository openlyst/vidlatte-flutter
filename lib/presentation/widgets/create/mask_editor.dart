import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MaskEditor extends StatefulWidget {
  final Uint8List imageBytes;
  final double brushSize;
  final bool isEraser;
  final GlobalKey<MaskEditorState> exportKey;

  const MaskEditor({
    super.key,
    required this.imageBytes,
    this.brushSize = 30,
    this.isEraser = false,
    required this.exportKey,
  });

  @override
  State<MaskEditor> createState() => MaskEditorState();
}

class MaskEditorState extends State<MaskEditor> {
  final List<Offset> _points = [];
  final List<List<Offset>> _strokes = [];
  ui.Image? _image;
  Size _imageSize = Size.zero;
  final _repaintNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() async {
    final codec = await ui.instantiateImageCodec(widget.imageBytes);
    final frame = await codec.getNextFrame();
    setState(() {
      _image = frame.image;
      _imageSize = Size(_image!.width.toDouble(), _image!.height.toDouble());
    });
  }

  void clearMask() {
    _strokes.clear();
    _repaintNotifier.notifyListeners();
  }

  Future<Uint8List> exportMask() async {
    if (_image == null) {
      debugPrint('[mask] exportMask called before image loaded');
      return Uint8List(0);
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawRect(Offset.zero & _imageSize, Paint()..color = Colors.black);

    final paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = widget.brushSize
      ..blendMode = widget.isEraser ? BlendMode.clear : BlendMode.srcOver;

    for (final stroke in _strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(_image!.width, _image!.height);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      debugPrint('[mask] toByteData returned null');
      return Uint8List(0);
    }
    return byteData.buffer.asUint8List();
  }

  Offset _toImageCoords(Offset localPos, Size widgetSize) {
    final scale = _imageSize.width / widgetSize.width;
    return Offset(localPos.dx * scale, localPos.dy * scale);
  }

  @override
  Widget build(BuildContext context) {
    if (_image == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final displayWidth = constraints.maxWidth;
        final displayHeight = _imageSize.height * (displayWidth / _imageSize.width);

        return Column(
          children: [
            SizedBox(
              width: displayWidth,
              height: displayHeight,
              child: GestureDetector(
                onPanStart: (details) {
                  _points.clear();
                  _points.add(_toImageCoords(details.localPosition, Size(displayWidth, displayHeight)));
                  _strokes.add(List.from(_points));
                },
                onPanUpdate: (details) {
                  final point = _toImageCoords(details.localPosition, Size(displayWidth, displayHeight));
                  _points.add(point);
                  _strokes.last.add(point);
                  _repaintNotifier.notifyListeners();
                },
                onPanEnd: (_) {
                  _repaintNotifier.notifyListeners();
                },
                child: ClipRect(
                  child: CustomPaint(
                    painter: _MaskPainter(
                      image: _image!,
                      strokes: _strokes,
                      brushSize: widget.brushSize,
                      isEraser: widget.isEraser,
                      repaintNotifier: _repaintNotifier,
                    ),
                    size: Size(displayWidth, displayHeight),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MaskPainter extends CustomPainter {
  final ui.Image image;
  final List<List<Offset>> strokes;
  final double brushSize;
  final bool isEraser;
  final ValueNotifier<int> repaintNotifier;

  _MaskPainter({
    required this.image,
    required this.strokes,
    required this.brushSize,
    required this.isEraser,
    required this.repaintNotifier,
  }) : super(repaint: repaintNotifier);

  @override
  void paint(Canvas canvas, Size size) {
    final imageScale = size.width / image.width.toDouble();
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );

    final maskPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.5)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = brushSize * imageScale;

    for (final stroke in strokes) {
      if (stroke.length < 2) {
        canvas.drawPoints(ui.PointMode.points, [stroke.first], maskPaint);
        continue;
      }
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(
          Offset(stroke[i].dx * imageScale, stroke[i].dy * imageScale),
          Offset(stroke[i + 1].dx * imageScale, stroke[i + 1].dy * imageScale),
          maskPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MaskPainter oldDelegate) => false;
}
