import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:tensor_flow_project/recognise_page.dart';
import 'package:tensor_flow_project/service/camera_ui_module.dart';

import 'new_camera_check.dart';


// late ObjectBox objectbox;
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // objectbox = await ObjectBox.create();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      builder: BotToastInit(), //1. call BotToastInit
      navigatorObservers: [BotToastNavigatorObserver()], //2. registered route observer
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: CameraScreenView(),
    );
  }
}
 class MyHomePage extends StatelessWidget {
   const MyHomePage({super.key});

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       body: Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: <Widget>[
           MaterialButton(onPressed: (){
           Navigator.push(context, MaterialPageRoute(builder:   (context) => FaceRecognitionScreen()));
           }, child: Text('Open Camera')),
           ],
         ),
       ),
     );
   }
 }

