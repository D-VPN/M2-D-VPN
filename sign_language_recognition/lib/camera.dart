import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
  final FlutterTts flutterTts = FlutterTts();
  bool isStart = false;

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
        if (!isStart) return;

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
              if (!isStart) return;
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
                  _speak(result);
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
    return SafeArea(
      child: Stack(
        children: [
          CameraPreview(cameraController),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              // backgroundColor: Color(0xff64B6FF),
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.blue,
                ),
              ),
              elevation: 0,
            ),
            body: Builder(builder: (context) {
              if (label.isEmpty) return Container();

              return Container(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FadeIn(
                      delay: 0,
                      duration: Duration(seconds: 1),
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 50,
                        ),
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          shape: BoxShape.rectangle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xff374ABE).withOpacity(0.5),
                              Color(0xff64B6FF).withOpacity(
                                0.3,
                              )
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: Text(
                          label,
                          // "$label with ${accuracy.round()}% accuracy",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget buttons() {
    return Container(
      height: 50.0,
      margin: EdgeInsets.symmetric(
        horizontal: 70,
      ),
      child: RaisedButton(
        onPressed: () {
          setState(() {
            isStart = !isStart;
          });
        },
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
        padding: EdgeInsets.all(0.0),
        color: Colors.white,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 300.0,
            minHeight: 50.0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              30.0,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          alignment: Alignment.center,
          child: Text(
            isStart ? "Stop" : "Start",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blue,
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Future _speak(String str) async {
    await flutterTts.setLanguage("hi-IN");
    await flutterTts.setPitch(0.9);
    await flutterTts.speak(str);
  }
}
