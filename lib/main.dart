import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:resecue_paws/screens/home_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  OneSignal.shared.setAppId("657ac24e-e486-475b-85ab-925e4654ddfc");

  FirebaseMessaging.onMessage.listen((message) {
    if (message.notification != null) {
      display(message);
    }
  });

  await OneSignal.shared.promptUserForPushNotificationPermission();
  FirebaseMessaging.instance.subscribeToTopic('foundPets');
  runApp(const MyApp());
}

FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> display(RemoteMessage message) async {
  // To display the notification in device
  try {
    print(message.notification!.android!.sound);
    final id = DateTime
        .now()
        .millisecondsSinceEpoch ~/ 1000;
    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
          message.notification!.android!.sound ?? "Channel Id",
          message.notification!.android!.sound ?? "Main Channel",
          groupKey: "gfg",
          color: Colors.green,
          importance: Importance.max,
          sound: RawResourceAndroidNotificationSound(
              message.notification!.android!.sound ?? "gfg"),

          // different sound for
          // different notification
          playSound: true,
          priority: Priority.high),
    );
    await _notificationsPlugin.show(id, message.notification?.title,
        message.notification?.body, notificationDetails,
        payload: message.data['route']);
  } catch (e) {
    debugPrint(e.toString());
  }
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rescue Paws',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}

