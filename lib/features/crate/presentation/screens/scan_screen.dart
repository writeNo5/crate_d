import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/ai_vision_service.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/models/vinyl.dart';
import 'package:provider/provider.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isAnalyzing = false;
  bool _hasError = false;
  String _errorMessage = '';
  
  final AiVisionService _aiService = AiVisionService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // Try to find the back camera first
    CameraDescription? backCamera;
    for (var camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.back) {
        backCamera = camera;
        break;
      }
    }

    _controller = CameraController(
      backCamera ?? cameras.first, // Fallback to first if back camera not found
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to access camera. Please check permissions.';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePictureAndAnalyze() async {
    if (_isAnalyzing) return;

    setState(() => _isAnalyzing = true);

    try {
      XFile? image;
      
      // 1. Capture Image or Use Fallback Image
      if (_controller != null && _controller!.value.isInitialized) {
        image = await _controller!.takePicture();
      } else {
        // Fallback for Web/Emulator testing without real camera
        debugPrint('Camera not available. Using fallback demo image.');
        await Future.delayed(const Duration(seconds: 1)); // Simulate capture delay
        
        // This won't create a real local file on web, but we can pass it to the service if we change its signature or use a known image.
        // For web compatibility we'll pass a dummy path that AiVisionService handles or pass bytes directly.
        image = XFile('assets/images/jazz.png');
      }
      
      // 2. AI Analysis
      final result = await _aiService.analyzeVinylCover(image);

      // 3. Result Handing
      if (mounted) {
        if (result != null) {
          _showResultDialog(image!, result);
        } else {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Analysis Failed'),
              content: const Text('Could not analyze the image. Please verify your GEMINI_API_KEY in the .env file and ensure you are connected to the network.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error taking picture/analyzing: $e');
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  void _showResultDialog(XFile image, AiAnalysisResult result) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return ScaleTransition(
          scale: curvedAnimation,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: AppColors.aqua.withValues(alpha: 0.3)),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'AI ANALYSIS COMPLETE',
                          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, color: AppColors.aqua),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child: Image.network(image.path, fit: BoxFit.cover, errorBuilder: (c, e, s) => Image.asset('assets/images/jazz.png', fit: BoxFit.cover)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    result.title,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    result.artist,
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    r'Market Value: $--.--', // Discogs API placeholder
                                    style: TextStyle(color: AppColors.aqua, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Genre: ${result.genre}',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  ),
                                  Text(
                                    'Released: ${result.year > 0 ? result.year : "Unknown"}',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () {
                            // Stage 5 Data Layer Integration
                            final newVinyl = Vinyl(
                              title: result.title,
                              artist: result.artist,
                              genre: result.genre,
                              year: result.year,
                              coverUrl: 'assets/images/jazz.png', // Temporary local image
                            );
                            
                            context.read<CollectionProvider>().addVinyl(newVinyl);
                            
                            Navigator.pop(context); // Close Dialog
                            Navigator.pop(context); // Go back from ScanScreen
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.aqua,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('ADD TO MY CRATE', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('RE-SCAN', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview or Fallback
          if (_hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videocam_off_outlined, color: AppColors.error, size: 64),
                  const SizedBox(height: 16),
                  Text(_errorMessage, style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            )
          else if (_isInitialized && _controller != null)
            Center(
              child: AspectRatio(
                aspectRatio: 1 / _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              ),
            )
          else
            // Fallback Preview for Web
            Center(
              child: Opacity(
                opacity: 0.5,
                child: Image.asset('assets/images/jazz.png', fit: BoxFit.cover),
              ),
            ),

          // Glassmorphism Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.5),
                  width: 40,
                ),
              ),
              child: Center(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.aqua.withValues(alpha: 0.5), width: 2),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.aqua.withValues(alpha: 0.1),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Header
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'POSITION VINYL COVER',
                style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
            ),
          ),

          // Analysis Animation (Neon Scan Line)
          if (_isAnalyzing)
            const ScanningAnimation(),

          // Capture Button
          if (!_isAnalyzing)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _takePictureAndAnalyze,
                  child: Container(
                    width: 80,
                    height: 80,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ScanningAnimation extends StatefulWidget {
  const ScanningAnimation({super.key});

  @override
  State<ScanningAnimation> createState() => _ScanningAnimationState();
}

class _ScanningAnimationState extends State<ScanningAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Positioned(
          top: 300 + (_animController.value * 200), // Scanning range
          left: 50,
          right: 50,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.aqua,
              boxShadow: [
                BoxShadow(
                  color: AppColors.aqua,
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
