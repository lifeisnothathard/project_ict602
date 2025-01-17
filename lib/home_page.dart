import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget{
  const HomePage ({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setupCameraController();
  }

  @override
  void dispose() {
    //dispose camera controller
    cameraController?.dispose();
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: ui(),
    );
  }

Widget ui() {
   if (cameraController == null || !cameraController!.value.isInitialized) {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.red,
      ),
    );
   }
   return SafeArea(
    child: Column(
      children: [
        //camera preview
        CameraPreview(cameraController!),
        ElevatedButton(
          onPressed: () {},
          child: Text("Capture"),
          ), 
      ],
    ),
  );
}

  Future<void> setupCameraController() async{
    try{
      //fetch available camera
      final _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        setState(() {
          cameras = _cameras;
          cameraController = CameraController(_cameras.first, ResolutionPreset.high,);
        });
        //initialize the camera controller
        await cameraController!.initialize();
        //update UI after initialization
        setState(() {
          
        });
       } else {
        showError("No Camera available on this device");
       }

    } catch(e) {
      showError("Error initializing camera: $e");
    }
  }
  void showError(String message) {
  showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text(message), actions: [TextButton(onPressed: ()=> Navigator.of(context).pop, child: Text("Close"),)],),);
}
}


