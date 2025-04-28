import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tensor_flow_project/service/tensor_flow_service.dart';
import 'package:tensor_flow_project/widget/loader_widget.dart';

import 'cameraView.dart';
import 'model/dbpassModel.dart';

class RecognisePage extends StatefulWidget {
  const RecognisePage({super.key});

  @override
  State<RecognisePage> createState() => _RecognisePageState();
}

class _RecognisePageState extends State<RecognisePage> {
  XFile? image;
  List<double> getEmbeddingValue = [];

  bool isLoading = false;
  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    image = await picker.pickImage(source: ImageSource.gallery);
    print("THE VISHNU IMAG PATH ${image!.path}");

    setState(() {});
  }

  TextEditingController controller = TextEditingController();

  Future<void> uploadImage() async {
    isLoading = true;
    showLoaderDialog(context, title: "Loading...");
    DbPassDate model = DbPassDate("1", controller.text, image!.path);
    var mapData = await FaceRecognitionStream.recognizeFace(model);
    print("the value ${mapData}");
    print("the value ${mapData.runtimeType}");
    if (mapData == null) {
      isLoading = false;
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }

    if (mapData.runtimeType == String) {
      if (mapData.contains("Error")) {
        Navigator.of(context, rootNavigator: true).pop();
        // Navigator.of(context, rootNavigator: true).pop();
        BotToast.showText(text: mapData);
        isLoading = false;
        return;
      }
    }
    var value = mapData["embedding"];
    if (value == "submitted") {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context, rootNavigator: true).pop();
      BotToast.showText(text: "Upload SuccessFully");
      isLoading = false;
      return;
    }
    BotToast.showText(text: value);
    isLoading = false;
    Navigator.of(context, rootNavigator: true).pop();
    // Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Face"), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: MediaQuery.of(context).padding.top + 20,
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: controller,
              onTapOutside: (_) {
                FocusScope.of(context).unfocus();
              },
              onChanged: (value) {
                // Handle name input
              },
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(fontSize: 18),
              cursorColor: Colors.blue,
              cursorHeight: 25,
              cursorWidth: 2,
              decoration: const InputDecoration(
                labelText: "Name",
                hintText: "Enter person's name",
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 2)),
                errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2)),
                focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2)),
              ),
            ),

            SizedBox(height: 44),

            MaterialButton(
              onPressed:
                  controller.text.isEmpty
                      ? null
                      : () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Container(
                              height: 200,
                              width: MediaQuery.sizeOf(context).width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text("Choose Image From"),
                                  SizedBox(height: 20),
                                  MaterialButton(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    color: Colors.blue,
                                    onPressed: () async {
                                      late List<CameraDescription> _cameras;
                                      _cameras = await availableCameras();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => CameraApp(cameras: _cameras)),
                                      ).then((v) {
                                        if (v == null) {
                                          print("The image is null");
                                          return;
                                        }
                                        print("The image is ${v[0]}");
                                        image = v[0];
                                        Navigator.of(context).pop();
                                        setState(() {});
                                      });
                                    },
                                    child: const Text("Camera"),
                                  ),
                                  MaterialButton(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    color: Colors.blue,
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      pickImage();
                                    },
                                    child: const Text("Gallery"),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
              height: 55,
              minWidth: 150,
              color: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),

              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  const Icon(Icons.browse_gallery, color: Colors.white),
                  const SizedBox(width: 10),
                  const Text("Choose Photos", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            SizedBox(height: 44),

            if (image != null) Image.file(File(image!.path), height: 250, width: 200, fit: BoxFit.fill),
            SizedBox(height: 11),
            if (image != null)
              MaterialButton(
                onPressed: () async {
                  await uploadImage();
                },
                height: 55,
                minWidth: 150,
                color: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),

                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    const Icon(Icons.update, color: Colors.white),
                    const SizedBox(width: 10),
                    const Text("Upload Image", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
