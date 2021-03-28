import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

part 'image_text_detector_view.dart';
part 'camera_text_detector_view.dart';

class TextDetectorView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RaisedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ImageTextDetectorView()));
            },
            child: const Text("Image Text detector"),
          ),
          SizedBox(height: 30,),
          RaisedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CameraTextDetectorView()));
            },
            child: const Text("Camera Text detector"),
          ),
        ],
      ),
    );
  }
}