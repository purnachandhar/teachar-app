import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teacher/views/send_notification/send_notification_page.dart';
import 'package:teacher/views/student/students_list_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(title: Text("Home"),),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: (){
                  Get.to(SendNotificationPage());
                },
                child: Container(
                  width: size.width / 1.5,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text("Send Notification to All Students"),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 22,
              ),
              InkWell(
                onTap: (){
                  Get.to(StudentListPage());
                },
                child: Container(
                  width: size.width / 1.5,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text("Send Notification One Student"),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
