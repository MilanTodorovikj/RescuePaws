import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PetCard extends StatelessWidget {
  final String petType;
  final String breed;
  final String color;
  final String age;
  final String gender;
  final bool hasCollar;
  final String foundBy;
  final String contact;
  final String imageUrl;
  final VoidCallback onLocationPressed;

  const PetCard({
    Key? key,
    required this.petType,
    required this.breed,
    required this.color,
    required this.age,
    required this.gender,
    required this.hasCollar,
    required this.foundBy,
    required this.contact,
    required this.imageUrl,
    required this.onLocationPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromRGBO(230,235,245,1.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            // Pet image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Pet type and breed
                    Text(
                      '$petType - $breed',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    // Pet details
                    Text(
                      '$color, $age, $gender, ${hasCollar ? "has a collar" : "no collar"}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    // Found by
                    Text(
                      'Found by: $foundBy',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    // Contact
                    Text(
                      'Contact: $contact',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Location button
            IconButton(
              icon: Icon(Icons.location_on, color: Color.fromRGBO(27, 53, 86, 1.0),),
              onPressed: onLocationPressed,
            ),
          ],
        ),
      ),
    );
  }
}