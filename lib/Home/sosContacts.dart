import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:girls_grivince/Models/DataProvider.dart';
import 'package:girls_grivince/Models/SupportStaffModel.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Soscontacts extends StatefulWidget {
  @override
  _SoscontactsState createState() => _SoscontactsState();
}

class _SoscontactsState extends State<Soscontacts> {
  List<dynamic> globalSOS = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    dataProvider.fetchData();
    fetchSOSData();
  }

  Future<void> fetchSOSData() async {
    try {
      final response = await http.get(
        Uri.parse('https://tech-hackathon-glowhive.onrender.com/api/sos'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          globalSOS = data['globalSOS'] ?? [];
          isLoading = false;
        });
      } else {
        // Handle the error if the API fails
        setState(() {
          isLoading = false;
        });
        print('Failed to load SOS data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                'assets/img/home2.png',
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 50,
                left: 20,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        'assets/img/arrow2.png',
                        width: 41,
                        height: 33,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'SOS Contacts',
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
                 'SOS Contacts',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
                SizedBox(height: 0),
              ],
            ),
          ),
          Expanded(
            child:  ListView.builder(
                    itemCount: globalSOS.length,
                    itemBuilder: (context, index) {
                      final sosContact = globalSOS[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            sosContact['name'] ?? 'No Name',
                            style: TextStyle(
                              color: Color.fromRGBO(169, 61, 231, 0.91),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sosContact['email'] ?? 'No Email',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
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

  _buildProviderData(List<SupportStaffModel> supportStaff){
    return ListView.builder(
                    itemCount: globalSOS.length,
                    itemBuilder: (context, index) {
                      final sosContact = globalSOS[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            sosContact['name'] ?? 'No Name',
                            style: TextStyle(
                              color: Color.fromRGBO(169, 61, 231, 0.91),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sosContact['email'] ?? 'No Email',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
  }
}
