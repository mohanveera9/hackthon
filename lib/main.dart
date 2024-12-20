import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:girls_grivince/Home/home.dart';
import 'package:girls_grivince/Login/loginMain.dart';
import 'package:girls_grivince/Models/DataProvider.dart';
import 'package:girls_grivince/Models/UserModel.dart';
import 'package:girls_grivince/Models/UserModel/UserProvider.dart';
import 'package:girls_grivince/Models/UserModel/user.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => DataProvider()),
      ChangeNotifierProvider(create: (context) => UserModel()),
      ChangeNotifierProvider(create: (context) => UserProvider()),

    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        primaryColor: Colors.purple,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashHandler(), // Splash logic handler
    );
  }
}



class SplashHandler extends StatefulWidget {
  const SplashHandler({super.key});

  @override
  State<SplashHandler> createState() => _SplashHandlerState();
}

class _SplashHandlerState extends State<SplashHandler> {
  @override
  void initState() {
    super.initState();
    _checkTokenAndNavigate();
  }

  Future<void> _checkTokenAndNavigate() async {
    try {
      String? token = await _getToken();

      if (token == null) {
        _navigateToLogin();
        return;
      }

      final response = await http.get(
        Uri.parse('https://tech-hackathon-glowhive.onrender.com/api/user/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userJson = data['user'];

        // Parse user data and store it in UserProvider
        User user = User.fromJson(userJson);
        Provider.of<UserProvider>(context, listen: false).setUser(user);

        _navigateToHome();
      } else {
        _navigateToLogin();
      }
    } catch (e) {
      print('Error verifying token: $e');
      _navigateToLogin();
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Loginmain()),
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Home()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(169, 61, 231, 0.91),
      body: Center(
        child: Image.asset('assets/img/mainicon.png'),
      ),
    );
  }
}
