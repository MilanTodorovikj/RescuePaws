import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'map_screen.dart';



class NewLostPet extends StatefulWidget {
  final Function addLostPet;
  final String formType;

  const NewLostPet({Key? key, required this.addLostPet, required this.formType}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    // Initialize the selected location to a default value or null
    _selectedLocation = GeoPoint(37.7749, -122.4194); // Default: San Francisco
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
    );

    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(labelText: 'Pet type'),
              controller: _petTypeController,
              onSubmitted: (_) => _submitData(),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Breed'),
              controller: _breedController,
              onSubmitted: (_) => _submitData(),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Color/Pattern'),
              controller: _colorController,
              onSubmitted: (_) => _submitData(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
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
              decoration: const InputDecoration(labelText: 'Found place'),
              controller: _foundPlaceController,
              onSubmitted: (_) => _submitData(),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Person name'),
              controller: _personNameController,
              onSubmitted: (_) => _submitData(),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Contact phone'),
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
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).textTheme.button?.color,
                backgroundColor: Theme.of(context).secondaryHeaderColor,
                fixedSize: const Size.fromWidth(500),
              ),
              onPressed: _submitData,
              child: Text(
                'Add '+ this.widget.formType + ' Pet',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

          ],
        ),
      ),
    );
  }
}