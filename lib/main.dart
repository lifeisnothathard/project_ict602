import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'home_page.dart'; // Import your home_page.dart file
import 'login.dart'; // Import your login.dart file

List<CameraDescription>? cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: '/login', // Set login as the initial screen
      routes: {
        '/login': (context) => const LoginPage(), // Login screen route
        '/home': (context) => HomePageWrapper(cameras: cameras!), // HomePage route
      },
    );
  }
}

class HomePageWrapper extends StatelessWidget {
  final List<CameraDescription> cameras;

  const HomePageWrapper({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return const HomePage(); // Use HomePage for the main camera functionality
  }
}
