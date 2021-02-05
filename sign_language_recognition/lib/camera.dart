import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;

  const Camera({Key key, this.cameras}) : super(key: key);
  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  CameraController cameraController;

  @override
  void initState() {
    super.initState();
    print(widget.cameras.length);
    if (widget.cameras == null ?? widget.cameras.length < 1) {
      print("No camera");
    } else {
      cameraController =
          CameraController(widget.cameras[0], ResolutionPreset.high);
      cameraController.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    cameraController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController.value.isInitialized) {
      print("NOT DONE");
      return Container();
    }
    print("DONE");

    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = cameraController.value.previewSize;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.black
            // backgroundColor: Color(0xff64B6FF),
            // elevation: 0,
            ),
        body: OverflowBox(
          maxHeight: screenRatio > previewRatio
              ? screenH
              : screenW / previewW * previewH,
          maxWidth: screenRatio > previewRatio
              ? screenH / previewH * previewW
              : screenW,
          child: CameraPreview(cameraController),
        ),
      ),
    );
  }
}
