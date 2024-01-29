import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resecue_paws/models/Post.dart';
import 'package:resecue_paws/screens/found_pets_screen.dart';
import 'package:resecue_paws/screens/pet_card.dart';

import 'add_pet_post_screen.dart';
import 'home_screen.dart';

class LostPetsScreen extends StatefulWidget {
  const LostPetsScreen({super.key});

  @override
  State<LostPetsScreen> createState() => _LostPetsScreenState();
}

class _LostPetsScreenState extends State<LostPetsScreen> {
  final CollectionReference _itemsCollection =
  FirebaseFirestore.instance.collection('lostPets');
  List<Post> _lostPets = [];

  // static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  String? _deviceToken;

  // static void initialize() {
  //   // Initialization  setting for android
  //   const InitializationSettings initializationSettingsAndroid = InitializationSettings(
  //     android: AndroidInitializationSettings('image'),
  //   );
  //   _notificationsPlugin.initialize(
  //     initializationSettingsAndroid,
  //     // to handle event when we receive notification
  //     onDidReceiveNotificationResponse: (details) {
  //       if (details.input != null) {}
  //     },
  //   );
  // }

  // Future<bool> _requestLocationService() async {
  //   PermissionStatus status = await Permission.location.status;
  //   if (status == PermissionStatus.denied) {
  //     status = await Permission.location.request();
  //     if (status != PermissionStatus.granted) {
  //       // Handle the case where the user denied location permission
  //       return false;
  //     }
  //   }
  //
  //   if (status == PermissionStatus.granted) {
  //     return true;
  //   }
  //
  //   return false;
  // }

