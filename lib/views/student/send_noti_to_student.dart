import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:teacher/constrains/firebase.dart';

class SendNotificationToOneStudentPage extends StatefulWidget {
  String? token;
  String? name;
  String? id;

  SendNotificationToOneStudentPage(this.token, this.name, this.id);

  @override
  State<SendNotificationToOneStudentPage> createState() =>
      _SendNotificationToOneStudentPageState();
}

class _SendNotificationToOneStudentPageState
    extends State<SendNotificationToOneStudentPage> {
  TextEditingController titleTextEditingController = TextEditingController();

  TextEditingController decriptionTextEditingController =
      TextEditingController();

  var channel;

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        enableVibration: true,
      );

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
  }

  void initState() {
    super.initState();
    requestPermission();
    loadFCM();
    listenFCM();
  }

  void sendPushMessage(String body, String title, String token) async {
    print(
      "body: $body \n title: $title \n token: $token",
    );
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAFovm5KM:APA91bE1CPEkSdh1ricFZjWAAKhbXQTcjr-eE8PBDr1yM5PsJMvD3mx4jYI4G43koKmQHv1OA-pN_Rpl1a62oOjZfhkV_e9T__Ji_pUd3u1Sn8pPLV8yZ2kp3dW5lReIfPEibscGm58J',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
      );
      print('done');
    } catch (e) {
      print("error push notification");
    }
    saveNotification(title, body,"${widget.name}");
  }

  saveNotification(String title, String description ,String name) {
    firebaseFirestore
        .collection("notifications")
        .doc()
        .set({"title": title, "description": description,"type": "individual", "name" :name});
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Send Notification to ${widget.name}"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: titleTextEditingController,
                  decoration: InputDecoration(hintText: "Message Tile"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: decriptionTextEditingController,
                  decoration: InputDecoration(hintText: "Enter Description"),
                  maxLines: 5,
                ),
              ),
              SizedBox(
                height: 22,
              ),
              InkWell(
                onTap: () {
                  sendPushMessage(
                      decriptionTextEditingController.text.toString(),
                      titleTextEditingController.text.toString(),
                      widget.token!);
                },
                child: Container(
                  width: size.width / 1.5,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text(
                        "Send Notification to ${widget.name}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
