import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io'; // for file handling

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HomePage({super.key, required this.cameras}); // Constructor to pass cameras

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CameraController? cameraController;
  XFile? imageFile; // Variable to hold the captured image

  @override
  void initState() {
    super.initState();
    setupCameraController(); // Initialize camera controller
  }

  // Set up camera controller
  Future<void> setupCameraController() async {
    try {
      if (widget.cameras.isNotEmpty) {
        setState(() {
          cameraController = CameraController(
            widget.cameras.first,
            ResolutionPreset.high,
          );
        });
        await cameraController!.initialize();
        setState(() {});
      } else {
        showError("No cameras available on this device.");
      }
    } catch (e) {
      showError("Error initializing the camera: $e");
    }
  }

  // Show error message
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

  // Capture the photo
  Future<void> takePicture() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      showError("Camera is not initialized.");
      return;
    }

    try {
      final XFile file = await cameraController!.takePicture();

      setState(() {
        imageFile = file; // Store the captured image file
      });
    } catch (e) {
      showError("Error capturing the image: $e");
    }
  }

  @override
  void dispose() {
    cameraController?.dispose(); // Dispose the camera when done
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: cameraController == null || !cameraController!.value.isInitialized
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  CameraPreview(cameraController!), // Camera preview
                  const SizedBox(height: 16),
                  // Camera icon button
                  IconButton(
                    icon: const Icon(Icons.camera_alt, size: 40), // Camera icon with size 40
                    onPressed: takePicture, // Capture the photo on press
                    tooltip: "Capture", // Tooltip when user long-presses
                  ),
                  if (imageFile != null) // Display captured image if available
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.file(
                        File(imageFile!.path),
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover, // Image fit for the preview
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras(); // Fetch available cameras
  runApp(MaterialApp(
    home: HomePage(cameras: cameras), // Pass cameras to the HomePage
  ));
}
