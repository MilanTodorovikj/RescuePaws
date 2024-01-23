import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resecue_paws/models/Post.dart';

import 'add_pet_post_screen.dart';


class FoundPetsScreen extends StatefulWidget {
  const FoundPetsScreen({super.key});

  @override
  State<FoundPetsScreen> createState() => _FoundPetsScreenState();
}

class _FoundPetsScreenState extends State<FoundPetsScreen> {
  final CollectionReference _itemsCollection = FirebaseFirestore.instance
      .collection('foundPets');
  List<Post> _foundPets = [];
  // static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  String? _deviceToken;

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
      //image
      String personName,
      String contactPhone,
      GeoPoint location) async {

    addLostPet(petType, breed, color, age, gender, collar, foundPlace, personName, contactPhone, location);
  }

  void _addLostPet() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NewLostPet(addLostPet: _addNewLostPetToDatabase, formType: "found")));
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
    DateTime newDate = DateTime.now();

    return FirebaseFirestore.instance.collection('foundPets').add({
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
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rescue Paws"),
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        actions: [
          ElevatedButton(
            onPressed: () => _addLostPet(),
            style: const ButtonStyle(
                backgroundColor:
                MaterialStatePropertyAll<Color>(Colors.limeAccent)),
            child: const Text(
              "Add found pet",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _itemsCollection.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            // If the data is ready, convert it to a list of MyItem
            List<Post> items = snapshot.data!.docs.map((DocumentSnapshot doc) {
              return Post.fromMap(doc.data() as Map<String, dynamic>);
            }).toList();

            // Now you have a list of items, you can use it as needed
            return GridView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  // onTap: () {
                  //   _launchGoogleMaps(items[index].location);
                  // },
                    child: Card(
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Display Exam details
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    items[index].petType,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('yyyy-MM-dd HH:mm').format(items[index].date),
                                    style: const TextStyle(fontSize: 20, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                );
              },
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
            );
          }),
    );
  }
}
