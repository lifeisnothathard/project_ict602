import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras; // Add this field to accept cameras

  const HomePage({super.key, required this.cameras}); // Add this constructor to pass cameras

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CameraController? cameraController;

  @override
  void initState() {
    super.initState();
    setupCameraController(); // Call setupCameraController to initialize the camera
  }

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

  @override
  void dispose() {
    cameraController?.dispose();
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
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text("Capture"),
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
    home: HomePage(cameras: cameras), // Pass the list of cameras here
  ));
}
