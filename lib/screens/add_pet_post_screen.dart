import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'camera_screen.dart';
import 'map_screen.dart';

class NewLostPet extends StatefulWidget {
  final Function addLostPet;
  final String formType;

  const NewLostPet({Key? key, required this.addLostPet, required this.formType})
      : super(key: key);

  @override
  _NewLostPetState createState() => _NewLostPetState();
}

class _NewLostPetState extends State<NewLostPet> {
  final _petTypeController = TextEditingController();
  final _breedController = TextEditingController();
  final _colorController = TextEditingController();
  final _foundPlaceController = TextEditingController();
  final _personNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  GeoPoint? _selectedLocation; // Store the selected location
  String _selectedGender = "";
  String _selectedAge = "";
  bool _collar = true;
  var firstCamera;
  var image;
  var image_url;

  @override
  void initState() {
    super.initState();

    this.initCameras();

    // Initialize the selected location to a default value or null
    _selectedLocation = GeoPoint(37.7749, -122.4194); // Default: San Francisco
  }

  Future<void> initCameras() async {
    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

// Get a specific camera from the list of available cameras.
    firstCamera = cameras.first;
  }

  void _selectLocation() async {
    LocationData currentLocation = await _getCurrentLocation();
    GeoPoint? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          currentLocation: GeoPoint(
            currentLocation.latitude!,
            currentLocation.longitude!,
          ),
        ),
      ),
    );

    if (selectedLocation != null) {
      setState(() {
        _selectedLocation = selectedLocation;
      });
    }
  }

  Future<LocationData> _getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw Exception('Location permission denied.');
      }
    }

    return await location.getLocation();
  }

  void _submitData() {
    final petType = _petTypeController.text;
    final breed = _breedController.text;
    final color = _colorController.text;
    final foundPlace = _foundPlaceController.text;
    final personName = _personNameController.text;
    final contactPhone = _contactPhoneController.text;

    // Combine the image information with other form data
    // For example, you can include the image path or URL in the Firebase data
    Map<String, dynamic> formData = {
      // ... existing form data ...
      'imagePath': image_url, // Replace with the appropriate image information
    };

    if (petType.isEmpty ||
        breed.isEmpty ||
        color.isEmpty ||
        foundPlace.isEmpty ||
        personName.isEmpty ||
        contactPhone.isEmpty ||
        _selectedGender.isEmpty ||
        _selectedAge.isEmpty ||
        _selectedLocation == null) {
      return;
    }

    widget.addLostPet(
      petType,
      breed,
      color,
      _selectedAge,
      _selectedGender,
      _collar,
      foundPlace,
      personName,
      contactPhone,
      _selectedLocation!,
      formData,
    );

    Navigator.of(context).pop();
  }

  void _openCamera() async {
    try {
      final imageFile = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TakePictureScreen(camera: firstCamera),
        ),
      );

      // Handle the captured image (save it to Firebase Storage or perform any other actions)
      if (imageFile != null) {
        await _uploadImageToStorage(imageFile);
      }
    } catch (e) {
      print("Error opening camera: $e");
    }
  }

  Future<void> _uploadImageToStorage(XFile imageFile) async {
    try {
      String imageName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
      FirebaseStorage.instance.ref().child('images/$imageName.jpg');

      File file = File(imageFile.path);
      await storageReference.putFile(file);
      String imageUrl = await storageReference.getDownloadURL();

      // Now you have the imageUrl, you can use it as needed (e.g., save it to Firestore)
      print("Image uploaded to Firebase Storage: $imageUrl");
      image_url = imageUrl;

      // You can set the 'imagePath' variable to imageUrl when calling _submitData
      setState(() {
        image = Image.network(imageUrl);
      });
    } catch (e) {
      print("Error uploading image to Firebase Storage: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorSchemeSeed: const Color.fromRGBO(27, 53, 86, 1.0),
          useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
            title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text(
                'Add pet ',
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
            ]),
        ),
        //AppBar(title: const Text('Add '+ this.widget.formType + ' Pet',)),
        body: SingleChildScrollView(
          child: Card(
            elevation: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    TextField(
                      decoration: const InputDecoration(
                        // suffixIcon: Icon(Icons.clear),
                        labelText: 'Pet type',
                        hintText: '',
                        // filled: true,
                      ),
                      controller: _petTypeController,
                      onSubmitted: (_) => _submitData(),
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Breed',
                        hintText: '',
                      ),
                      controller: _breedController,
                      onSubmitted: (_) => _submitData(),
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Color/Pattern',
                        hintText: '',
                      ),
                      controller: _colorController,
                      onSubmitted: (_) => _submitData(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            const Text('Age:'),
                            Radio(
                              value: 'Young',
                              groupValue: _selectedAge,
                              onChanged: (value) {
                                setState(() {
                                  _selectedAge = value.toString();
                                });
                              },
                            ),
                            Text('Young'),
                          ],
                        ),
                        Row(
                          children: [
                            Radio(
                              value: 'Mature',
                              groupValue: _selectedAge,
                              onChanged: (value) {
                                setState(() {
                                  _selectedAge = value.toString();
                                });
                              },
                            ),
                            Text('Mature'),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            const Text('Gender:'),
                            Radio(
                              value: 'Male',
                              groupValue: _selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value.toString();
                                });
                              },
                            ),
                            Text('Male'),
                          ],
                        ),
                        Row(
                          children: [
                            Radio(
                              value: 'Female',
                              groupValue: _selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value.toString();
                                });
                              },
                            ),
                            Text('Female'),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            const Text('Collar:'),
                            Radio(
                              value: true,
                              groupValue: _collar,
                              onChanged: (value) {
                                setState(() {
                                  _collar = value!;
                                });
                              },
                            ),
                            Text('Yes'),
                          ],
                        ),
                        Row(
                          children: [
                            Radio(
                              value: false,
                              groupValue: _collar,
                              onChanged: (value) {
                                setState(() {
                                  _collar = value!;
                                });
                              },
                            ),
                            Text('No'),
                          ],
                        ),
                      ],
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Found place',
                        hintText: '',
                      ),
                      controller: _foundPlaceController,
                      onSubmitted: (_) => _submitData(),
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Person name',
                        hintText: '',
                      ),
                      controller: _personNameController,
                      onSubmitted: (_) => _submitData(),
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Contact phone',
                        hintText: '',
                      ),
                      controller: _contactPhoneController,
                      onSubmitted: (_) => _submitData(),
                    ),
                    ElevatedButton(
                      onPressed: _selectLocation,
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        onPrimary: Colors.white,
                        fixedSize: const Size.fromWidth(500),
                      ),
                      child: const Text(
                        'Select Location',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _openCamera,
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        onPrimary: Colors.white,
                        fixedSize: const Size.fromWidth(500),
                      ),
                      child: const Text(
                        'Open Camera',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton( // samo za izgled
                      onPressed: () {
                        // Combine the image information with other form data and submit to Firebase
                        _submitData();
                      },
                      child: Text('Submit'),
                    ),
                  ]),
            ),
            // ],
          ),
        ),
      ),
    );
  }
}
