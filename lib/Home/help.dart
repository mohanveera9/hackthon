import 'package:flutter/material.dart';

class Help extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stack for image and header
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
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Image.asset(
                          'assets/img/arrow2.png',
                          height: 35,
                          width: 43,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Help',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Welcome Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(text: 'Welcome to '),
                    TextSpan(
                      text: 'Girls Grievance',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          ', your comprehensive solution for addressing grievances and ensuring safety. '
                          'This app has been designed with simplicity and effectiveness in mind, enabling users to navigate seamlessly and take action whenever needed.',
                    ),
                  ],
                ),
              ),
            ),
            // Features Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Features of the App',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  buildFeature(
                    'Registration',
                    'Start by creating an account through the registration process to securely log in.',
                  ),
                  buildFeature(
                    'File a Complaint',
                    'Navigate to the Complaint Form section to categorize the issue as critical or non-critical. '
                    'Provide incident details to ensure appropriate authorities are notified.',
                  ),
                  buildFeature(
                    'Track Complaints',
                    'Visit the Complaint Status page to track progress, check updates, or resend notifications if necessary.',
                  ),
                  buildFeature(
                    'SOS Feature',
                    'In emergencies, tap the SOS button to initiate a fake call and record audio or video. This is sent to authorities or emergency contacts. '
                    'Predefined gestures like pressing the power button multiple times can activate the SOS feature if the app cannot be accessed.',
                  ),
                  buildFeature(
                    'Complaint History',
                    'Review all past complaints and their current statuses for transparency and accountability.',
                  ),
                  buildFeature(
                    'Notifications',
                    'Stay updated on the progress of your cases or any critical developments.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build feature items
  Widget buildFeature(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 5),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
