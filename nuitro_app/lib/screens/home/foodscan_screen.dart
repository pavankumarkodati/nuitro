import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nuitro/models/api_reponse.dart';
import 'package:nuitro/providers/auth_provider.dart';
import 'package:nuitro/services/api_helper.dart';
import 'package:nuitro/services/services.dart';

import 'package:nuitro/home/Notifications/barcode_scan_result.dart';
import 'package:nuitro/home/Notifications/logs.dart';
import 'package:nuitro/home/Notifications/manual_log.dart';
import 'package:nuitro/home/Notifications/nutrition_card.dart';
import 'package:nuitro/home/Notifications/scan_result.dart';
import 'package:nuitro/home/Notifications/voice_log.dart';
import 'package:nuitro/home/Notifications/voice_scan_result.dart';
import 'package:nuitro/providers/scan_workflow_provider.dart';

class FoodScanScreen extends StatefulWidget {
  const FoodScanScreen ({Key? key}) : super(key: key);

  @override
  State<FoodScanScreen> createState() => _FoodScanScreenState();
}

class _FoodScanScreenState extends State<FoodScanScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  int selectedIndex = 0;
  bool _isProcessingCapture = false;
  String? _cameraError;
  final VoiceLogController _voiceLogController = VoiceLogController();

  final List<String> buttons = [
    "AI Scan",
    "AI Barcode",
    "Manual Log",
    "Voice Log",
    "Logs",
  ];
  final List<String> buttonlogo = [
    'assets/images/camera.png' ,
    'assets/images/AI Barcode.png',
    'assets/images/Manual Log.png',
    'assets/images/Voice Log.png'
    ,'assets/images/Log.png'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<UserProvider>().ensureInitialized();
      await ApiHelper.ensureFreshAccessToken();
    });
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint("No camera available on this device");
        setState(() {
          _cameraError = "No camera available on this device.";
          _controller = null;
          _initializeControllerFuture = null;
        });
        return;
      }

      final firstCamera = cameras.first;
      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;
      if (!mounted) return;
      setState(() {
        _cameraError = null;
      });
    } catch (e) {
      debugPrint("Camera initialization failed: $e");
      if (!mounted) return;
      setState(() {
        _cameraError = "Camera is unavailable. Please check permissions and try again.";
        _controller = null;
        _initializeControllerFuture = null;
      });
    }
  }

  Future<void> _handleCapture(BuildContext context) async {
    if (_isProcessingCapture) {
      return;
    }

    final workflow = context.read<ScanWorkflowProvider>();
    setState(() {
      _isProcessingCapture = true;
    });

    ApiResponse? response;

    try {
      if (selectedIndex == 0 || selectedIndex == 1) {
        if (_controller == null || _initializeControllerFuture == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera not ready'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await _initializeControllerFuture;
        if (!mounted) return;
        if (!(_controller?.value.isInitialized ?? false)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera failed to initialize'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await ApiHelper.ensureFreshAccessToken();
        final image = await _controller!.takePicture();

        if (selectedIndex == 0) {
          response = await ApiServices.uploadImage(image);
          if (response.status && mounted) {
            final data = response.data;
            if (data is Map<String, dynamic>) {
              final bool? shouldClose = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => ScanResult(
                    responseDataRaw: data,
                    capturedImagePath: image.path,
                  ),
                ),
              );
              if (shouldClose == true && mounted) {
                Navigator.of(context).pop();
                return;
              }
            }
          }
        } else {
          response = await ApiServices.uploadBarcodeImage(image);
          if (response.status && mounted) {
            final data = response.data;
            if (data is Map<String, dynamic>) {
              final bool? shouldClose = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => BarcodeScanResult(
                    responseDataRaw: data,
                  ),
                ),
              );
              if (shouldClose == true && mounted) {
                Navigator.of(context).pop();
                return;
              }
            }
          }
        }
      } else if (selectedIndex == 2) {
        response = await workflow.captureManual();
        if (response.status && mounted) {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            final bool? shouldClose = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => ScanResult(
                  responseDataRaw: data,
                ),
              ),
            );
            if (shouldClose == true && mounted) {
              Navigator.of(context).pop();
              return;
            }
          }
        }
      } else if (selectedIndex == 3) {
        final voiceText = _voiceLogController.text.trim();
        if (voiceText.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please record something before continuing'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          workflow.setVoiceTranscript(voiceText);
          response = await workflow.predictVoice();
          if (!mounted) {
            return;
          }

          if (response.status) {
            final results = workflow.voiceResults;
            final selected = workflow.voiceSelection ??
                (results.isNotEmpty ? results.first : null);

            if (selected == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No nutrition info found for the recorded prompt'),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              final List<Map<String, dynamic>> predictions = results.isNotEmpty
                  ? results.toList()
                  : [selected];
              final bool? shouldClose = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => VoiceScanResult(
                    spokenText: voiceText,
                    prediction: selected,
                    predictions: predictions,
                  ),
                ),
              );

              if (shouldClose == true && mounted) {
                Navigator.of(context).pop();
                return;
              }
            }
          }
        }
        return;
      } else if (selectedIndex == 4) {
        response = await workflow.captureLogs();
        if (response.status && mounted) {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            final bool? shouldClose = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => ScanResult(
                  responseDataRaw: data,
                ),
              ),
            );
            if (shouldClose == true && mounted) {
              Navigator.of(context).pop();
              return;
            }
          }
        }
      }

      if (response != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: response.status ? null : Colors.red,
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingCapture = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double focusWidth = size.width * 0.7;
    final double focusHeight = size.height * 0.45;

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 230,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(60),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(buttons.length, (index) {
                      final isSelected = selectedIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: Container(
                          height: 48,
                          width: 70,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? const Color.fromRGBO(220, 250, 157, 1)
                                  : Colors.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.black,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                buttonlogo[index],
                                color: isSelected
                                    ? const Color.fromRGBO(220, 250, 157, 1)
                                    : Colors.grey,
                              ),
                              Text(
                                buttons[index],
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color.fromRGBO(220, 250, 157, 1)
                                      : Colors.white,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              if (selectedIndex != 2)
                GestureDetector(
                  onTap: () => _handleCapture(context),
                  child: Container(
                    padding: EdgeInsets.all(size.width * 0.009),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color.fromRGBO(220, 250, 157, 1),
                          width: 3),
                    ),
                    child: Container(
                      width: size.width * 0.13,
                      height: size.width * 0.13,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromRGBO(220, 250, 157, 1),
                      ),
                      child: _isProcessingCapture
                          ? Center(
                              child: SizedBox(
                                width: size.width * 0.06,
                                height: size.width * 0.06,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.black),
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      body: selectedIndex == 2
          ? ManualLog()
          : selectedIndex == 3
              ? VoiceLog(controller: _voiceLogController)
              : selectedIndex == 4
                  ? Logs()
                  : (_cameraError != null)
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.no_photography, size: 64, color: Colors.white70),
                    const SizedBox(height: 16),
                    Text(
                      _cameraError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _cameraError = null;
                        });
                        _initCamera();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : _controller == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // Camera preview
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

          // Blur overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(


                  color:  selectedIndex == 1 ?Colors.black.withOpacity(0.2): Colors.white.withOpacity(0.2)),
            ),
          ),

          // Focused rectangle with live preview
         Align(alignment: Alignment(0, 0.5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: focusWidth,
                height: focusHeight,
                child: FutureBuilder(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.done) {
                      return CameraPreview(_controller!);
                    } else {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),
          ),

          // White corners
          Align(alignment: Alignment(0, 0.5),
            child: SizedBox(
              width: focusWidth,
              height: focusHeight,
              child: CustomPaint(painter: CornerPainter()),
            ),
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                     selectedIndex == 1 ? "Barcode Scanner" : "AI Camera",
                     style: TextStyle(
                       color: selectedIndex == 1 ? Colors.white : Colors.black,
                       fontSize: 20,
                       fontWeight: FontWeight.w600,
                     ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child:

                    Container(decoration:BoxDecoration(
                        color:Color.fromRGBO(35, 34, 32, 1),
                        shape: BoxShape.circle),child:
                    Padding(padding:EdgeInsets.all(10),child:
                    const Icon(Icons.close, color: Colors.white))),
                  ),
                ],
              ),
            ),
          ),

          // Bottom buttons + capture button

        ],
      ),
    );
  }
}

class CornerPainter extends CustomPainter {
  final double radius;          // how round the corner curve is
  final double horizontalLength; // length of horizontal lines
  final double verticalLength;   // length of vertical lines
  final double strokeWidth;
  final Color color;

  CornerPainter({
    this.radius = 20,
    this.horizontalLength = 60, // smaller than vertical
    this.verticalLength = 120,  // longer than horizontal
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
    canvas.drawLine(Offset(0, radius), Offset(0, verticalLength), paint);   // vertical
    canvas.drawArc(
      Rect.fromLTWH(0, 0, radius * 2, radius * 2),
      3.1416, 1.5708, false, paint,
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
      -1.5708, 1.5708, false, paint,
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
      1.5708, 1.5708, false, paint,
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
      0, 1.5708, false, paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}





