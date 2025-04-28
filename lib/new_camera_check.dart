// lib/main.dart
import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:tensor_flow_project/recognise_page.dart';
import 'package:tensor_flow_project/service/tensor_flow_service.dart';
import 'dart:ui' as ui;
import 'listOfPerson.dart';

class CameraScreenView extends StatefulWidget {
  @override
  _CameraScreenViewState createState() => _CameraScreenViewState();
}

class _CameraScreenViewState extends State<CameraScreenView> {
  bool isGranted = false;
  String? streamData;
  String name = "";
  double height = 0.0;
  double width = 0.0;
  StreamSubscription? _subscription;
  Map<String, dynamic> value = {};
  Rect? _faceRect;
  void faceStream() {
    _subscription = FaceRecognitionStream.faceEmbeddingsStream.listen((embedding) {
      setState(() {
        streamData = embedding.toString();
        height = embedding["height"].toDouble();
        name = embedding["name"].toString();
        width = embedding["width"].toDouble();
        if (embedding["left"] == null ||
            embedding["top"] == null ||
            embedding["right"] == null ||
            embedding["bottom"] == null) {
          _faceRect = null;
          return;
        }
        _faceRect = Rect.fromLTRB(
          embedding["left"].toDouble() * 1.0, // x
          embedding["top"].toDouble() * 1.0, // y
          embedding["right"].toDouble() * 1.0, // width
          embedding["bottom"].toDouble() * 1.0, // height
        );
      });
      print("Received Face Embedding: $streamData");
    });
  }

  @override
  void initState() {
    super.initState();
    faceStream();
    _requestCameraPermission().then((_) => checkPermission());
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() {}); // Rebuild to show the camera preview
    } else {
      // Handle permission denial (e.g., show an error message)
      print("Camera permission denied");
    }
  }

  void checkPermission() async {
    isGranted = await Permission.camera.status.isGranted;
    setState(() {});
  }

  @override
  void dispose() {
    FaceRecognitionStream.stopCamera();
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Preview'),
        actions: [
          IconButton(
            onPressed: () {
              FaceRecognitionStream.stopCamera();
              Navigator.push(context, MaterialPageRoute(builder: (context) => ListofPerson())).then((V) {
                Future.delayed(Duration.zero).then((v) {
                  FaceRecognitionStream.startCameras();
                  setState(() {});
                });
              });
            },
            icon: Text("Face List", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          IconButton(
            onPressed: () {
              FaceRecognitionStream.stopCamera();
              Navigator.push(context, MaterialPageRoute(builder: (context) => RecognisePage())).then((V) {
                Future.delayed(Duration.zero).then((v) {
                  FaceRecognitionStream.startCameras();
                  setState(() {});
                });
              });
            },
            icon: Icon(Icons.face),
          ),
        ],
      ),
      body: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final previewWidth = constraints.maxWidth;
            final previewHeight = constraints.maxHeight;

            final scaleX = previewWidth / width; // Kotlin Bitmap width
            final scaleY = previewHeight / height; // Kotlin Bitmap height
            return Stack(
              fit: StackFit.expand,
              children: [
                AndroidView(
                  viewType: 'camera_preview', // Must match the viewType registered in MainActivity
                  creationParams: {}, // Optional parameters to pass to the native view
                  creationParamsCodec: const StandardMessageCodec(),
                ),
                if (_faceRect != null)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: FacePainter(faceRect: _faceRect!, scaleX: scaleX, scaleY: scaleY, name: name),
                      child: SizedBox(),
                    ),
                  ),
              ],
            );
          },
        ),
      ), // Expanded(child: Text("the value is granted $streamData"))
    );
  }
}

// ✅ Draw Rectangle Around the Detected Face
class FacePainter extends CustomPainter {
  final Rect? faceRect;
  final bool isFrontCamera;
  final double scaleX;
  final double scaleY;
  final String? name; // 👈 Add name field

  FacePainter({this.faceRect, this.isFrontCamera = true, this.scaleX = 0.0, this.scaleY = 0.0, this.name});

  @override
  void paint(Canvas canvas, Size size) {
    if (faceRect == null) return;

    final Paint paint =
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;

    // Step 1: Scale the rect to Flutter preview
    final scaledRect = Rect.fromLTRB(
      faceRect!.left * scaleX,
      faceRect!.top * scaleY,
      faceRect!.right * scaleX,
      faceRect!.bottom * scaleY,
    );

    // Step 2: Mirror horizontally if front camera
    final mirroredRect =
        isFrontCamera
            ? Rect.fromLTRB(
              size.width - scaledRect.right,
              scaledRect.top,
              size.width - scaledRect.left,
              scaledRect.bottom,
            )
            : scaledRect;

    // ✅ Draw face rectangle
    canvas.drawRect(mirroredRect, paint);

    // ✅ Draw name label (if provided)
    if (name != null && name!.isNotEmpty) {
      final textSpan = TextSpan(
        text: name,
        style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
      );

      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();

      // Position text slightly above the top-left corner of the rectangle
      final offset = Offset(mirroredRect.left, mirroredRect.top - textPainter.height - 4);

      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant FacePainter oldDelegate) =>
      oldDelegate.faceRect != faceRect ||
      oldDelegate.scaleX != scaleX ||
      oldDelegate.scaleY != scaleY ||
      oldDelegate.name != name || // 👈 compare name
      oldDelegate.isFrontCamera != isFrontCamera;
}
