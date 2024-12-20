import 'package:flutter/material.dart';
import 'package:girls_grivince/Models/DataProvider.dart';
import 'package:provider/provider.dart';
import 'package:girls_grivince/Models/NotificationModel.dart';
import 'package:url_launcher/url_launcher.dart';

class Alerts extends StatefulWidget {
  @override
  _AlertsState createState() => _AlertsState();
}

class _AlertsState extends State<Alerts> {
  @override
  void initState() {
    super.initState();
    // Fetch the data when the screen is initialized
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    dataProvider.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    // Access the dataProvider to listen to the state changes
    final dataProvider = Provider.of<DataProvider>(context);

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
                        'Notifications',
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
            // Notifications List
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: dataProvider.isLoading
                  ? Column(
                      children: dataProvider.notifications.map((notification) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: buildNotificationCard(notification),
                        );
                      }).toList(),
                    )
                  : Column(
                      children: dataProvider.notifications.map((notification) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: buildNotificationCard(notification),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNotificationCard(NotificationModel notification) {
    return GestureDetector(
      onTap: () {
        _showNotificationPopup(notification);
      },
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              notification.title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            // Description
            Text(
              notification.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            // Links
            if (notification.links != null && notification.links!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: notification.links!.map<Widget>((link) {
                  return GestureDetector(
                    onTap: () {
                      print('Open link: $link');
                    },
                    child: Text(
                      link,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  );
                }).toList(),
              ),
            SizedBox(height: 8),
            // Sender
            Text(
              'Sent by: ${notification.sender?.username ?? 'Unknown'} (${notification.sender?.role ?? 'No Role'})',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationPopup(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(notification.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  notification.description,
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 12),
                // Links
                if (notification.links != null &&
                    notification.links!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Links:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      ...notification.links!.map((link) {
                        return GestureDetector(
                          onTap: () async {
                            final uri = Uri.tryParse(link);
                            if (uri != null && await canLaunchUrl(uri)) {
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Invalid or unlaunchable URL: $link')),
                              );
                            }
                          },
                          child: Text(
                            link,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                SizedBox(height: 12),
                // Sender
                Text(
                  'Sent by: ${notification.sender?.username ?? 'Unknown'} (${notification.sender?.role ?? 'No Role'})',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
