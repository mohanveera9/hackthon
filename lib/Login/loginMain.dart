import 'package:flutter/material.dart';
import 'package:girls_grivince/Login/login.dart';
import 'package:girls_grivince/Login/signup.dart';
import 'package:girls_grivince/widgets/button.dart';

class Loginmain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
            height: 90,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Image.asset(
              'assets/img/Main.png',
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Login to access exclusive features and share your feedback or complaints effectively.',
                textAlign: TextAlign.center, // Center align the text
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Button(
              text: 'Login',
              function: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (builder) => Login(),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          // Sign-Up Text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (builder) => Signup(),
                    ),
                  );
                },
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(169, 61, 231, 0.91),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
