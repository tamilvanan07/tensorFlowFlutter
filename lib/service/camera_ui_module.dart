import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FaceRecognitionScreen extends StatefulWidget {
  const FaceRecognitionScreen({super.key});

  @override
  _FaceRecognitionScreenState createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognitionScreen> {
  static const platform = MethodChannel('face_recognition');
  String faceData = "Waiting for Face Data...";

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler((call) async {
      if (call.method == "onFaceDetected") {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            faceData = call.arguments.toString();
          });
        });

      }
    });
  }

  Future<void> startCamera() async {
    try {
      await platform.invokeMethod('startCamera');
    } on PlatformException catch (e) {
      print("Failed to start camera: '${e.message}'.");
    }
  }

  Future<void> stopCamera() async {
    try {
      await platform.invokeMethod('stopCamera');
    } on PlatformException catch (e) {
      print("Failed to stop camera: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Face Recognition")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(faceData),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: startCamera,
            child: const Text("Start Camera"),
          ),
          ElevatedButton(
            onPressed: stopCamera,
            child: const Text("Stop Camera"),
          ),
        ],
      ),
    );
  }
}