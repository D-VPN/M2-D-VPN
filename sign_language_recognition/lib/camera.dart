import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sign_language_recognition/model.dart';
import 'dart:math' as math;

import 'package:tflite/tflite.dart';

import 'animations/fadein.dart';

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;

  const Camera({Key key, this.cameras}) : super(key: key);
  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  CameraController cameraController;
  bool isDetecting = false;
  String label = "";

  double accuracy;
  List<Response> responses = [];

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
          // int startTime = new DateTime.now().millisecondsSinceEpoch;

          if (!isDetecting) {
            isDetecting = true;
            Tflite.runModelOnFrame(
              bytesList: img.planes.map((plane) {
                return plane.bytes;
              }).toList(),
              imageHeight: img.height,
              imageWidth: img.width,
              numResults: 1,
              asynch: true,
            ).then((recognitions) {
              if (!mounted) return;
              // int endTime = new DateTime.now().millisecondsSinceEpoch;
              // print("Time took for detection: ${endTime - startTime}");
              if (recognitions.length < 1) {
                return;
              } else {
                responses.add(Response(
                  label: recognitions.first["label"],
                  confidence: recognitions.first["confidence"] * 100,
                ));
              }
              if (responses.length < 6) {
                // return;
              } else if (responses.length % 6 == 0) {
                int pos = responses.length - 1;
                Map<String, int> map = {};
                for (int i = pos; i >= pos - 5; i--) {
                  if (map.containsKey(responses[i].label)) {
                    map[responses[i].label] = map[responses[i].label]++;
                  } else {
                    map[responses[i].label] = 1;
                  }
                }
                int max = 0;
                String result = "";
                map.entries.forEach((a) {
                  if (a.value > max) {
                    result = a.key;
                    max = a.value;
                  }
                });
                setState(() {
                  label += result;
                  accuracy = 0;
                });
              }

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
      child: Stack(
        children: [
          CameraPreview(cameraController),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              // backgroundColor: Color(0xff64B6FF),
              elevation: 0,
            ),
            body: Builder(builder: (context) {
              if (label.isEmpty) return Container();

              return FadeIn(
                delay: 0,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 50,
                        ),
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
                          // "$label with ${accuracy.round()}% accuracy",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
