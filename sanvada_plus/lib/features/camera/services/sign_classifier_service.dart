import 'dart:convert';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../utils/sinhala_label_mapper.dart';

class SignClassifierException implements Exception {
  final String message;
  SignClassifierException(this.message);

  @override
  String toString() => 'SignClassifierException: $message';
}

class SignPrediction {
  final int classIndex;
  final String englishLabel;
  final String sinhalaLabel;
  final double confidence;

  const SignPrediction({
    required this.classIndex,
    required this.englishLabel,
    required this.sinhalaLabel,
    required this.confidence,
  });
}

class SignClassifierService {
  SignClassifierService({
    this.modelAssetPath = 'assets/ml/sign_model.tflite',
    this.classNamesAssetPath = 'assets/ml/class_names.json',
    this.inputSize = 224,
    this.outputClassCount = 41,
    this.useMobileNetV2Normalization = true,
  });

  final String modelAssetPath;
  final String classNamesAssetPath;
  final int inputSize;
  final int outputClassCount;
  final bool useMobileNetV2Normalization;

  Interpreter? _interpreter;
  List<String> _classNames = <String>[];
  int _resolvedOutputClassCount = 41;
  int _resolvedInputWidth = 224;
  int _resolvedInputHeight = 224;
  bool _expectsUint8Input = false;
  bool _hasUint8Output = false;
  double _outputScale = 1.0;
  int _outputZeroPoint = 0;

  bool get isLoaded => _interpreter != null && _classNames.isNotEmpty;

  Future<void> load() async {
    try {
      _interpreter = await Interpreter.fromAsset(modelAssetPath);
    } catch (e) {
      throw SignClassifierException(
        'Failed to load model at $modelAssetPath. $e',
      );
    }

    try {
      final classNamesRaw = await rootBundle.loadString(classNamesAssetPath);
      final decoded = jsonDecode(classNamesRaw);
      if (decoded is! List) {
        throw SignClassifierException('class_names.json must be a JSON array.');
      }

      _classNames = decoded.map((dynamic e) => e.toString()).toList();
      if (_classNames.isEmpty) {
        throw SignClassifierException('class_names.json is empty.');
      }
    } catch (e) {
      throw SignClassifierException(
        'Failed to load class names at $classNamesAssetPath. $e',
      );
    }

    try {
      final inputTensor = _interpreter!.getInputTensor(0);
      final inputShape = inputTensor.shape;
      if (inputShape.length >= 4) {
        _resolvedInputHeight = inputShape[1];
        _resolvedInputWidth = inputShape[2];
      }
      final inputElementCount =
          inputShape.isEmpty ? 0 : inputShape.reduce((a, b) => a * b);
      _expectsUint8Input =
          inputElementCount > 0 && inputTensor.numBytes() == inputElementCount;

      final outputTensor = _interpreter!.getOutputTensor(0);
      final outputShape = outputTensor.shape;
      if (outputShape.isNotEmpty) {
        _resolvedOutputClassCount = outputShape.last;
      }
      final outputElementCount =
          outputShape.isEmpty ? 0 : outputShape.reduce((a, b) => a * b);
      _hasUint8Output =
          outputElementCount > 0 && outputTensor.numBytes() == outputElementCount;
      _outputScale = outputTensor.params.scale == 0 ? 1.0 : outputTensor.params.scale;
      _outputZeroPoint = outputTensor.params.zeroPoint;
    } catch (_) {
      _resolvedOutputClassCount = outputClassCount;
    }
  }

  Future<SignPrediction> classifyFrame(CameraImage cameraImage) async {
    if (_interpreter == null) {
      throw SignClassifierException('Interpreter is not loaded.');
    }

    final rgbImage = _cameraImageToRgb(cameraImage);
    if (rgbImage == null) {
      throw SignClassifierException(
        'Unsupported camera image format: ${cameraImage.format.group}',
      );
    }

    final cropped = _cropCenterSquare(rgbImage);
    final resized = img.copyResize(
      cropped,
      width: _resolvedInputWidth,
      height: _resolvedInputHeight,
      interpolation: img.Interpolation.linear,
    );

    final output = _hasUint8Output
        ? List<List<int>>.generate(
            1,
            (_) => List<int>.filled(_resolvedOutputClassCount, 0),
          )
        : List<List<double>>.generate(
            1,
            (_) => List<double>.filled(_resolvedOutputClassCount, 0),
          );

    try {
      if (_expectsUint8Input) {
        final inputTensor = _toUint8Input4D(resized);
        _interpreter!.run(inputTensor, output);
      } else {
        final inputTensor = _toFloat32Input4D(resized);
        _interpreter!.run(inputTensor, output);
      }
    } catch (e) {
      throw SignClassifierException(
        'Inference failed. The model input/output state is invalid. $e',
      );
    }

    final probabilities = _extractProbabilities(output);
    final bestIndex = _argMax(probabilities);
    final bestConfidence = probabilities[bestIndex];

    final englishLabel =
        bestIndex < _classNames.length ? _classNames[bestIndex] : 'class_$bestIndex';

    return SignPrediction(
      classIndex: bestIndex,
      englishLabel: englishLabel,
      sinhalaLabel: SinhalaLabelMapper.toSinhala(englishLabel),
      confidence: bestConfidence,
    );
  }

