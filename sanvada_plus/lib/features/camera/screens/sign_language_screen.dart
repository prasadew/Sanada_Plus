import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../services/sign_classifier_service.dart';

class SignLanguageScreen extends StatefulWidget {
  const SignLanguageScreen({
    super.key,
    required this.finalText,
    required this.onSendText,
  });

  final String finalText;
  final ValueChanged<String> onSendText;

  @override
  State<SignLanguageScreen> createState() => _SignLanguageScreenState();
}

class _SignLanguageScreenState extends State<SignLanguageScreen> {
  static const double _minConfidence = 0.45;
  static const double _allowAddConfidence = 0.20;
  static const Duration _inferenceInterval = Duration(seconds: 2);

  final SignClassifierService _classifier = SignClassifierService();
  final TextEditingController _finalTextController = TextEditingController();

  CameraController? _cameraController;
  List<CameraDescription> _cameras = <CameraDescription>[];
  int _cameraIndex = 0;
  bool _isInitializing = true;
  bool _isStreaming = false;
  bool _isRunningInference = false;
  bool _isClosing = false;
  DateTime _lastInferenceAt = DateTime.fromMillisecondsSinceEpoch(0);
  SignPrediction? _latestPrediction;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _finalTextController.text = widget.finalText;
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      await _classifier.load();
      await _initCamera();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      throw SignClassifierException('No camera found on this device.');
    }

    final preferredBackIndex = _cameras.indexWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );
    _cameraIndex = preferredBackIndex >= 0 ? preferredBackIndex : 0;

    await _startCamera(_cameraIndex);
  }

  Future<void> _startCamera(int index) async {
    await _stopCameraStream();
    await _cameraController?.dispose();

    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    _cameraController = controller;

    try {
      await controller.initialize();
      await controller.startImageStream(_onFrame);
      _isStreaming = true;
    } catch (e) {
      throw SignClassifierException('Failed to initialize camera stream. $e');
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_isClosing ||
        _isRunningInference ||
        DateTime.now().difference(_lastInferenceAt) < _inferenceInterval) {
      return;
    }

    _isRunningInference = true;
    _lastInferenceAt = DateTime.now();

    try {
      final prediction = await _classifier.classifyFrame(image);
      if (!mounted) return;

      setState(() {
        _latestPrediction = prediction;
      });
    } catch (e) {
      if (!mounted) return;
      final rawMessage = e.toString();
      final lowerMessage = rawMessage.toLowerCase();
      final friendlyMessage =
          lowerMessage.contains('failed precondition')
              ? 'Model inference failed due to a temporary precondition issue. Please retry or reopen this screen.'
              : rawMessage;
      setState(() {
        _errorMessage = friendlyMessage;
      });
    } finally {
      _isRunningInference = false;
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length < 2 || _isInitializing) return;

    final nextIndex = (_cameraIndex + 1) % _cameras.length;
    setState(() {
      _cameraIndex = nextIndex;
    });

    try {
      await _startCamera(nextIndex);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  void _addLetter() {
    final prediction = _latestPrediction;
    if (prediction == null || prediction.confidence < _allowAddConfidence) {
      _showSnack('Hold sign clearly');
      return;
    }

    final current = _finalTextController.text;
    _finalTextController.text = '$current${prediction.sinhalaLabel}';
    if (prediction.confidence < _minConfidence) {
      _showSnack('Added with low confidence. Keep hand steady for better accuracy.');
    }
    setState(() {});
  }

  void _clearText() {
    _finalTextController.clear();
    setState(() {});
  }

  void _sendMessage() {
    final message = _finalTextController.text.trim();
    if (message.isEmpty) {
      _showSnack('Type or add at least one letter');
      return;
    }

    widget.onSendText(message);
    _finalTextController.clear();
    setState(() {});
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _stopCameraStream() async {
    final controller = _cameraController;
    if (controller == null) return;

    if (controller.value.isStreamingImages) {
      await controller.stopImageStream();
    }
    _isStreaming = false;
  }

  @override
  void dispose() {
    _isClosing = true;
    _stopCameraStream();
    _cameraController?.dispose();
    _classifier.dispose();
    _finalTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prediction = _latestPrediction;
    final confidence = prediction?.confidence ?? 0;
    final hasGoodConfidence = confidence >= _minConfidence;
    final displayText = hasGoodConfidence
        ? (prediction?.sinhalaLabel ?? '-')
        : 'Hold sign clearly';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sinhala Sign to Text'),
      ),
      body: SafeArea(
        child: _isInitializing
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null && _cameraController == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _initialize,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        flex: 5,
                        child: _cameraController != null &&
                                _cameraController!.value.isInitialized
                            ? Stack(
                                children: [
                                  Positioned.fill(
                                    child: CameraPreview(_cameraController!),
                                  ),
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: IconButton.filled(
                                      onPressed: _toggleCamera,
                                      icon: const Icon(Icons.cameraswitch),
                                    ),
                                  ),
                                ],
                              )
                            : const Center(child: CircularProgressIndicator()),
                      ),
                      Expanded(
                        flex: 4,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Detected Character',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        displayText,
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                                      ),
                                      if (prediction != null)
                                        Text('Label: ${prediction.englishLabel}'),
                                      if (_errorMessage != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Text(
                                            _errorMessage!,
                                            style: const TextStyle(
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _finalTextController,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: 'Current Composed Text',
                                  border: OutlineInputBorder(),
                                ),
                                minLines: 2,
                                maxLines: 3,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _isStreaming ? _addLetter : null,
                                      child: const Text('Add Letter'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _clearText,
                                      child: const Text('Clear'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _sendMessage,
                                      child: const Text('Send Message'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
