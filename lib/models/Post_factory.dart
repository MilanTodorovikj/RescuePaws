import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Post.dart';

abstract class PostFactory {
  Post createLostPet({
    required String petType,
    required String breed,
    required String color,
    required String age,
    required String gender,
    required bool collar,
    required String foundPlace,
    required String personName,
    required String contactPhone,
    required GeoPoint location,
    required String imagePath,
  });

  Post createFoundPet({
    required String petType,
    required String breed,
    required String color,
    required String age,
    required String gender,
    required bool collar,
    required String foundPlace,
    required String personName,
    required String contactPhone,
    required GeoPoint location,
    required String imagePath,
  });
}
