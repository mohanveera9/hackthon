import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Emergency extends StatefulWidget {
  @override
  _EmergencyState createState() => _EmergencyState();
}

class _EmergencyState extends State<Emergency> {
  final List<Map<String, String>> contacts = [
    {"title": "Police", "number": "100"},
    {"title": "Child Helpline", "number": "1098"},
    {"title": "Women Helpline", "number": "181"},
    {"title": "Fire Service", "number": "101"},
    {"title": "Ambulance", "number": "108"},
    {"title": "Road Accident", "number": "1073"},
    {"title": "National Emergency", "number": "112"},
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            children: [
              // Background image
              Image.asset(
                'assets/img/home2.png',
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
              // Overlay for back button and title
              Positioned(
                top: 50,
                left: 20,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context), // Navigates back
                      child: Image.asset(
                        'assets/img/arrow2.png',
                        width: 41,
                        height: 33,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Emergency Contacts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Please don't hesitate to reach us out if you have any queries",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                SizedBox(height: 0),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      contacts[index]["title"]!,
                      style: TextStyle(
                        color: Color.fromRGBO(169, 61, 231, 0.91),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      contacts[index]["number"]!,
                      style: TextStyle(fontSize: 16),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.call, color: Colors.black),
                      onPressed: () {
                         final phoneNumber = contacts[index]["number"]!;
                        launch('tel:$phoneNumber');
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}