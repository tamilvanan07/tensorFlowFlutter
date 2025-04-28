import 'dart:convert';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tensor_flow_project/service/tensor_flow_service.dart';
import 'package:tensor_flow_project/widget/loader_widget.dart';

import 'cameraView.dart';
import 'model/personDB.dart';

class ListofPerson extends StatefulWidget {
  const ListofPerson({super.key});

  @override
  State<ListofPerson> createState() => _ListofPersonState();
}

class _ListofPersonState extends State<ListofPerson> {
  PersonDb? listOfPersonModel;
  List<PersonDb> list = [];
  XFile? image;
  bool isLoading = false;

  Future removeId(String? id, int index) async {
    showLoaderDialog(context, title: "Removing...");
    var message = await FaceRecognitionStream.removePerson(id);
    list.remove(list[index]);
    Navigator.of(context, rootNavigator: true).pop();
    setState(() {});
  }

  Future getData() async {
    try {
      setState(() {
        isLoading = true;
      });
      var result = await FaceRecognitionStream.getAllPersonList();
      print("THE RESULT IS $result");

      if (result == null) {
        setState(() {
          isLoading = false;
        });
        print("The list is empty");
        return;
      }
      final List<dynamic> jsonList = jsonDecode(result);

      final List<PersonDb> personList =
          jsonList.map((item) => PersonDb.fromJson(item as Map<String, dynamic>)).toList();

      print(personList.first.personName);
      list = personList;
      print("The data is ${list.length}");

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error in getting data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future uploadImage(String? id,BuildContext context) async {
    showLoaderDialog(context, title: "Uploading...");
    var imageValue = await FaceRecognitionStream.updatePersonPhoto(id.toString(), image!.path);

    if (imageValue == false) {
      BotToast.showText(text: "Image is not updated");
      Navigator.of(context).pop();
      return;
    }
    BotToast.showText(text: "Image updated successfully");
    Navigator.of(context).pop();
  }

  Future pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    var result = await picker.pickImage(source: ImageSource.gallery);
    // Navigator.of(context, rootNavigator: true).pop();
    return result;
  }

  bool isExpansion = false;

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List of Person"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ListofPerson()));
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : list.isEmpty
              ? Center(child: Text("No Data Found"))
              : SafeArea(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  itemBuilder: (BuildContext context, int index) {
                    return CardWidget(
                      personDb: list[index],
                      onTap: () async {
                        try {
                          removeId(list[index].personID.toString(), index);
                        } catch (e) {
                          print("Error in removing person: $e");
                        }
                        setState(() {});
                      },
                      showDialogue: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return showImageUpdatePopUp(list[index].personID.toString());
                          },
                        );
                      },
                    );
                  },
                  itemCount: list.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(height: 11);
                  },
                ),
              ),
    );
  }

  Widget showImageUpdatePopUp(String id) {
    return StatefulBuilder(
      builder: (context, SET) {
        return Card(
          child: SizedBox(
            height: 300,
            width: MediaQuery.sizeOf(context).width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (image != null) Image.file(File(image!.path), height: 250, width: 200, fit: BoxFit.fill),
                MaterialButton(
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onPressed: () async {
                    if (image != null) {
                      uploadImage(id,context,);
                      SET(() {});
                      return;
                    }

                    showModalBottomSheet(context: context, builder: (context){

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

                              onPressed: () async{
                                late List<CameraDescription> _cameras;
                                _cameras = await availableCameras();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CameraApp(cameras: _cameras,),
                                  ),
                                ).then(( v) {
                                  if (v == null) {
                                    print("The image is null");
                                    return;
                                  }
                                  print("The image is ${v[0]}");
                                  image = v[0];
                                  Navigator.of(context).pop();
                                  SET(() {});
                                } );

                              },
                              child: const Text("Camera"),
                            ),
                            MaterialButton(
                              onPressed: ()async {
                                Navigator.of(context).pop();
                                image = await pickImage();
                              },
                              child: const Text("Gallery"),
                            ),
                          ],
                        ),
                      );
                    });

                    SET(() {});
                  },
                  child: Text(
                    image != null ? "Upload Image" : "Select Photo",
                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CardWidget extends StatefulWidget {
  final PersonDb personDb;
  final VoidCallback onTap;
  final VoidCallback showDialogue;
  const CardWidget({super.key, required this.personDb, required this.onTap, required this.showDialogue});

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  bool isExpansion = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: AnimatedSize(
        duration: Duration(milliseconds: 300),
        reverseDuration: Duration(milliseconds: 300),
        child: GestureDetector(
          onTap: () {
            isExpansion = !isExpansion;
            setState(() {});
          },
          child: Column(
            children: [
              ListTile(
                title: Text(widget.personDb.personName ?? "No Name"),
                subtitle: Text("Person ID: ${widget.personDb.personID}"),
                trailing: IconButton(onPressed: widget.onTap, icon: Icon(Icons.delete)),
              ),

              if (isExpansion)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MaterialButton(
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        onPressed: () {},
                        child: Text("Change Name", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white)),
                      ),

                      MaterialButton(
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        onPressed: widget.showDialogue,
                        child: Text("Change Photo", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    ;
  }
}
