import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:girls_grivince/VideoRecorder.dart';
import 'package:girls_grivince/Home/emergency.dart';
import 'package:girls_grivince/Home/sosContacts.dart';
import 'package:girls_grivince/Home/soshelp.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:http_parser/http_parser.dart';

class Sos extends StatefulWidget {
  @override
  _SosState createState() => _SosState();
}

class _SosState extends State<Sos> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final AudioRecorder audioRecorder = AudioRecorder();
  bool isRecording = false;
  String? recordingPath;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  //Token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  //Location
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

  //SendLoaction
  Future<void> _sendLocation(double latitude, double longitude) async {
    final token = await getToken();
    var url = Uri.parse(
        'https://tech-hackathon-glowhive.onrender.com/api/user/sos/submit');

    try {
      // Show "Location is sending..." dialog
      _showPopup("Location is sending...");

      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "location": [latitude, longitude],
        }),
      );

      Navigator.pop(context); // Close the popup

      if (response.statusCode == 200) {
        _showPopup("Location sent successfully!", autoClose: true);
      } else {
        _showPopup("Failed to send location: ${response.statusCode}");
      }
    } catch (e) {
      Navigator.pop(context); // Close the popup in case of error
      _showPopup("Error occurred: $e");
    }
  }

  //Send Loaction and audio
  Future<void> _sendLocationToApi(
      double latitude, double longitude, String path) async {
    final token = await getToken();
    var url = Uri.parse(
        'https://tech-hackathon-glowhive.onrender.com/api/user/sos/submit');

    try {
      // Show "Audio & Location is sending..." dialog
      _showPopup("Audio & Location is sending...");

      // Read the audio file as bytes
      final File audioFile = File(path);
      final List<int> audioBytes = await audioFile.readAsBytes();
      final audioBlob = base64Encode(audioBytes);

      // Create the request body
      final body = jsonEncode({
        "location": [latitude, longitude], // Send location as a JSON array
        "audio": audioBlob, // Send audio as a base64 string
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
        _showPopup("Audio & Location sent successfully!", autoClose: true);
      } else {
        final responseBody = jsonDecode(response.body);
        _showPopup(
            "Failed to send Audio & Location: ${response.statusCode} - ${responseBody['message']}",
            autoClose: true);
      }
    } catch (e) {
      _showPopup("Error occurred: $e");
    } finally {
      _cleanupRecordingFile(); // Cleanup the recording file
    }
  }

  //Clean The audio
  void _cleanupRecordingFile() {
    if (recordingPath != null) {
      final file = File(recordingPath!);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }

  //Pop up for Loaction
  void _showPopup(String message, {bool autoClose = false}) {
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

  //Pop pup for counter
  void _showCountdownPopup(VoidCallback onConfirm) {
    int countdown = 3;
    Timer? timer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Start the timer when the dialog is created
            if (timer == null) {
              timer = Timer.periodic(Duration(seconds: 1), (timer) {
                if (countdown == 1) {
                  timer.cancel();
                  if (Navigator.canPop(dialogContext)) {
                    Navigator.pop(dialogContext); // Close the popup safely
                  }
                  onConfirm(); // Trigger the confirmation callback
                } else {
                  setState(() {
                    countdown--;
                  });
                }
              });
            }

            return AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circular Countdown
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$countdown',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cancel Button
                  IconButton(
                    onPressed: () {
                      timer?.cancel(); // Cancel the timer
                      if (Navigator.canPop(dialogContext)) {
                        Navigator.pop(dialogContext); // Close the dialog safely
                      }
                      // Stop recording audio if recording
                      if (isRecording) {
                        audioRecorder.stop();
                        setState(() {
                          isRecording = false;
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    iconSize: 30,
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      // Ensure timer is canceled when the dialog is dismissed
      timer?.cancel();
    });
  }

  //Start Recording
  void _startRecording() async {
    if (await audioRecorder.hasPermission()) {
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      final String filePath = p.join(appDocumentsDir.path, 'recording.mp3');

      await audioRecorder.start(RecordConfig(), path: filePath);

      setState(() {
        isRecording = true;
        recordingPath = filePath;
      });

      Future.delayed(Duration(seconds: 10), () async {
        if (isRecording) {
          String? path = await audioRecorder.stop();
          setState(() {
            isRecording = false;
            recordingPath = path;
          });
          if (recordingPath != null) {
            Position position = await _getLocation();
            await _sendLocationToApi(
                position.latitude, position.longitude, recordingPath!);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color customPurple = Color.fromRGBO(169, 61, 231, 0.91);

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: -20,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: customPurple,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
            ),
          ),
          Positioned(
            left: 30,
            right: 30,
            top: 140,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 2,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                        onTap: () async {
                          if (isRecording) {
                            // Show a message or prevent navigation while recording
                            SnackBar(
                              content: Text(
                                  'Recording in Progree.. Stop recording first'),
                              backgroundColor: Colors.red,
                            );
                          } else {
                            Navigator.of(context)
                                .pop(); // Proceed with navigation
                          }
                        },
                        child: Image.asset(
                          'assets/img/arrow.png',
                          height: 30,
                          width: 30,
                        )),
                    Text(
                      'Girls Grievance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: customPurple,
                      ),
                    ),
                    Icon(
                      Icons.arrow_back,
                      size: 30,
                      color: Colors.transparent,
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 30,
            top: 40,
            child: ClipOval(
              child: Image.asset(
                'assets/img/icon.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            right: 30,
            top: 60,
            child: ClipOval(
              child: Image.asset(
                'assets/img/rgukt.jpg',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: List.generate(4, (index) {
                        double size = 120.0 + (index * 20.0);
                        return Container(
                          height: size * _controller.value,
                          width: size * _controller.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orangeAccent.withOpacity(
                                1 - _controller.value / (index + 1)),
                          ),
                        );
                      }),
                    );
                  },
                ),
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.yellow, Colors.orangeAccent],
                      center: Alignment.center,
                      radius: 0.8,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    Position position = await _getLocation();
                    await _sendLocation(position.latitude, position.longitude);
                  },
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5 - 140,
            left: 30,
            child: _buildGridItem(Icons.video_call, 'Video', customPurple, () {
              _showCountdownPopup(() {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (builder) => VideoRecorderScreen(),
                  ),
                );
              });

              //Position position = await _getLocation();
              //await _sendLocationToApi(position.latitude, position.longitude);
            }),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5 - 140,
            right: 30,
            child: _buildGridItem(
              isRecording ? Icons.stop : Icons.mic,
              'Audio',
              customPurple,
              () async {
                if (isRecording) {
                  audioRecorder.stop();
                  Position position = await _getLocation();
                  _sendLocationToApi(
                      position.latitude, position.longitude, recordingPath!);
                  setState(() {
                    isRecording = false;
                  });
                } else {
                  _showCountdownPopup(() {
                    _startRecording();
                  });
                }
              },
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.5 - 140,
            left: 30,
            child: _buildGridItem(
                Icons.contact_emergency, 'SOS Contacts', customPurple, () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (builder) => Soscontacts(),
                ),
              );
            }),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.5 - 140,
            right: 30,
            child: _buildGridItem(
                Icons.emergency, 'Emergency Contacts', customPurple, () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (builder) => Emergency(),
                ),
              );
            }),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (builder) => Soshelp(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(169, 61, 231, 0.91),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.help_outline,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          // Add your existing widgets below...
        ],
      ),
    );
  }

  Widget _buildGridItem(
      IconData icon, String label, Color color, VoidCallback function) {
    return GestureDetector(
      onTap: function,
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 4,
              spreadRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
