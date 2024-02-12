import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Subscriber{
  String playerId;

  Subscriber({
    required this.playerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'playerId': playerId,
    };
  }

  factory Subscriber.fromMap(Map<String, dynamic>? map) {
    return Subscriber(
      playerId: map?['playerId'] as String,
    );
  }
}