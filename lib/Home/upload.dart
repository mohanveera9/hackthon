import 'dart:io';

import 'package:flutter/material.dart';

class Upload extends StatefulWidget{
  final File videoFile;
  final String videoPath;
  const Upload({super.key, required this.videoFile, required this.videoPath});

  
  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}