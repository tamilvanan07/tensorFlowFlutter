import 'dart:typed_data';
import 'package:flutter/services.dart';

import '../model/dbpassModel.dart';

class FaceRecognitionStream {
  static const EventChannel _eventChannel = EventChannel('camera_event_channel');
  static const MethodChannel _method = MethodChannel('camera_preview');

  static Stream get faceEmbeddingsStream {
    return _eventChannel.receiveBroadcastStream().map((data) => data ?? '');
  }

  static Future<void> stopCamera() async {
    try {
      final result = await _method.invokeMethod('stopCamera');
      print('Start Camera Result: $result');
    } catch (e) {
      print('Error: $e');
    }
  }

  static Future<void> startCameras() async {
    try {
      final result = await _method.invokeMethod('startCameras');
      print('Start Camera Result: $result');
    } catch (e) {
      print('Error: $e');
    }
  }

  static Future<dynamic> recognizeFace(DbPassDate model) async {
    try {
      final result = await _method.invokeMethod('faceRecogniseCamera', {
        "imageURI": model.imageURI,
        "personName": model.personName,
      });
      print('Start Camera Result: $result');
      return result;
    } catch (e) {
      print('Error: $e');
    }
  }

  static Future<dynamic> getAllPersonList() async {
    try {
      final result = await _method.invokeMethod('GETALL');
      print('Start GETALL: $result');
      return result;
    } catch (e) {
      print('Error: $e');
    }
  }

  static Future<dynamic> removePerson(String? id) async {
    try {
      final result = await _method.invokeMethod('removePerson', {"id": id});
      return result;
    } catch (e) {
      print('Error: $e');
    }
  }

  static Future<dynamic> updatePersonPhoto(String? id,String? imagePath) async {
    try {
      final result = await _method.invokeMethod('updatePersonPhotoEmbedding', {"id": id,"imageURI" : imagePath});
      return result;
    } catch (e) {
      print('Error: $e');
    }
  }
}
