import 'package:flutter/material.dart';
import 'package:girls_grivince/Models/UserModel.dart';
import 'package:girls_grivince/Models/UserModel/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:girls_grivince/Home/complaint.dart';
import 'package:girls_grivince/Home/help.dart';
import 'package:girls_grivince/Home/notification.dart';
import 'package:girls_grivince/Home/profile.dart';
import 'package:girls_grivince/Home/sos.dart';
import 'package:girls_grivince/Home/status.dart';
import 'package:girls_grivince/Home/support.dart';
import 'package:girls_grivince/Models/DataProvider.dart';
import 'package:girls_grivince/widgets/categorybtn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  @override
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await getToken();
      if (token != null) {
        // Set the token in the DataProvider
        Provider.of<DataProvider>(context, listen: false).setToken(token);

        // Fetch data using the token
        Provider.of<DataProvider>(context, listen: false).fetchData();
      }
    });
    // Fetch user details and set username
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user != null) {
      Provider.of<UserModel>(context, listen: false).setUserDetails(
        name: userProvider.user!.username,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final userData = Provider.of<UserModel>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    final boxDecoration = BoxDecoration(
      color: Color.fromRGBO(169, 61, 231, 0.91),
      borderRadius: BorderRadius.circular(50),
    );

    final iconPadding = const EdgeInsets.all(8.0);

    List<Map<String, dynamic>> categories = [
      {
        'title': "SOS",
        'imagePath': 'assets/img/sos.png',
        'function': () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (builder) => Sos()),
          );
        },
      },
      {
        'title': "Complaint",
        'imagePath': 'assets/img/complaint.png',
        'function': () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (builder) =>
                    Complaint(id: user != null ? user.id : "")),
          );
        },
      },
      {
        'title': "Complaint Status",
        'imagePath': 'assets/img/status.png',
        'function': () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (builder) => Status()),
          );
        },
      },
      {
        'title': "Support",
        'imagePath': 'assets/img/support.png',
        'function': () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (builder) => Support()),
          );
        },
      },
    ];

    Widget _buildActionButton({
      required IconData icon,
      required Function onTap,
      required Color color,
    }) {
      return GestureDetector(
        onTap: () => onTap(),
        child: Container(
          decoration: boxDecoration,
          child: Padding(
            padding: iconPadding,
            child: Icon(icon, color: color),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/img/loginhome.png',
              fit: BoxFit.cover,
            ),
          ),
          // Main content
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 60.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30),
                Text(
                  "Welcome",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(height: 10),
                Text(
                  userData.name,
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(height: 70),
                // Category buttons
                Expanded(
                  child: GridView.builder(
                    itemCount: categories.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemBuilder: (context, index) {
                      return Categorybtn(
                        title: categories[index]['title'],
                        imagePath: categories[index]['imagePath'],
                        function: categories[index]['function'],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Loading indicator
          if (dataProvider.isLoading)
            Center(
              child: CircularProgressIndicator(color: Colors.transparent),
            ),
          // Notifications button
          Positioned(
            bottom: 80,
            right: 20,
            child: _buildActionButton(
                icon: Icons.notifications,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (builder) => Alerts()),
                  );
                },
                color: Colors.yellow),
          ),
          // Profile button
          Positioned(
            bottom: 20,
            right: 20,
            child: _buildActionButton(
                icon: Icons.person,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (builder) => Profile(),
                    ),
                  );
                },
                color: Colors.white),
          ),
          // Help button
          Positioned(
            bottom: 20,
            left: 20,
            child: _buildActionButton(
                icon: Icons.help,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (builder) => Help()),
                  );
                },
                color: Colors.white),
          ),
        ],
      ),
    );
  }
}
