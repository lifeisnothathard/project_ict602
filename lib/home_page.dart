import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'dart:html'; // For web download handling
import 'dart:io'; // For mobile file handling
import 'dart:typed_data'; // For web image bytes
import 'package:social_sharing_plus/social_sharing_plus.dart'; // Import the sharing package

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HomePage({super.key, required this.cameras});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CameraController? cameraController;
  XFile? imageFile; // To store the captured image
  String selectedFrame = 'None'; // To store the selected frame design
  bool _isLoading = false; // To manage loading state
  String? savedImagePath; // To store the path of the saved image

  @override
  void initState() {
    super.initState();
    setupCameraController(); // Initialize the camera
  }

  // Set up the camera controller
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
        showError("No cameras available on this device.");
      }
    } catch (e) {
      showError("Error initializing the camera: $e");
      setState(() {
        _isLoading = false;
      });
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

  // Capture the picture
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
      setState(() {
        imageFile = file; // Store the captured image
        _isLoading = false;
      });
    } catch (e) {
      showError("Error capturing the image: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show frame options and let the user select one
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
            // New Frame Options
            ListTile(
              title: const Text("Love Frame"),
              onTap: () {
                setState(() {
                  selectedFrame = 'Love';
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text("Nature Frame"),
              onTap: () {
                setState(() {
                  selectedFrame = 'Nature';
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text("Hello Kitty Frame"),
              onTap: () {
                setState(() {
                  selectedFrame = 'Hello Kitty';
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text("Flower Frame"),
              onTap: () {
                setState(() {
                  selectedFrame = 'Flower';
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Apply frame to the captured image
  Widget applyFrame(XFile image) {
    String frameImagePath = '';
    switch (selectedFrame) {
      case 'Gold':
        frameImagePath = 'assets/gold.png';
        break;
      case 'Wooden':
        frameImagePath = 'assets/wooden.png';
        break;
      case 'Love':
        frameImagePath = 'assets/love.png';
        break;
      case 'Nature':
        frameImagePath = 'assets/nature.png';
        break;
      case 'Hello Kitty':
        frameImagePath = 'assets/hello kitty.png';
        break;
      case 'Flower':
        frameImagePath = 'assets/flower.png';
        break;
      default:
        frameImagePath = '';
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        image: frameImagePath.isNotEmpty
            ? DecorationImage(
                image: AssetImage(frameImagePath),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: FutureBuilder<Uint8List>(
        future: image.readAsBytes(),  // Works for both web and mobile
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              width: 180,
              height: 180,
              fit: BoxFit.cover,
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  // Save the image with the selected frame
  void saveImage() async {
    if (imageFile == null) {
      showError("No image to save.");
      return;
    }

    // Create a Blob URL for the image and trigger download
    final bytes = await imageFile!.readAsBytes();
    final blob = Blob([bytes]);
    final url = Url.createObjectUrlFromBlob(blob);
    final anchor = AnchorElement(href: url)
      ..target = 'blank'
      ..download = 'captured_image.jpg'
      ..click();
    Url.revokeObjectUrl(url); // Free up memory

    // Store the saved image path for sharing
    savedImagePath = url; // Store the URL for sharing
  }

  // Share the saved image
  void shareImage() async {
    if (savedImagePath == null) {
      showError("No image to share.");
      return;
    }

    String content = "Check out this image!";
    List<String> mediaPaths = [savedImagePath!]; // Use the saved image path

    try {
      await SocialSharingPlus.shareToSocialMediaWithMultipleMedia(
        SocialPlatform.facebook, // Change to desired platform
        media: mediaPaths,
        content: content,
        isOpenBrowser: false,
        onAppNotInstalled: () {
          // Handle app not installed case
        },
      );
      // Show success message
      print("Image shared successfully!");
    } catch (e) {
      // Handle error
      showError("Error sharing image: $e");
    }
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
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            )
          : cameraController == null || !cameraController!.value.isInitialized
              ? const Center(
                  child: Text("Camera not initialized"),
                )
              : SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: CameraPreview(cameraController!), // Camera preview
                      ),
                      const SizedBox(height: 16),
                      // Camera icon button
                      IconButton(
                        icon: const Icon(Icons.camera_alt, size: 40), // Camera icon
                        onPressed: takePicture, // Capture photo on press
                        tooltip: "Capture", // Tooltip
                      ),
                      const SizedBox(height: 16),
                      // Button to select the frame
                      ElevatedButton(
                        onPressed: showFrameOptions, // Show frame options dialog
                        child: const Text("Choose Frame"),
                      ),
                      const SizedBox(height: 16),
                      if (imageFile != null) ...[
                        applyFrame(imageFile!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: saveImage,
                          child: const Text("Save Image"),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: shareImage, // Share image button
                          child: const Text("Share Image"),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}