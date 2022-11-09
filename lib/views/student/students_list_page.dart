import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teacher/constrains/controllers.dart';
import 'package:teacher/controllers/student_controller.dart';
import 'package:teacher/views/student/send_noti_to_student.dart';

class StudentListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student List"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: studentController.studentsCollection.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Loading"),
                ),
              ],
            ));
          }
          if (snapshot.hasData == null) {
            return Center(child: Text("No users"));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: InkWell(
                  onTap: (){
                    print("${snapshot.data!.docs[index]['token']}");
                    String token = "${snapshot.data!.docs[index]['token']}";
                    String name = "${snapshot.data!.docs[index]['name']}";
                    String id = "${snapshot.data!.docs[index]['id']}";
                    Get.to(SendNotificationToOneStudentPage(token,name,id));
                  },
                    child: Text("${snapshot.data!.docs[index]['name']}")),
              );
            },
          );
        },
      ),
    );
  }
}
