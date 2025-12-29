import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:nuitro/screens/weight/weight_scan_result.dart';

class WeightScanning extends StatefulWidget {
  const WeightScanning({Key? key}) : super(key: key);

  @override
  State<WeightScanning> createState() => _WeightScanningState();
}

class _WeightScanningState extends State<WeightScanning> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  final List<XFile> _photos = []; // keep last photos (max 5)

  // Move the focus box a bit higher so it doesn't sit too low on the screen
  final double focusVerticalAlign = -0.12;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final firstCamera = cameras.first;

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;
      setState(() {});
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      if (_initializeControllerFuture == null) return;
      await _initializeControllerFuture;
      if (!mounted || _controller == null || !_controller!.value.isInitialized) return;

      final image = await _controller!.takePicture();

      setState(() {
        // insert at start (leftmost). keep only last 5.
        _photos.insert(0, image);
        if (_photos.length > 5) _photos.removeLast();
      });

      debugPrint("Picture saved to ${image.path}");
    } catch (e) {
      debugPrint("Error taking picture: $e");
    }
  }

  void _submitPhotos() {
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No photos to submit")),
      );
      return;
    }
    // TODO: handle submission (e.g., upload to server)
    debugPrint("Submitting ${_photos.length} photos...");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${_photos.length} photos submitted!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double focusWidth = size.width * 0.7;
    final double focusHeight = size.height * 0.45;

    return Scaffold(
      backgroundColor: Colors.black,

      // Bottom black container restored (height similar to your original)
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 230,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Thumbnails row (max 5). Newest on the left.
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    if (index < _photos.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_photos[index].path),
                            width: 70,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    } else {
                      // placeholder for empty slots
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Container(
                          width: 60,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade700),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white30,
                            size: 30,
                          ),
                        ),
                      );
                    }
                  }),
                ),
              ),

              // Capture button centered
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: GestureDetector(
                  onTap: _takePicture,
                  child: Container(
                    padding: EdgeInsets.all(size.width * 0.009),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color.fromRGBO(220, 250, 157, 1), width: 3),
                    ),
                    child: Container(
                      width: size.width * 0.13,
                      height: size.width * 0.13,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromRGBO(220, 250, 157, 1),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Main camera view
      body: _controller == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // Fullscreen blurred camera preview (acts as background)
          Positioned.fill(
            child: FutureBuilder(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller!);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),

          // Blur overlay so only the focus box looks clear above it
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.white.withOpacity(0.25)),
            ),
          ),

          // Focused rectangle with live preview (clear)
          Align(
            alignment: Alignment(0, focusVerticalAlign),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: focusWidth,
                height: focusHeight,
                child: FutureBuilder(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return CameraPreview(_controller!);
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),
          ),

          // White corner decoration around the focused box
          Align(
            alignment: Alignment(0, focusVerticalAlign),
            child: SizedBox(
              width: focusWidth,
              height: focusHeight,
              child: CustomPaint(painter: CornerPainter()),
            ),
          ),

          // Submit button above black container (right side)
          Positioned(
            right: 20,
            bottom: 10, // just above black container
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Color.fromRGBO(220, 250, 157, 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: GestureDetector(
                onTap: () {
                  _submitPhotos(); // your existing function

                  // Navigate to next page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeightScanResult(), // replace with your page
                    ),
                  );
                },

                child: const Text(
                  "Submit",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // Top bar (title + close)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "AI Camera",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(35, 34, 32, 1),
                        shape: BoxShape.circle,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CornerPainter extends CustomPainter {
  final double radius; // how round the corner curve is
  final double horizontalLength; // length of horizontal lines
  final double verticalLength; // length of vertical lines
  final double strokeWidth;
  final Color color;

  CornerPainter({
    this.radius = 20,
    this.horizontalLength = 60, // smaller than vertical
    this.verticalLength = 120, // longer than horizontal
    this.strokeWidth = 3,
    this.color = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(Offset(radius, 0), Offset(horizontalLength, 0), paint); // horizontal
    canvas.drawLine(Offset(0, radius), Offset(0, verticalLength), paint); // vertical
    canvas.drawArc(
      Rect.fromLTWH(0, 0, radius * 2, radius * 2),
      3.1416,
      1.5708,
      false,
      paint,
    );

    // Top-right
    canvas.drawLine(
      Offset(size.width - horizontalLength, 0),
      Offset(size.width - radius, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, radius),
      Offset(size.width, verticalLength),
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(size.width - radius * 2, 0, radius * 2, radius * 2),
      -1.5708,
      1.5708,
      false,
      paint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(0, size.height - verticalLength),
      Offset(0, size.height - radius),
      paint,
    );
    canvas.drawLine(
      Offset(radius, size.height),
      Offset(horizontalLength, size.height),
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(0, size.height - radius * 2, radius * 2, radius * 2),
      1.5708,
      1.5708,
      false,
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(size.width - horizontalLength, size.height),
      Offset(size.width - radius, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height - verticalLength),
      Offset(size.width, size.height - radius),
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(size.width - radius * 2, size.height - radius * 2, radius * 2, radius * 2),
      0,
      1.5708,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
