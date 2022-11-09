import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:teacher/constrains/firebase.dart';
import 'package:teacher/models/student_model.dart';

class StudentController extends GetxController {
  static StudentController instance = Get.find();
  CollectionReference studentsCollection =
      FirebaseFirestore.instance.collection('students');
}
