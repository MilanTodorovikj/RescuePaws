import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resecue_paws/models/Post.dart';
import 'package:resecue_paws/screens/found_pets_screen.dart';
import 'package:resecue_paws/screens/pet_card.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/Post_factory.dart';
import 'add_pet_post_screen.dart';
import 'home_screen.dart';

class LostPetsScreen extends StatefulWidget {
  final PostFactory postFactory;
  const LostPetsScreen({super.key, required this.postFactory});

  @override
  State<LostPetsScreen> createState() => _LostPetsScreenState();
}

class _LostPetsScreenState extends State<LostPetsScreen> {
  final Query _itemsCollection =
  FirebaseFirestore.instance.collection('lostPets').orderBy('date', descending: true);
  List<Post> _lostPets = [];

  @override
  void initState() {
    // TODO: implement initState
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
        imagePath,
    );
  }

  void _addLostPet() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                NewLostPet(
                    addLostPet: _addNewLostPetToDatabase, formType: "lost")));
  }

  void addLostPet(String petType,
      String breed,
      String color,
      String age,
      String gender,
      bool collar,
      String foundPlace,
      String personName,
      String contactPhone,
      GeoPoint location,
      String imagePath) {

    Post post = widget.postFactory.createLostPet(petType: petType, breed: breed, color: color, age: age, gender: gender, collar: collar, foundPlace: foundPlace, personName: personName, contactPhone: contactPhone, location: location, imagePath: imagePath);
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
                                builder: (context) => FoundPetsScreen(postFactory: Post.defaultPost(),)),
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
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _addLostPet(),
                child: Text('Report missing pet', style: TextStyle(color: Colors.white)),
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
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
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