  // Future<void> _requestNotificationPermission() async {
  //   PermissionStatus status = await Permission.notification.request();
  //   if (status.isGranted) {
  //     print("Notification permission granted");
  //   } else if (status.isDenied) {
  //     print("Notification permission denied");
  //   } else if (status.isPermanentlyDenied) {
  //     print("Notification permission permanently denied");
  //     // You might want to open the app settings in this case
  //     openAppSettings();
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // initialize();
    // _requestNotificationPermission();
    // _requestLocationService();
    //
    //
    // OneSignal.shared.setAppId("657ac24e-e486-475b-85ab-925e4654ddfc");
    //
    // OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
    //   // Handle notification open
    // });
    //
    // FirebaseMessaging.instance.getToken().then((token) {
    //   _deviceToken = token;
    // });
    //
    // // To initialise when app is not terminated
    // FirebaseMessaging.instance.getInitialMessage().then((message) {
    //   // Handle initial message
    // });
    //
    // FirebaseMessaging.onMessage.listen((message) {
    //   if (message.notification != null) {
    //     display(message);
    //   }
    // });
  }

  // Future<void> requestPermission() async {
  //   await OneSignal.shared.promptUserForPushNotificationPermission();
  // }

  // static Future<void> display(RemoteMessage message) async {
  //   // To display the notification in device
  //   try {
  //     print(message.notification!.android!.sound);
  //     final id = DateTime
  //         .now()
  //         .millisecondsSinceEpoch ~/ 1000;
  //     NotificationDetails notificationDetails = NotificationDetails(
  //       android: AndroidNotificationDetails(
  //           message.notification!.android!.sound ?? "Channel Id",
  //           message.notification!.android!.sound ?? "Main Channel",
  //           groupKey: "gfg",
  //           color: Colors.green,
  //           importance: Importance.max,
  //           sound: RawResourceAndroidNotificationSound(
  //               message.notification!.android!.sound ?? "gfg"),
  //
  //           // different sound for
  //           // different notification
  //           playSound: true,
  //           priority: Priority.high),
  //     );
  //     await _notificationsPlugin.show(id, message.notification?.title,
  //         message.notification?.body, notificationDetails,
  //         payload: message.data['route']);
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  void _addNewLostPetToDatabase(String petType,
      String breed,
      String color,
      String age,
      String gender,
      bool collar,
      String foundPlace,
      //image
      String personName,
      String contactPhone,
      GeoPoint location) async {
    // String topic = 'lost_pets';
    //
    // FirebaseMessaging.instance.subscribeToTopic(topic);
    //
    // try {
    //   var deviceState = await OneSignal.shared.getDeviceState();
    //   String? playerId = deviceState?.userId;
    //
    //
    //
    //   if (playerId != null && playerId.isNotEmpty) {
    //     print("playerId:"+playerId);
    //     List<String> playerIds = [playerId];
    //
    //     try {
    //       await OneSignal.shared.postNotification(OSCreateNotification(
    //         playerIds: playerIds,
    //         content: "You have a new exam: $subject",
    //         heading: "New Exam Added",
    //       ));
    //     } catch (e) {
    //       print("Error posting notification: $e");
    //     }
    //   } else {
    //     print("Player ID is null or empty.");
    //   }
    // } catch (e) {
    //   // Handle errors
    //   print("Error getting device state: $e");
    // }

    addLostPet(
        petType,
        breed,
        color,
        age,
        gender,
        collar,
        foundPlace,
        personName,
        contactPhone,
        location);
  }

  void _addLostPet() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                NewLostPet(
                    addLostPet: _addNewLostPetToDatabase, formType: "lost")));
  }

  Future<void> addLostPet(String petType,
      String breed,
      String color,
      String age,
      String gender,
      bool collar,
      String foundPlace,

      //image
      String personName,
      String contactPhone,
      GeoPoint location) {
    // User? user = FirebaseAuth.instance.currentUser;
    DateTime newDate = DateTime.now();
    // if (user != null) {
    //   return FirebaseFirestore.instance.collection('exams').add({
    //     'subject': subject,
    //     'date': newDate,
    //     'location': location,
    //     'userId': user.uid,
    //   });
    // }

    return FirebaseFirestore.instance.collection('lostPets').add({
      'petType': petType,
      'breed': breed,
      'color': color,
      'age': age,
      'gender': gender,
      'collar': collar,
      'foundPlace': foundPlace,
      'personName': personName,
      'contactPhone': contactPhone,
      'date': newDate,
      'location': location
    });

    // return FirebaseFirestore.instance.collection('lostPets').add({
    //   'petType': 'petType',
    //   'breed': 'breed',
    //   'color': 'color',
    //   'age': 'age',
    //   'gender': 'gender',
    //   'collar': true,
    //   'foundPlace': 'foundPlace',
    //   'personName': 'personName',
    //   'contactPhone': 'contactPhone',
    //   'date': DateTime.now(),
    // });
  }

  // Future<void> _signOutAndNavigateToLogin(BuildContext context) async {
  //   try {
  //     await FirebaseAuth.instance.signOut();
  //     Navigator.of(context).pushAndRemoveUntil(
  //       MaterialPageRoute(builder: (context) => AuthGate()),
  //           (Route<dynamic> route) => false,
  //     );
  //   } catch (e) {
  //     print('Error during sign out: $e');
  //     // Handle the error
  //   }
  // }

  // void _goToCalendar() {
  //   print("calendar button pressed");
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) =>
  //               CalendarScreen()));
  // }

  // Future<void> _deleteExam(String subject, DateTime date) async {
  //   User? user = FirebaseAuth.instance.currentUser;
  //
  //   if (user != null) {
  //     // Find the document with matching subject, date, and userId
  //     var query = _itemsCollection
  //         .where('subject', isEqualTo: subject)
  //         .where('date', isEqualTo: date)
  //         .where('userId', isEqualTo: user.uid);
  //
  //     query.get().then((querySnapshot) {
  //       querySnapshot.docs.forEach((doc) {
  //         // Delete the document with the found ID
  //         _itemsCollection.doc(doc.id).delete();
  //       });
  //     });
  //   }
  //
  //   String topic = 'exams'; // Use a meaningful topic name
  //
  //   FirebaseMessaging.instance.subscribeToTopic(topic);
  //
  //   try {
  //     var deviceState = await OneSignal.shared.getDeviceState();
  //     String? playerId = deviceState?.userId;
  //
  //
  //
  //     if (playerId != null && playerId.isNotEmpty) {
  //       print("playerId:"+playerId);
  //       List<String> playerIds = [playerId];
  //
  //       try {
  //         await OneSignal.shared.postNotification(OSCreateNotification(
  //           playerIds: playerIds,
  //           content: "You deleted an exam: $subject",
  //           heading: "Exam deleted",
  //         ));
  //       } catch (e) {
  //         print("Error posting notification: $e");
  //       }
  //     } else {
  //       print("Player ID is null or empty.");
  //     }
  //   } catch (e) {
  //     // Handle errors
  //     print("Error getting device state: $e");
  //   }
  //
  // }

  // void _launchGoogleMaps(GeoPoint location) async {
  //   final lat = location.latitude;
  //   final long = location.longitude;
  //   final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$long';
  //
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     print('Could not launch $url');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Column(
        children: [
          const SizedBox(height: 40.0),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PopupMenuButton<int>(
                    itemBuilder: (context) =>
                    [
                      const PopupMenuItem(
                        value: 1,
                        child: Text('Home'),
                      ),
                      const PopupMenuItem(
                        value: 2,
                        child: Text('Found pets'),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 1:
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Home()),
                          );
                          break;
                        case 2:
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FoundPetsScreen()),
                          );
                          break;
                      }
                    },
                    offset: Offset(-100, 0),
                  ),
                  const Text(
                    'Lost pets',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Color.fromRGBO(27, 53, 86, 1.0),
                    ),
                  ),
                  Image.asset(
                    "lib/images/logo.png",
                    height: 50,
                  ),
                ],
              ),
              Image.asset(
                "lib/images/2dogs1cat.jpg",
                height: 110,
                width: 400,
                fit: BoxFit.fitWidth,
              ),
              ElevatedButton(
                onPressed: () => _addLostPet(),
                child: Text('Add pet'),
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromRGBO(27, 53, 86, 1.0),
                  elevation: 4,
                  textStyle: const TextStyle(fontSize: 15),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _itemsCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                List<Post> items = snapshot.data!.docs.map((
                    DocumentSnapshot doc) {
                  return Post.fromMap(doc.data() as Map<String, dynamic>);
                }).toList();
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        // width: MediaQuery
                        //     .of(context)
                        //     .size
                        //     .width * 0.6,
                        child: PetCard(
                          petType: items[index].petType,
                          breed: items[index].breed,
                          color: items[index].color,
                          age: items[index].age,
                          gender: items[index].gender,
                          hasCollar: items[index].collar,
                          foundBy: items[index].foundPlace,
                          contact: items[index].contactPhone,
                          imageUrl: "https://www.akc.org/wp-content/uploads/2017/11/Pomeranian-On-White-01.jpg",
                          onLocationPressed: () {},
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}