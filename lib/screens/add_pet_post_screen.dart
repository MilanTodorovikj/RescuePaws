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

    // Get the main camera from the list of available cameras.
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

    Map<String, dynamic> formData = {
      'imagePath': image_url,
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

      print("Image uploaded to Firebase Storage: $imageUrl");
      image_url = imageUrl;

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
          scaffoldBackgroundColor: Colors.white,
          useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
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
        body: SingleChildScrollView(
          child: Card(
            elevation: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 10.0),
                          child: const Text(
                            'Pet type:',
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: '',
                            ),
                            controller: _petTypeController,
                            onSubmitted: (_) => _submitData(),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 12.0),
                          child: const Text(
                            'Breed:',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                            child: TextField(
                          decoration: const InputDecoration(
                            hintText: '',
                          ),
                          controller: _breedController,
                          onSubmitted: (_) => _submitData(),
                        ))
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 15.0),
                          child: const Text(
                            'Color/Pattern:',
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                            child: TextField(
                          decoration: const InputDecoration(
                            hintText: '',
                          ),
                          controller: _colorController,
                          onSubmitted: (_) => _submitData(),
                        ))
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: 70,
                              child: Text('Age:'),
                            ),
                            SizedBox(
                              width: 110,
                              child: Row(
                                children: [
                                  Radio(
                                    value: 'Young',
                                    groupValue: _selectedAge,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedAge = value.toString();
                                      });
                                    },
                                  ),
                                  const Text('Young'),
                                ],
                              ),
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
                                const Text('Mature'),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 70,
                              child: Text('Gender:'),
                            ),
                            SizedBox(
                              width: 110,
                              child: Row(
                                children: [
                                  Radio(
                                    value: 'Male',
                                    groupValue: _selectedGender,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedGender = value.toString();
                                      });
                                    },
                                  ),
                                  const Text('Male'),
                                ],
                              ),
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
                                const Text('Female'),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 70,
                              child: const Text('Collar:'),
                            ),
                            SizedBox(
                              width: 110,
                              child: Row(
                                children: [
                                  Radio(
                                    value: true,
                                    groupValue: _collar,
                                    onChanged: (value) {
                                      setState(() {
                                        _collar = value!;
                                      });
                                    },
                                  ),
                                  const Text('Yes'),
                                ],
                              ),
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
                                const Text('No'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 10.0),
                          child: const Text(
                            'Found place:',
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: '',
                            ),
                            controller: _foundPlaceController,
                            onSubmitted: (_) => _submitData(),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 10.0),
                          child: const Text(
                            'Person name:',
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: '',
                            ),
                            controller: _personNameController,
                            onSubmitted: (_) => _submitData(),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 10.0),
                          child: const Text(
                            'Contact phone:',
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: '',
                            ),
                            controller: _contactPhoneController,
                            onSubmitted: (_) => _submitData(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          'Location:',
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _selectLocation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              fixedSize: const Size.fromWidth(500),
                            ),
                            child: const Text(
                              'Select Location',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Last seen:',
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _openCamera,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              fixedSize: const Size.fromWidth(500),
                            ),
                            child: const Text(
                              'Open Camera',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          fixedSize: const Size.fromWidth(300),
                        ),
                        onPressed: () {
                          _submitData();
                        },
                        child: const Text('Submit'),
                      ),
                    )
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
