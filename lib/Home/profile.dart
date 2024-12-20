import 'package:flutter/material.dart';
import 'package:girls_grivince/Login/loginMain.dart';
import 'package:girls_grivince/Models/UserModel.dart';
import 'package:girls_grivince/Models/UserModel/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _isEditingName = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final userModel = Provider.of<UserModel>(context, listen: false);
    _nameController = TextEditingController(text: userModel.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildHeader(context),
                      _buildProfilePicture(userModel.name),
                    ],
                  ),
                  const SizedBox(height: 90),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      children: [
                        _buildEditableProfileField(
                          icon: Icons.person,
                          label: 'Name',
                          controller: _nameController,
                          isEditable: _isEditingName,
                          onEditPressed: () {
                            setState(() {
                              if (_isEditingName) {
                                userModel.updateName(_nameController.text);
                              }
                              _isEditingName = !_isEditingName;
                            });
                          },
                        ),
                        const SizedBox(height: 30),
                        _buildProfileField(
                          icon: Icons.email,
                          label: 'Email',
                          value: user != null
                              ? user.email
                              : '', // Add `email` to UserModel
                        ),
                        const SizedBox(height: 30),
                        _buildProfileField(
                          icon: Icons.call,
                          label: 'Mobile Number',
                          value: user != null
                              ? user.phone
                              : '', // Add `phone` to UserModel
                        ),
                        const SizedBox(height: 30),
                        _buildSignOutButton(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 150,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(169, 61, 231, 0.91),
            Color.fromRGBO(169, 61, 231, 0.91)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
        ),
      ),
      child: Positioned(
        top: 50,
        left: 20,
        right: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop(); // This will pop the current screen
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child:
                    const Icon(Icons.arrow_back, size: 30, color: Colors.white),
              ),
            ),
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 30), // Placeholder for spacing
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture(String name) {
    return Positioned(
      top: 100,
      left: MediaQuery.of(context).size.width / 2 - 50,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor:
                Colors.primaries[name.hashCode % Colors.primaries.length],
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableProfileField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool isEditable,
    required VoidCallback onEditPressed,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.purple),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              isEditable
                  ? TextField(
                      controller: controller,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(
                      controller.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onEditPressed,
          child: Icon(
            isEditable ? Icons.check : Icons.edit,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.purple),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(169, 61, 231, 0.21),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () async {
          // Clear the token from SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('auth_token');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Loginmain()),
            (route) => false,
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout, color: Colors.black),
            SizedBox(width: 8),
            Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
