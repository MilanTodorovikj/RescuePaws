import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:resecue_paws/models/Post.dart';
import 'package:resecue_paws/screens/lost_pets_screen.dart';
import 'package:resecue_paws/screens/pet_card.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/Post_factory.dart';
import 'add_pet_post_screen.dart';
import 'home_screen.dart';

class FoundPetsScreen extends StatefulWidget {
  final PostFactory postFactory;
  const FoundPetsScreen({super.key, required this.postFactory});

  @override
  State<FoundPetsScreen> createState() => _FoundPetsScreenState();
}

class _FoundPetsScreenState extends State<FoundPetsScreen> {
  final CollectionReference _itemsCollection =
  FirebaseFirestore.instance.collection('foundPets');
  List<Post> _foundPets = [];

  // static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  String? _deviceToken;

  @override
  void initState() {
    super.initState();
  }

  void _addNewLostPetToDatabase(String petType,
      String breed,
      String color,
      String age,
      String gender,
      bool collar,
      String foundPlace,
      String personName,
      String contactPhone,
      GeoPoint location,
      Map<String, dynamic> formData) async {
    // Check if the image is not null before adding it to the database
    String imagePath = formData['imagePath'] ?? '';

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
      location,
      imagePath, // Pass the image path to the addLostPet method
    );
  }

  void _addLostPet() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                NewLostPet(
                    addLostPet: _addNewLostPetToDatabase, formType: "found")));
  }

  Future<void> addLostPet(String petType,
      String breed,
      String color,
      String age,
      String gender,
      bool collar,
      String foundPlace,
      String personName,
      String contactPhone,
      GeoPoint location,
      String imagePath) async {
    Post post = widget.postFactory.createFoundPet(petType: petType, breed: breed, color: color, age: age, gender: gender, collar: collar, foundPlace: foundPlace, personName: personName, contactPhone: contactPhone, location: location, imagePath: imagePath);

    try {
      var deviceState = await OneSignal.shared.getDeviceState();
      String? playerId = deviceState?.userId;



      if (playerId != null && playerId.isNotEmpty) {
        print("playerId:"+playerId);
        List<String> playerIds = [playerId];

        try {
          await OneSignal.shared.postNotification(OSCreateNotification(
            playerIds: playerIds,
            content: "A new "+post.petType+" has been found.\nBreed: " + post.breed+", color/pattern: " +post.color+", gender: "+post.gender+" at: " +post.foundPlace,
            heading: "New Pet Found",
          ));
        } catch (e) {
          print("Error posting notification: $e");
        }
      } else {
        print("Player ID is null or empty.");
      }
    } catch (e) {
      // Handle errors
      print("Error getting device state: $e");
    }


  }

  void _launchGoogleMaps(GeoPoint location) async {
    final lat = location.latitude;
    final long = location.longitude;
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$long';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

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
                        child: Text('Lost pets'),
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
                                builder: (context) => LostPetsScreen(postFactory: Post.defaultPost(),)),
                          );
                          break;
                      }
                    },
                    offset: Offset(-100, 0),
                  ),
                  const Text(
                    'Found pets',
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
                "lib/images/2cats1dog.jpg",
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
                          foundBy: items[index].personName,
                          contact: items[index].contactPhone,
                          imageUrl: items[index].imagePath,
                          onLocationPressed: () {_launchGoogleMaps(items[index].location);},
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