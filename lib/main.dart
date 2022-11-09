import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:teacher/constrains/firebase.dart';
import 'package:teacher/controllers/notification_controller.dart';
import 'package:teacher/controllers/student_controller.dart';
import 'package:teacher/views/home/home.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initialization.then((value) {
    Get.put(NotificationController());
    Get.put(StudentController());
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

