import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:tflite/tflite.dart';

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;

  const Camera({Key key, this.cameras}) : super(key: key);
  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  CameraController cameraController;
  bool isDetecting = false;
  String label;

  @override
  void initState() {
    super.initState();
    // print(widget.cameras.length);
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
        cameraController.startImageStream((CameraImage img) {
          if (!isDetecting) {
            isDetecting = true;
            int startTime = new DateTime.now().millisecondsSinceEpoch;
            Tflite.runModelOnFrame(
              bytesList: img.planes.map((plane) {
                return plane.bytes;
              }).toList(),
              imageHeight: img.height,
              imageWidth: img.width,
              numResults: 2,
            ).then((recognitions) {
              // print(recognitions.first["label"]);
              if (recognitions.length < 1)
                setState(() {
                  label = null;
                });
              else
                setState(() {
                  label = recognitions.first["label"];
                });

              isDetecting = false;
            });
          }
        });
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
      return Container();
    }

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
        body: Stack(
          alignment: Alignment.center,
          children: [
            OverflowBox(
              maxHeight: screenRatio > previewRatio
                  ? screenH
                  : screenW / previewW * previewH,
              maxWidth: screenRatio > previewRatio
                  ? screenH / previewH * previewW
                  : screenW,
              child: CameraPreview(cameraController),
            ),
            if (label != null)
              Builder(builder: (context) {
                print("Label : " + label);
                return Positioned(
                  bottom: 100,
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xff374ABE), Color(0xff64B6FF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(
                        30.0,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              })
          ],
        ),
      ),
    );
  }
}
