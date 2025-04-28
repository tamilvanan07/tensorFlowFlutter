// import 'dart:isolate';
// import 'dart:typed_data';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:flutter/services.dart';
// import 'package:image/image.dart' as img;
//
// class CameraScreen extends StatefulWidget {
//   @override
//   _CameraScreenState createState() => _CameraScreenState();
// }
//
// class _CameraScreenState extends State<CameraScreen> {
//   CameraController? _cameraController;
//   bool isProcessing = false;
//   int frameCount = 0;
//   static const MethodChannel _channel = MethodChannel('face_recognition');
//   Rect? faceRect;
//   FaceBoundingBox? detectedFace;
//   List<double> faceEmbedding = [];
//   @override
//   void initState() {
//     super.initState();
//     FaceRecognitionService.startIsolate();
//     _initializeCamera();
//   }
//
//   Future<void> _initializeCamera() async {
//     await FaceRecognitionService.startIsolate();
//     final cameras = await availableCameras();
//     _cameraController = CameraController(cameras[1], ResolutionPreset.medium);
//     await _cameraController?.initialize();
//     if (mounted) setState(() {});
//     _startImageStream();
//   }
//
//   void _startImageStream() {
//     _cameraController?.startImageStream((CameraImage image) async {
//       if (!isProcessing) {
//         isProcessing = true;
//         if (frameCount % 3 == 0) {
//           var map = {'value': image};
//           // ✅ Skip frames to reduce lag
//           await FaceRecognitionService.recognizeFace(map).then((result) {
//             print("Recognition Result: $result");
//             faceEmbedding = List<double>.from(result["embedding"]);
//
//             // 🔹 Save bounding box for drawing square
//             detectedFace = FaceBoundingBox(
//               left: result["left"],
//               top: result["top"],
//               right: result["right"],
//               bottom: result["bottom"],
//             );
//             setState(() {
//
//             });
//             isProcessing = false;
//           });
//         }
//         frameCount++;
//         isProcessing = false;
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final scaleX = size.width / 480; // Camera preview width
//     final scaleY = size.height / 640; // Camera preview height
//
//     if (_cameraController == null || !_cameraController!.value.isInitialized) {
//       return Center(child: CircularProgressIndicator());
//     }
//     return Scaffold(
//       body: Stack(
//         children: [
//           CameraPreview(_cameraController!),
//           // if (detectedFace != null)
//           //   CustomPaint(painter: FacePainter(face: detectedFace!, scaleX: scaleX, scaleY: scaleY), child: Container()),
//         ],
//       ),
//     );
//   }
// }
//
// // ✅ Draw Rectangle Around the Detected Face
//
// class FacePainter extends CustomPainter {
//   final FaceBoundingBox? face;
//   final double scaleX, scaleY;
//
//   FacePainter({required this.face, required this.scaleX, required this.scaleY});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     if (face == null) return;
//
//     final paint =
//         Paint()
//           ..color = Colors.green
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 3.0;
//
//     final left = face!.left * scaleX;
//     final top = face!.top * scaleY;
//     final right = face!.right * scaleX;
//     final bottom = face!.bottom * scaleY;
//
//     final rect = Rect.fromLTRB(left, top, right, bottom);
//     canvas.drawRect(rect, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant FacePainter oldDelegate) {
//     return oldDelegate.face != face;
//   }
// }
//
// class FaceRecognitionService {
//   static SendPort? _sendPort;
//   static const MethodChannel _channel = MethodChannel('face_recognition');
//
//   /// Start the isolate for image processing
//   static Future<void> startIsolate() async {
//     ReceivePort receivePort = ReceivePort();
//     await Isolate.spawn(_isolateEntry, receivePort.sendPort);
//     _sendPort = await receivePort.first;
//   }
//
//   /// The function that runs in the isolate
//   static void _isolateEntry(SendPort sendPort) {
//     ReceivePort receivePort = ReceivePort();
//     sendPort.send(receivePort.sendPort);
//
//     receivePort.listen((message) async {
//       final Map<String, dynamic> data = message['data'];
//       final SendPort replyPort = message['replyPort'];
//
//       // Process Image
//       Uint8List processedBytes = await _convertCameraImageToBytes(data);
//
//       replyPort.send(processedBytes);
//     });
//   }
//
//   /// Call this function to process images in isolate
//   static Future<Uint8List> processImage(Map<String, dynamic> map) async {
//     CameraImage image = map['value'];
//
//     if (_sendPort == null) await startIsolate();
//
//     ReceivePort receivePort = ReceivePort();
//     _sendPort?.send({
//       "data": {'value': image},
//       "replyPort": receivePort.sendPort,
//     });
//
//     return await receivePort.first;
//   }
//
//   /// Convert CameraImage to RGB Uint8List (Runs inside isolate)
//   static Future<Uint8List> _convertCameraImageToBytes(Map<String, dynamic> params) async {
//     final CameraImage image = params['value'];
//
//     final int width = image.width;
//     final int height = image.height;
//
//     final Uint8List yBuffer = image.planes[0].bytes;
//     final Uint8List uBuffer = image.planes[1].bytes;
//     final Uint8List vBuffer = image.planes[2].bytes;
//
//     final int yRowStride = image.planes[0].bytesPerRow;
//     final int uvRowStride = image.planes[1].bytesPerRow;
//     final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;
//
//     final Uint8List rgbBuffer = Uint8List(width * height * 3);
//     int bufferIndex = 0;
//
//     for (int y = 0; y < height; y++) {
//       for (int x = 0; x < width; x++) {
//         final int yIndex = y * yRowStride + x;
//         final int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;
//
//         final int yValue = yBuffer[yIndex] & 0xFF;
//         final int uValue = uBuffer[uvIndex] & 0xFF;
//         final int vValue = vBuffer[uvIndex] & 0xFF;
//
//         final int r = (yValue + 1.402 * (vValue - 128)).toInt();
//         final int g = (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128)).toInt();
//         final int b = (yValue + 1.772 * (uValue - 128)).toInt();
//
//         rgbBuffer[bufferIndex++] = r.clamp(0, 255);
//         rgbBuffer[bufferIndex++] = g.clamp(0, 255);
//         rgbBuffer[bufferIndex++] = b.clamp(0, 255);
//       }
//     }
//
//     // ✅ Resize the image before returning
//     final img.Image originalImage = img.Image.fromBytes(width: width, height: height, bytes: rgbBuffer.buffer);
//
//     final img.Image resizedImage = img.copyResize(originalImage, width: 160, height: 160);
//
//     return Uint8List.fromList(resizedImage.getBytes(order: img.ChannelOrder.rgb));
//   }
//
//   /// Call Native Method for Face Recognition
//   static Future recognizeFace(Map<String, dynamic> map) async {
//     CameraImage image = map['value'];
//     Uint8List processedBytes = await processImage(map);
//
//     try {
//       // ✅ Now call the MethodChannel in the main isolate
//       var result = await _channel.invokeMethod('recognizeFace', {
//         "bytes": processedBytes,
//         "width": image.width,
//         "height": image.height,
//       });
//
//       return result;
//     } catch (e) {
//       print("Error: $e");
//       return null;
//     }
//   }
// }
//
// class FaceBoundingBox {
//   final double left;
//   final double top;
//   final double right;
//   final double bottom;
//
//   FaceBoundingBox({required this.left, required this.top, required this.right, required this.bottom});
// }
