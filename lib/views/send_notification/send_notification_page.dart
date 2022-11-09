import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:teacher/constrains/firebase.dart';
import 'package:teacher/views/student/send_noti_to_student.dart';
import 'package:http/http.dart' as http;

class SendNotificationPage extends StatefulWidget {
  const SendNotificationPage({Key? key}) : super(key: key);

  @override
  State<SendNotificationPage> createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
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
    firebaseFirestore.collection("students").get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        print(result.data()['token']);
        setState(() {
          allUserTokens.add(result.data()['token']);
        });
      });
    });
    requestPermission();
    loadFCM();
    listenFCM();
  }

  List allUserTokens = [];

  void sendPushMessage(
    String body,
    String title,
    List allUserTokens,
  ) async {
    try {
      // FirebaseMessaging.instance.subscribeToTopic("myTopic1");
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
            'registration_ids': allUserTokens,
          },
        ),
      );
      print('done');
    } catch (e) {
      print("error push notification");
    }
    saveNotification(title, body);
  }

  saveNotification(String title, String description) {
    firebaseFirestore
        .collection("notifications")
        .doc()
        .set({"title": title, "description": description, "type": "all","name" :"all"});
     Get.back();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Send Notification"),
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
                  sendPushMessage(decriptionTextEditingController.text.trim(),
                      titleTextEditingController.text.trim(), allUserTokens);
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
            ],
          ),
        ),
      ),
    );
  }
}
