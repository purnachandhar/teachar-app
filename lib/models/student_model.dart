import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  static const StudentToken = "token";
  static const StudentName = "name";
  static const StudentMobileNumber = "mobileNumber";

  String? token;
  String? studentName;
  String? studentMobileNumber;

  StudentModel({this.token, this.studentName, this.studentMobileNumber});

  StudentModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    token =snapshot.data()![StudentToken];
    studentName =snapshot.data()![StudentName];
    studentMobileNumber =snapshot.data()![studentMobileNumber];
  }
}
