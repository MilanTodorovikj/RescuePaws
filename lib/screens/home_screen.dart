import 'package:flutter/material.dart';

import 'found_pets_screen.dart';
import 'lost_pets_screen.dart';

void main() {
  runApp(HomeScreen());
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rescue Pets',
      theme: ThemeData(
        primaryColor: Color.fromRGBO(27, 53, 86, 1.0),
      ),
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text(
                'Rescue paws  ',
                style: TextStyle(
                  fontSize: 44,
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
            SizedBox(height: 8),
            const Text(
              '"A dog is a bond between strangers."',
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: Color.fromRGBO(27, 53, 86, 1.0),
              ),
            ),
            SizedBox(height: 20),
            Image.asset(
              "lib/images/home_page.jpg",
              height: 300,
              width: 400,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.pets_outlined, size: 24, color: Colors.white),
              label: Text('Report pet'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LostPetsScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Color.fromRGBO(27, 53, 86, 1.0),
                // Adjust the button color as needed
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.pets_outlined, size: 24, color: Colors.white),
              label: Text('List of pets'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FoundPetsScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Color.fromRGBO(27, 53, 86, 1.0),
                // Adjust the button color as needed
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
