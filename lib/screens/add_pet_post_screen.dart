import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
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
  GeoPoint? _selectedLocation;
  GeoPoint? _defaultLocation;
  String _selectedGender = "";
  String _selectedAge = "";
  bool _collar = true;
  var firstCamera;
  var image;
  var image_url;
  String _address = "";

  @override
  void initState() {
    super.initState();
    this.initCameras();
    _selectedLocation = _defaultLocation =
        GeoPoint(37.7749, -122.4194); // Default: San Francisco
  }

  Future<void> initCameras() async {
    final cameras = await availableCameras();
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
        _getLocationInfo(
            selectedLocation.latitude, selectedLocation.longitude);
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

  void _getLocationInfo(double latitude, double longitude) async {
    List<geocoding.Placemark> placemarks =
    await geocoding.placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      geocoding.Placemark nearestPlace = placemarks.first;
      String subLocality = nearestPlace.subLocality ?? '';
      String locality = nearestPlace.locality ?? '';
      String country = nearestPlace.country ?? '';
      String administrativeArea  = nearestPlace.administrativeArea ?? '';
      String postalCode = nearestPlace.postalCode ?? '';
      String street = nearestPlace.street ?? '';

      String address = "${street}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";

      print('Location Information:\n$address');

      setState(() {
        _address = address ?? '';
      });
    }
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

      if (imageFile != null) {
        await _uploadImageToStorage(imageFile);

        setState(() {
          image = Image.file(File(imageFile.path));
        });
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
          margin: EdgeInsets.symmetric(horizontal: 10),
          elevation: 5,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Container(
                        child: const Text(
                          'Pet type:',
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: TextField(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                              ),
                              hintText: '',
                              fillColor: Color.fromRGBO(209, 222, 233, 1.0),
                              filled: true,
                            ),
                            controller: _petTypeController,
                            onSubmitted: (_) => _submitData(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Container(
                        child: const Text(
                          'Breed:',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: TextField(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                              ),
                              hintText: '',
                              fillColor: Color.fromRGBO(209, 222, 233, 1.0),
                              filled: true,
                            ),
                            controller: _breedController,
                            onSubmitted: (_) => _submitData(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Container(
                        child: const Text(
                          'Color/Pattern:',
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: TextField(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                              ),
                              hintText: '',
                              fillColor: Color.fromRGBO(209, 222, 233, 1.0),
                              filled: true,
                            ),
                            controller: _colorController,
                            onSubmitted: (_) => _submitData(),
                          ),
                        ),
                      ),
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
                                  activeColor: Theme.of(context).primaryColor,
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
                                activeColor: Theme.of(context).primaryColor,
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
                                  activeColor: Theme.of(context).primaryColor,
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
                                activeColor: Theme.of(context).primaryColor,
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
                                  activeColor: Theme.of(context).primaryColor,
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
                                activeColor: Theme.of(context).primaryColor,
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
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Container(
                        child: const Text(
                          'Found place:',
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: TextField(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                              ),
                              hintText: '',
                              fillColor: Color.fromRGBO(209, 222, 233, 1.0),
                              filled: true,
                            ),
                            controller: _foundPlaceController,
                            onSubmitted: (_) => _submitData(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Container(
                        child: const Text(
                          'Person name:',
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: TextField(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                              ),
                              hintText: '',
                              fillColor: Color.fromRGBO(209, 222, 233, 1.0),
                              filled: true,
                            ),
                            controller: _personNameController,
                            onSubmitted: (_) => _submitData(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Container(
                        child: const Text(
                          'Contact phone:',
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: TextField(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                              ),
                              hintText: '',
                              fillColor: Color.fromRGBO(209, 222, 233, 1.0),
                              filled: true,
                            ),
                            controller: _contactPhoneController,
                            onSubmitted: (_) => _submitData(),
                          ),
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
                          child: Text(
                            _selectedLocation != null &&
                                    _selectedLocation != _defaultLocation
                                ? 'Select Another Location'
                                : 'Select Location',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedLocation != null &&
                      _selectedLocation != _defaultLocation)
                    Row(
                      children: [
                        Text('Selected location: '),
                        Flexible( // Wrap the address in a Flexible widget
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Latitude: ${_selectedLocation!.latitude.toStringAsFixed(5)}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Longitude: ${_selectedLocation!.longitude.toStringAsFixed(5)}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Address: $_address',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                  Row(
                    children: [
                      const Text(
                        'Take a picture:',
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
                  if (image != null)
                    Row(
                      children: [
                        Text('Uploaded image: '), // Text widget added
                        Container(
                          width: 200,
                          height: 200,
                          child: image,
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
        )),
      ),
    );
  }
}
