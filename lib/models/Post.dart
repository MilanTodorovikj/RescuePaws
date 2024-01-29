import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Post {
  String petType;
  String breed;
  String color;
  String age;
  String gender;
  bool collar;
  String foundPlace;
  GeoPoint location;
  //image
  String personName;
  String contactPhone;
  DateTime date;


  Post({
    required this.petType,
    required this.breed,
    required this.color,
    required this.age,
    required this.gender,
    required this.collar,
    required this.foundPlace,
    required this.personName,
    required this.contactPhone,
    required this.date,
    required this.location,
  });

  // Add a named constructor for creating an Exam from a Map
  factory Post.fromMap(Map<String, dynamic>? map) {
    if (map == null ||
        map['petType'] == null ||
        map['date'] == null
        // ||
        // map['location'] == null
    ) {
      // Handle null values or missing keys, return a default Post object or throw an error
      return Post(
        petType: 'Default pet type',
        breed: 'Default pet breed',
        color: 'Default pet color',
        age: 'Default pet age',
        gender: 'Default pet gender',
        collar: true,
        foundPlace: 'Default pet foundPlace',
        personName: 'Default pet personName',
        contactPhone: 'Default pet contactPhone',
        date: DateTime.now(),
        location: GeoPoint(0.0, 0.0),
      );
    }

    return Post(
      petType: map['petType'] as String,
      breed: map['breed'] as String,
      color: map['color'] as String,
      age: map['age'] as String,
      gender: map['gender'] as String,
      collar: map['collar'] as bool,
      foundPlace: map['foundPlace'] as String,
      personName: map['personName'] as String,
      contactPhone: map['contactPhone'] as String,
      date: (map['date'] as Timestamp).toDate(),
      location: map['location'] as GeoPoint,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'petType': petType,
      'breed': breed,
      'color': color,
      'age': age,
      'gender': gender,
      'collar': collar,
      'foundPlace': foundPlace,
      'personName': personName,
      'contactPhone': contactPhone,
      'date': date,
      'location': location,
    };
  }
}