part of 'text_detector_view.dart';

class CameraTextDetectorView extends StatefulWidget {
  @override
  _CameraTextDetectorViewState createState() => _CameraTextDetectorViewState();
}

class _CameraTextDetectorViewState extends State<CameraTextDetectorView> {
  CameraController controller;
  List cameras;
  int selectedCameraIdx;
  String imagePath;
  int _frameCounter = 0;
  TextDetector _textDetector = GoogleMlKit.instance.textDetector();

  Future<void> _detectText(CameraImage image) async {
    final bytes = await compute(_concatenatePlanes, image.planes);
    final imageSize = Size(image.height.toDouble(), image.width.toDouble());
    final inputImageData = InputImageData(
        size: imageSize,
        imageRotation: controller.description.sensorOrientation);
    print('sensor Orientation ${controller.description.sensorOrientation}');
    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
    final detects = await _textDetector.processImage(inputImage);
    if(detects.textBlocks.length>0){
      print(detects.textBlocks[0].textLines[0].lineText);
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    availableCameras().then((avlCameras) {
      cameras = avlCameras;
      if (cameras.length > 0) {
        setState(() {
          selectedCameraIdx = 0;
        });
        _initCameraController(cameras[selectedCameraIdx]).then((void v) {});
      } else
        print("\nNo available cameras");
    }).catchError((e) {
      print(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return _cameraPreviewWidget();
  }

  Future _initCameraController(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.medium);
    // controller.value.previewSize =
    controller.addListener(() {
      if (mounted) setState(() => null);
      if (controller.value.hasError) {
        print('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      print(e.toString());
    }

    if (mounted) {
      setState(() {});
    }
  }

  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Loading',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    }

    return SizedBox(
      height: controller.value.previewSize.height,
      width: controller.value.previewSize.width,
      child: Stack(
        children: [
          CameraPreview(controller),
          Positioned(
              bottom: 20,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                          child: const Text('Start streaming'),
                          onPressed: () async {
                            if (controller != null &&
                                !controller.value.isStreamingImages) {
                              controller.startImageStream((image) {
                                if (_frameCounter % 5 == 0) {
                                  _detectText(image);
                                }
                                if (_frameCounter > 1000) _frameCounter = 0;
                              });
                            }
                          }),
                      SizedBox(
                        width: 40,
                      ),
                      RaisedButton(
                        child: const Text('Stop streaming'),
                        onPressed: () async {
                          if (controller != null) {
                            if (controller.value.isStreamingImages)
                              controller.stopImageStream();
                          }
                        },
                      ),
                      SizedBox(
                        width: 40,
                      )
                    ]),
              )),
        ],
      ),
    );
  }
}

Uint8List _concatenatePlanes(List<Plane> planes) {
  final WriteBuffer allBytes = WriteBuffer();
  for (Plane plane in planes) {
    allBytes.putUint8List(plane.bytes);
  }
  return allBytes.done().buffer.asUint8List();
}
