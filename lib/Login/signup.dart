import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:girls_grivince/Login/login.dart';
import 'package:girls_grivince/Login/password.dart';
import 'package:girls_grivince/widgets/button.dart';
import 'package:girls_grivince/widgets/otheroptions.dart';

class Signup extends StatefulWidget {
  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool isResendEnabled = false;
  int resendCountdown = 60;
  Timer? resendTimer;

  Future<void> sendOtp(String email) async {
    final url = Uri.parse(
        "https://tech-hackathon-glowhive.onrender.com/api/user/send/otp/");
    try {
      final response = await http.post(
        url,
        body: jsonEncode({"email": email}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        showOtpDialog(email);
      } else {
        final data = jsonDecode(response.body);
        showSnackbar(data['message'] ?? "Email already exists.");
      }
    } catch (error) {
      showSnackbar("Failed to send OTP. Please try again later.");
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    final url = Uri.parse(
        "https://tech-hackathon-glowhive.onrender.com/api/user/verify/otp");
    try {
      final response = await http.post(
        url,
        body: jsonEncode({"email": email, "otp": otp}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Password(
              name: usernameController.text.trim(),
              email: email,
              phone: phoneController.text.trim(),
            ),
          ),
        );
      } else {
        final data = jsonDecode(response.body);
        showSnackbar(data['message'] ?? "Invalid OTP. Please try again.");
      }
    } catch (error) {
      showSnackbar("Failed to verify OTP. Please try again later.");
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void showOtpDialog(String email) {
    final List<TextEditingController> otpControllers =
        List.generate(6, (index) => TextEditingController());
    final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Enter OTP"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (index) => Expanded(
                  // Use Expanded to make each TextField take equal width
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4.0), // Add padding between the fields
                    child: TextField(
                      controller: otpControllers[index],
                      focusNode: focusNodes[index],
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        counterText: "",
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.length == 1 && index < 5) {
                          FocusScope.of(context)
                              .requestFocus(focusNodes[index + 1]);
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context)
                              .requestFocus(focusNodes[index - 1]);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              String otp = otpControllers.map((e) => e.text).join();
              if (otp.length == 6) {
                Navigator.of(context).pop();
                verifyOtp(email, otp);
              } else {
                showSnackbar("Please enter a valid 6-digit OTP.");
              }
            },
            child: Text("Verify"),
          ),
        ],
      ),
    );
  }

  void validateAndSubmit() async {
    final List<String> errors = [];

    // Validate username
    if (usernameController.text.trim().isEmpty) {
      errors.add('Name is required');
    }

    // Validate email
    final email = emailController.text.trim();
    if (email.isEmpty) {
      errors.add('Email is required');
    } else if (!RegExp(r"^[nsro]\d{6}@rguktn\.ac\.in$").hasMatch(email)) {
      errors.add('Enter a valid RGUKT email (e.g., n123456@rguktn.ac.in)');
    }

    // Validate phone number
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      errors.add('Phone number is required');
    } else if (!RegExp(r"^\d{10}$").hasMatch(phone)) {
      errors.add('Enter a valid phone number');
    }

    if (errors.isNotEmpty) {
      // Show all errors in a Snackbar
      showSnackbar(errors.join('\n'));
      return;
    }

    setState(() {
      isLoading = true;
    });

    await sendOtp(email);

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    resendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/loginhome.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
              child: SizedBox(
                height: height,
                width: width,
                child: Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, top: 60),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 150),
                        Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 40),
                        Text(
                          'Name:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'Enter your name',
                          ),
                          controller: usernameController,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Email:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'Enter your email',
                          ),
                          controller: emailController,
                        ),
                        SizedBox(height: 30),
                        Text(
                          'Phone Number:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'Enter your Phone num',
                          ),
                          controller: phoneController,
                        ),
                        SizedBox(height: 30),
                        Button(
                          text: isLoading ? 'Loading..' : 'Next',
                          function: validateAndSubmit,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Otheroptions(
                          text1: 'Already have an account? ',
                          text2: 'Log In',
                          function: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => Login(),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
