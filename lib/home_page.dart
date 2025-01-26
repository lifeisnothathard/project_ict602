import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:html'; // For web download handling
import 'dart:typed_data'; // For Uint8List

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HomePage({Key? key, required this.cameras}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CameraController? cameraController;
  Uint8List? imageBytes; // For storing the captured image bytes
  String selectedFrame = 'None'; // To store the selected frame design
  bool _isLoading = false; // For managing loading state

  @override
  void initState() {
    super.initState();
    setupCameraController();
  }

  // Initialize the camera controller
  Future<void> setupCameraController() async {
    try {
      if (widget.cameras.isNotEmpty) {
        setState(() {
          _isLoading = true;
        });
        cameraController = CameraController(
          widget.cameras.first,
          ResolutionPreset.high,
        );
        await cameraController!.initialize();
        setState(() {
          _isLoading = false;
        });
      } else {
        showError("No cameras are available.");
      }
    } catch (e) {
      showError("Error initializing the camera: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show error dialog
  void showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  // Capture the image and convert it to bytes for web
  Future<void> takePicture() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      showError("Camera is not initialized.");
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });
      final XFile file = await cameraController!.takePicture();
      final Uint8List bytes = await file.readAsBytes();
      setState(() {
        imageBytes = bytes;
        _isLoading = false;
      });

      // Debug: Print confirmation that imageBytes is set
      print("Image captured and imageBytes set: ${imageBytes != null}");
    } catch (e) {
      showError("Error capturing the image: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show frame options
  void showFrameOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Choose Frame"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("None"),
              onTap: () {
                setState(() {
                  selectedFrame = 'None';
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text("Gold Frame"),
              onTap: () {
                setState(() {
                  selectedFrame = 'Gold';
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text("Wooden Frame"),
              onTap: () {
                setState(() {
                  selectedFrame = 'Wooden';
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Apply the selected frame to the image
  Widget applyFrame(Uint8List imageBytes) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: selectedFrame == 'Gold'
              ? Colors.yellow
              : selectedFrame == 'Wooden'
                  ? Colors.brown
                  : Colors.transparent,
          width: selectedFrame == 'Gold' ? 5 : 8,
        ),
      ),
      child: Image.memory(
        imageBytes,
        width: 200,
        height: 200,
        fit: BoxFit.cover,
      ),
    );
  }

  // Save the image by triggering a download in the browser
  void saveImage() {
    if (imageBytes == null) {
      showError("No image to save.");
      return;
    }

    // Debug: Print confirmation that saveImage is called
    print("Save Image button pressed");

    // Create a Blob URL for the image and trigger download
    final blob = Blob([imageBytes!]);
    final url = Url.createObjectUrlFromBlob(blob);
    final anchor = AnchorElement(href: url)
      ..target = 'blank'
      ..download = 'captured_image.jpg'
      ..click();
    Url.revokeObjectUrl(url); // Free up memory
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : cameraController == null || !cameraController!.value.isInitialized
              ? const Center(child: Text("Camera not initialized"))
              : SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: CameraPreview(cameraController!),
                      ),
                      const SizedBox(height: 16),
                      IconButton(
                        icon: const Icon(Icons.camera_alt, size: 40),
                        onPressed: takePicture,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: showFrameOptions,
                        child: const Text("Choose Frame"),
                      ),
                      const SizedBox(height: 16),
                      if (imageBytes != null) ...[
                        applyFrame(imageBytes!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: saveImage,
                          child: const Text("Save Image"),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}
