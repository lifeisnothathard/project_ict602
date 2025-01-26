import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'home_page.dart'; // Import your home_page.dart file

List<CameraDescription>? cameras; // Global list of available cameras

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras(); // Fetch the list of available cameras
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const StartPage(), // Start with the Start Page
    );
  }
}

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome to the Camera App",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  if (cameras != null && cameras!.isNotEmpty) {
                    // Only navigate to HomePage if cameras are available
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePageWrapper(cameras: cameras!),
                      ),
                    );
                  } else {
                    // Show error if no cameras are available
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Error"),
                        content: const Text("No cameras available on this device."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Close"),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: const Text("Start"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePageWrapper extends StatelessWidget {
  final List<CameraDescription> cameras;

  const HomePageWrapper({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return HomePage(cameras: cameras); // Pass cameras to HomePage
  }
}
