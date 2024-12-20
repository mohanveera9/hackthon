import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:girls_grivince/Models/DataProvider.dart';
import 'package:girls_grivince/Models/SupportStaffModel.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Support extends StatefulWidget {
  @override
  _SupportState createState() => _SupportState();
}

class _SupportState extends State<Support> {
  List<dynamic> supportStaffff = [];
  List<String> safetyVideos = [
    'https://youtu.be/KVpxP3ZZtAc?si=uCrtshNTu6dPWs4X'
    'https://youtu.be/8ZJuf9scD1E?si=O7SHV5nAYSkOOI59',
    'https://youtu.be/cHwdNwGV_-I?si=xCOfINNMNhhothja',
  ];
  bool isLoading = true;

  List<YoutubePlayerController> _controllers = [];

  @override
  void initState() {
    super.initState();
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    dataProvider.fetchData();
    fetchSupportData();

    // Initialize controllers for each video
    for (var url in safetyVideos) {
      final videoID = YoutubePlayer.convertUrlToId(url);
      if (videoID != null) {
        _controllers.add(YoutubePlayerController(
          initialVideoId: videoID,
          flags: const YoutubePlayerFlags(autoPlay: false),
        ));
      }
    }
  }

  Future<void> fetchSupportData() async {
    try {
      final response = await http.get(
        Uri.parse('https://tech-hackathon-glowhive.onrender.com/api/support'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          supportStaffff = data['supportStaff'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print(
            'Failed to load support data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }


  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

 final ScrollController _scrollController = ScrollController();
  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 300, // Scroll by 300 pixels to the left
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 300, // Scroll by 300 pixels to the right
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Section
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
                      'Support',
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
            child: Text(
              "Support Contacts",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Main Content
          Expanded(
            child: isLoading
                ? _buildProviderData(dataProvider.supportStaff)
                : _buildApiData(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Youtube videos",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
           Row(
          children: [
            // Left Scroll Button
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: _scrollLeft,
            ),
            // Video List Section
            Expanded(
              child: SizedBox(
                height: 200, // Adjust height as needed
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: _controllers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
                      child: SizedBox(
                        width: 300, // Fixed width for each video
                        child: YoutubePlayer(
                          controller: _controllers[index],
                          showVideoProgressIndicator: true,
                          onReady: () => debugPrint('Video $index Ready'),
                          bottomActions: [
                            CurrentPosition(),
                            ProgressBar(
                              isExpanded: true,
                              colors: const ProgressBarColors(
                                playedColor: Colors.purple,
                                handleColor: Colors.purple,
                              ),
                            ),
                            PlaybackSpeedButton(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Right Scroll Button
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: _scrollRight,
            ),
          ],
        ),
        ],
      ),
    );
  }

  Widget _buildProviderData(List<SupportStaffModel> supportStaff) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: supportStaff.length,
      itemBuilder: (context, index) {
        final staff = supportStaff[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(
              staff.name,
              style: TextStyle(
                color: Color.fromRGBO(169, 61, 231, 0.91),
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              staff.position,
              style: TextStyle(fontSize: 16),
            ),
            trailing: IconButton(
              icon: Icon(Icons.call, color: Colors.black),
              onPressed: () {
                final phoneNumber = staff.phno;
                if (phoneNumber.isNotEmpty) {
                  launch('tel:$phoneNumber');
                } else {
                  print('Phone number not available');
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildApiData() {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: supportStaffff.length,
      itemBuilder: (context, index) {
        final staff = supportStaffff[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(
              staff['name'] ?? 'No Name',
              style: TextStyle(
                color: Color.fromRGBO(169, 61, 231, 0.91),
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              staff['position'] ?? 'No Position',
              style: TextStyle(fontSize: 16),
            ),
            trailing: IconButton(
              icon: Icon(Icons.call, color: Colors.black),
              onPressed: () {
                final phoneNumber = staff['phno'] ?? '';
                if (phoneNumber.isNotEmpty) {
                  launch('tel:$phoneNumber');
                } else {
                  print('Phone number not available');
                }
              },
            ),
          ),
        );
      },
    );
  }
}