  List<double> _extractProbabilities(Object output) {
    if (output is List<List<double>>) {
      return _normalizeProbabilities(output.first);
    }

    if (output is List<List<int>>) {
      final raw = output.first
          .map((v) => (v - _outputZeroPoint) * _outputScale)
          .toList(growable: false);
      return _normalizeProbabilities(raw);
    }

    throw SignClassifierException('Unsupported output tensor type.');
  }

  List<double> _normalizeProbabilities(List<double> raw) {
    if (raw.isEmpty) return raw;

    final sum = raw.fold<double>(0.0, (a, b) => a + b);
    final looksLikeProbabilities =
        raw.every((v) => v >= 0 && v <= 1.0) && (sum > 0.90 && sum < 1.10);
    if (looksLikeProbabilities) {
      return raw;
    }

    final maxLogit = raw.reduce(math.max);
    final exps = raw.map((v) => math.exp(v - maxLogit)).toList(growable: false);
    final expSum = exps.fold<double>(0.0, (a, b) => a + b);
    if (expSum == 0) return raw;
    return exps.map((v) => v / expSum).toList(growable: false);
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }

  img.Image _cropCenterSquare(img.Image source) {
    final side = math.min(source.width, source.height);
    final left = (source.width - side) ~/ 2;
    final top = (source.height - side) ~/ 2;
    return img.copyCrop(source, x: left, y: top, width: side, height: side);
  }

  List<List<List<List<double>>>> _toFloat32Input4D(img.Image image) {
    final height = image.height;
    final width = image.width;

    final batch = List<List<List<List<double>>>>.generate(
      1,
      (_) => List<List<List<double>>>.generate(
        height,
        (y) => List<List<double>>.generate(
          width,
          (x) {
            final pixel = image.getPixel(x, y);
            final r = pixel.r.toDouble();
            final g = pixel.g.toDouble();
            final b = pixel.b.toDouble();

            if (useMobileNetV2Normalization) {
              return <double>[
                (r / 127.5) - 1.0,
                (g / 127.5) - 1.0,
                (b / 127.5) - 1.0,
              ];
            }

            return <double>[r, g, b];
          },
          growable: false,
        ),
        growable: false,
      ),
      growable: false,
    );

    return batch;
  }

  List<List<List<List<int>>>> _toUint8Input4D(img.Image image) {
    final height = image.height;
    final width = image.width;

    final batch = List<List<List<List<int>>>>.generate(
      1,
      (_) => List<List<List<int>>>.generate(
        height,
        (y) => List<List<int>>.generate(
          width,
          (x) {
            final pixel = image.getPixel(x, y);
            return <int>[pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()];
          },
          growable: false,
        ),
        growable: false,
      ),
      growable: false,
    );

    return batch;
  }

  int _argMax(List<double> values) {
    var maxIndex = 0;
    var maxValue = values.first;

    for (var i = 1; i < values.length; i++) {
      if (values[i] > maxValue) {
        maxValue = values[i];
        maxIndex = i;
      }
    }

    return maxIndex;
  }

  img.Image? _cameraImageToRgb(CameraImage cameraImage) {
    if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
      return _convertBgra8888(cameraImage);
    }

    if (cameraImage.format.group == ImageFormatGroup.yuv420) {
      return _convertYuv420(cameraImage);
    }

    return null;
  }

  img.Image _convertBgra8888(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final result = img.Image(width: width, height: height);
    final bytes = image.planes[0].bytes;
    final bytesPerRow = image.planes[0].bytesPerRow;

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final offset = y * bytesPerRow + x * 4;
        final b = bytes[offset];
        final g = bytes[offset + 1];
        final r = bytes[offset + 2];
        result.setPixelRgb(x, y, r, g, b);
      }
    }

    return result;
  }

  img.Image _convertYuv420(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final result = img.Image(width: width, height: height);

    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final yBytes = yPlane.bytes;
    final uBytes = uPlane.bytes;
    final vBytes = vPlane.bytes;

    final yRowStride = yPlane.bytesPerRow;
    final uvRowStride = uPlane.bytesPerRow;
    final uvPixelStride = uPlane.bytesPerPixel ?? 1;

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final yIndex = y * yRowStride + x;
        final uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

        final yValue = yBytes[yIndex];
        final uValue = uBytes[uvIndex];
        final vValue = vBytes[uvIndex];

        final r = (yValue + 1.402 * (vValue - 128)).round();
        final g = (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128)).round();
        final b = (yValue + 1.772 * (uValue - 128)).round();

        result.setPixelRgb(
          x,
          y,
          r.clamp(0, 255),
          g.clamp(0, 255),
          b.clamp(0, 255),
        );
      }
    }

    return result;
  }
}
