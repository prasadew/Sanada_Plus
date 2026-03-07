import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../chat/providers/chat_provider.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  final String otherUserId;
  const VideoCallScreen({super.key, required this.otherUserId});

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isFrontCamera = true;
  bool _isMuted = false;
  bool _isCameraOff = false;
  final Stopwatch _callTimer = Stopwatch();
  late Stream<int> _timerStream;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _callTimer.start();
    _timerStream = Stream.periodic(const Duration(seconds: 1), (i) => i + 1);
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      // Start with front camera
      final frontCamera = _cameras!.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );
      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
      );
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    _isFrontCamera = !_isFrontCamera;
    final camera = _cameras!.firstWhere(
      (c) => c.lensDirection ==
          (_isFrontCamera
              ? CameraLensDirection.front
              : CameraLensDirection.back),
      orElse: () => _cameras!.first,
    );

    await _controller?.dispose();
    _controller = CameraController(camera, ResolutionPreset.medium);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
  }

  void _toggleCamera() {
    setState(() => _isCameraOff = !_isCameraOff);
  }

  void _endCall() {
    _callTimer.stop();
    context.pop();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _controller?.dispose();
    _callTimer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userDataProvider(widget.otherUserId));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Remote video placeholder (full screen) ──────
          Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.darkBrown,
            child: userAsync.when(
              data: (user) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.darkSurface,
                    backgroundImage: user.profilePic.isNotEmpty
                        ? CachedNetworkImageProvider(user.profilePic)
                        : null,
                    child: user.profilePic.isEmpty
                        ? const Icon(Icons.person_rounded,
                            size: 60, color: AppColors.warmGray)
                        : null,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<int>(
                    stream: _timerStream,
                    builder: (_, snap) {
                      final seconds = _callTimer.elapsed.inSeconds;
                      return Text(
                        _formatDuration(seconds),
                        style: const TextStyle(
                          color: AppColors.warmGray,
                          fontSize: 16,
                        ),
                      );
                    },
                  ),
                ],
              ),
              loading: () =>
                  const Center(child: CircularProgressIndicator(color: Colors.white)),
              error: (_, __) => const Center(
                child: Text('User not found',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ),

          // ── Local camera preview (PiP) ─────────────────
          if (_isInitialized && !_isCameraOff && _controller != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 120,
                  height: 160,
                  child: CameraPreview(_controller!),
                ),
              ),
            ),

          // ── Top bar ────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 28),
                    onPressed: _endCall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.cameraswitch_rounded,
                        color: Colors.white, size: 28),
                    onPressed: _switchCamera,
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom controls ────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 24,
                top: 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute
                  _controlButton(
                    icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    label: _isMuted ? 'Unmute' : 'Mute',
                    onTap: _toggleMute,
                    isActive: _isMuted,
                  ),
                  // End call
                  GestureDetector(
                    onTap: _endCall,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.call_end_rounded,
                          color: Colors.white, size: 32),
                    ),
                  ),
                  // Camera toggle
                  _controlButton(
                    icon: _isCameraOff
                        ? Icons.videocam_off_rounded
                        : Icons.videocam_rounded,
                    label: _isCameraOff ? 'Camera On' : 'Camera Off',
                    onTap: _toggleCamera,
                    isActive: _isCameraOff,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withOpacity(0.3)
                  : Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
