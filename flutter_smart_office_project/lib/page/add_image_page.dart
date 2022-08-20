import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';


import '../widgets.dart';

enum CaptureState {
  capturing,
  captured,
}

class AddImagePage extends StatefulWidget {
  const AddImagePage({Key? key, required this.camera}) : super(key: key);
  final CameraDescription camera;
  @override
  _AddImagePageState createState() => _AddImagePageState();
}

class _AddImagePageState extends State<AddImagePage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  late final Uint8List? data;
  late final String imageUrl;
  late XFile image;

  CaptureState captureState = CaptureState.capturing;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (captureState) {
      case CaptureState.capturing:
        return Scaffold(
          appBar: AppBar(title: const Text('Take a picture')),
          // You must wait until the controller is initialized before displaying the
          // camera preview. Use a FutureBuilder to display a loading spinner until the
          // controller has finished initializing.
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // If the Future is complete, display the preview.
                    return CameraPreview(_controller);
                  } else {
                    // Otherwise, display a loading indicator.
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 60,
                width: 250,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: const Color(0xffE09E45),
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      textStyle: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    // Take the Picture in a try / catch block. If anything goes wrong,
                    // catch the error.
                    try {
                      // Ensure that the camera is initialized.
                      await _initializeControllerFuture;
                      // Attempt to take a picture and get the file `image`
                      // where it was saved.
                      image = await _controller.takePicture();
                      setState(() {
                        captureState = CaptureState.captured;
                      });
                    } catch (e) {
                      // If an error occurs, log the error to the console.
                      print(e);
                    }
                  },
                  child: Row(
                    children: const [
                      Icon(
                        Icons.camera_rounded,
                        color: Color(0xffffffff),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Click to Capture',
                        style: TextStyle(
                            fontSize: 16,
                            color: Color(0xffffffff),
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      case CaptureState.captured:
        return DisplayPictureScreen(imagePath: image.path);
      default:
        return Row(
          children: const [
            Text("Internal error, this shouldn't happen..."),
          ],
        );
    }
  }
}

class ImageData {
  late String imagePath;
  late bool imageStatus;

  ImageData(String imagePath, bool imageStatus) {
    this.imagePath = imagePath;
    this.imageStatus = imageStatus;
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  late ImageData imageData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imageData = ImageData(widget.imagePath, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const IconAndDetail(Icons.photo_rounded, 'Captured Photo Preview'),
          Image.file(File(widget.imagePath)),
          // Text(
          //   'Path: ${widget.imagePath}',
          //   style: TextStyle(
          //     fontSize: 15,
          //   ),
          // ),
          SizedBox(
            height: 30,
          ),
          ElevatedButton(
            child: const Text('Continue'),
            style: ElevatedButton.styleFrom(
                primary: const Color(0xffE09E45),
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                textStyle:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            onPressed: () {
              imageData.imageStatus = true;
              Navigator.of(context).pop(imageData);
            },
          ),
        ],
      ),
    );
  }
}
