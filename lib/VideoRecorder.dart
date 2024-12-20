import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoRecorderScreen extends StatefulWidget {
  @override
  _VideoRecorderScreenState createState() => _VideoRecorderScreenState();
}

class _VideoRecorderScreenState extends State<VideoRecorderScreen> {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _timerValue = 10;
  late Future<void> _startRecordingFuture;
  bool _isRecording = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeCameras();
  }

  // Get the token from SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Initialize the camera and check permissions
  Future<void> _initializeCameras() async {
    if (await _requestPermissions()) {
      try {
        _cameras = await availableCameras();
        if (_cameras.isNotEmpty) {
          _initializeCameraController(_cameras[0]);
        } else {
          _showMessage('No cameras available on this device.');
        }
      } catch (e) {
        _showMessage('Error initializing cameras: $e');
      }
    } else {
      _showMessage('Camera permission denied.');
    }
  }

  // Request camera permissions
  Future<bool> _requestPermissions() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      _showMessage('Camera permission denied. Please enable it in settings.');
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    return false;
  }

  // Initialize the camera controller
  void _initializeCameraController(CameraDescription cameraDescription) async {
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
    );

    try {
      await cameraController.initialize();
      setState(() {
        _controller = cameraController;
      });
      _startRecording();
    } catch (e) {
      _showMessage('Error initializing camera: $e');
    }
  }

  // Start video recording automatically
  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      _showMessage('Camera is not initialized.');
      return;
    }

    if (_controller!.value.isRecordingVideo) {
      _showMessage('Already recording.');
      return;
    }

    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
      _showMessage('Video recording started.');
      _startTimer();
    } catch (e) {
      _showMessage('Error starting video recording: $e');
    }
  }

  // Stop video recording after 10 seconds and call _sendLocationToApi
  Future<void> _stopRecording() async {
    if (_controller == null || !_controller!.value.isRecordingVideo) {
      _showMessage('No video recording in progress.');
      return;
    }

    try {
      final XFile videoFile = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
      });
      _showMessage('Video recorded to: ${videoFile.path}');

      // Get the location (example coordinates, you can replace with actual location data)
      Position position = await _getLocation();

      // Call the API to send video and location
      _sendLocationToApi(position.latitude, position.longitude, videoFile.path);
    } catch (e) {
      _showMessage('Error stopping video recording: $e');
    }
  }

  // Show message in a snackbar
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Timer logic to stop recording after 10 seconds
  void _startTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (_isRecording && _timerValue > 0) {
        setState(() {
          _timerValue--;
        });
        _startTimer();
      } else if (_timerValue == 0) {
        _stopRecording();
        setState(() {
          isLoading = true;
        });
      }
    });
  }

  // Create a blinking red dot widget
  Widget _buildBlinkingDot() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      height: 10,
      width: 10,
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      curve: Curves.easeInOut,
      child: null,
    );
  }

  // Get the current location
  Future<Position> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied.");
      }
    }
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Function to send video and location to the API
  Future<void> _sendLocationToApi(
      double latitude, double longitude, String path) async {
    final token = await getToken();
    var url = Uri.parse(
        'https://tech-hackathon-glowhive.onrender.com/api/user/sos/submit');

    try {
      if (isLoading) return;
      // Show "Video & Location is sending..." dialog
      setState(() {
        isLoading = false;
      });
      _showPopup("Video & Location is sending...", autoClose: true);

      // Read the video file as bytes
      final File videoFile = File(path);
      final List<int> videoBytes = await videoFile.readAsBytes();
      final videoBlob = base64Encode(videoBytes);

      // Create the request body
      final body = jsonEncode({
        "location": [latitude, longitude], // Send location as a JSON array
        "video": videoBlob, // Send video as a base64 string
      });

      // Make a POST request
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      // Handle the response
      if (response.statusCode == 200) {
        _showPopup("Video & Location sent successfully!", autoClose: true);
      } else {
        final responseBody = jsonDecode(response.body);
        _showPopup(
            "Failed to send Video & Location: ${response.statusCode} - ${responseBody['message']}",
            autoClose: true);
      }
    } catch (e) {
      _showPopup("Error occurred: $e");
    } finally {
      _cleanupRecordingFile(); // Cleanup the video file (if necessary)
    }
  }

  void _showPopup(String message, {bool autoClose = false}) {
    if (isLoading) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        if (autoClose) {
          Future.delayed(Duration(seconds: 2), () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          });
        }
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        );
      },
    );
  }

  // Cleanup recording file (if needed)
  void _cleanupRecordingFile() {
    // If you need to clean up temporary files, you can add the logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Camera preview takes up the whole screen
          if (_controller != null && _controller!.value.isInitialized)
            CameraPreview(_controller!),

          if (isLoading)

            // Timer and blinking red dot at the bottom
            if (_isRecording)
              Positioned( 
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Blinking red dot
                    _buildBlinkingDot(),
                    // Timer display
                    Text(
                      ' $_timerValue sec',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
