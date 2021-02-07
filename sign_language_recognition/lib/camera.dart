import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sign_language_recognition/model.dart';

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
  int len = 10;

  double accuracy;
  List<Response> responses = [];

  @override
  void initState() {
    super.initState();
    if (widget.cameras == null ?? widget.cameras.length < 1) {
      print("No camera");
    } else {
      cameraController =
          CameraController(widget.cameras[0], ResolutionPreset.ultraHigh);
      cameraController.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        cameraController.startImageStream((CameraImage img) async {
          if (!isStart) return;

          if (!isDetecting) {
            isDetecting = true;
            await Future.delayed(Duration(seconds: 2));
            // Uint8List plane1 = Uint8List.fromList(img.planes[0].bytes.map((i) {
            //   int result = (i / 255.0).round();
            //   return result;
            // }).toList());
            // Uint8List plane2 = Uint8List.fromList(img.planes[1].bytes.map((i) {
            //   int result = (i / 255.0).round();
            //   // print(result);
            //   return result;
            // }).toList());
            // Uint8List plane3 = Uint8List.fromList(img.planes[2].bytes.map((i) {
            //   int result = (i / 255.0).round();
            //   return result;
            // }).toList());

            // Uint8List plane1 = _convertBGRA8888(img, 0);
            // Uint8List plane2 = _convertBGRA8888(img, 1);
            // Uint8List plane3 = _convertBGRA8888(img, 2);

            // print(plane1.length);
            // print(plane2.length);
            // print(plane3.length);
            // final colorImage = preProcessedImageData(img);
            // print(colorImage.length);

            print("----Distance-----");
            // print(plane1.length);
            // print(plane2.length);
            // print(plane3.length);
            // Uint8List plane1 = colorImage.sublist(0, 16384);
            // Uint8List plane2 = colorImage.sublist(16384, 32768);
            // Uint8List plane3 = colorImage.sublist(32768, 49152);

            // await Tflite.runModelOnBinary(
            //   binary: colorImage,
            // ).then((res) {
            //   print(res);
            // });
            // isDetecting = false;
            // return;
            await Tflite.runModelOnFrame(
              bytesList: [
                // plane1,
                // plane2,
                // plane3,
                img.planes[0].bytes,
                img.planes[1].bytes,
                img.planes[2].bytes,
              ],
              asynch: true,
            ).then((recognitions) {
              print(recognitions);
              if (!mounted) return;
              if (!isStart) {
                isDetecting = false;
                return;
              }
              if (recognitions.length < 1) {
                return;
              } else {
                responses.add(Response(
                  label: recognitions.first["label"],
                  confidence: recognitions.first["confidence"] * 100,
                ));
              }
              if (responses.length < len) {
                // return;
              } else if (responses.length % len == 0) {
                int pos = responses.length - 1;
                Map<String, int> map = {};
                for (int i = pos; i >= pos - len + 1; i--) {
                  if (map.containsKey(responses[i].label)) {
                    map[responses[i].label] = map[responses[i].label] + 1;
                  } else {
                    map[responses[i].label] = 1;
                  }
                }
                int max = 0;
                String result = "";
                print("\n----Start----\n");
                map.entries.forEach((a) {
                  print(a.key + " ${a.value}");
                  if (a.value > max) {
                    result = a.key;
                    max = a.value;
                  }
                });
                print("----End----");
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

  Uint8List concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    planes.forEach((Plane plane) => allBytes.putUint8List(plane.bytes));
    return allBytes.done().buffer.asUint8List();
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
                margin: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
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
                          color: Colors.white.withOpacity(0.8),
                          // gradient: LinearGradient(
                          //   colors: [
                          //     Color(0xff374ABE).withOpacity(0.5),
                          //     Color(0xff64B6FF).withOpacity(
                          //       0.3,
                          //     )
                          //   ],
                          //   begin: Alignment.centerLeft,
                          //   end: Alignment.centerRight,
                          // ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          Positioned(
              right: 10,
              top: MediaQuery.of(context).size.height / 2,
              child: buttons()),
        ],
      ),
    );
  }

  Widget buttons() {
    return Container(
      height: 100.0,
      width: 100,
      child: RaisedButton(
        onPressed: () {
          setState(() {
            isStart = !isStart;
            if (!isStart) {
              responses.clear();
            }
          });
        },
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
        padding: EdgeInsets.all(0.0),
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              30.0,
            ),
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

  Future<List<int>> convertImageToPng(CameraImage image) async {
    try {
      imglib.Image img;
      if (image.format.group == ImageFormatGroup.yuv420) {
        // img = _convertYUV420(image);
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        // img = _convertBGRA8888(image);
      }
      imglib.PngEncoder pngEncoder = new imglib.PngEncoder();
      List<int> png = pngEncoder.encodeImage(img);
      return png;
    } catch (e) {
      print("ERROR");
    }
    return null;
  }

  Uint8List preProcessedImageData(CameraImage camImg) {
    final rawRgbImage = convertYUV420toImageColor(camImg);
    final rgbImage = Platform.isAndroid
        ? imglib.copyRotate(
            rawRgbImage,
            90,
          )
        : rawRgbImage;
    return imglib
        .copyResizeCropSquare(rgbImage, 128)
        .getBytes(format: imglib.Format.rgb);
  }

  imglib.Image convertYUV420toImageColor(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel;

    const alpha255 = (0xFF << 24);

    final img = imglib.Image(width, height); // Create Image buffer

    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
        final int index = y * width + x;

        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        img.data[index] = alpha255 | (b << 16) | (g << 8) | r;
      }
    }
    return img;
  }

  Uint8List _convertBGRA8888(CameraImage image, int index) {
    var img = imglib.Image.fromBytes(
      image.width,
      image.height,
      image.planes[index].bytes,
      format: imglib.Format.rgb,
    );
    return imglib.copyResize(img, width: 32, height: 32).getBytes();
  }

  Uint8List _convertYUV420(CameraImage image, int index) {
    var img = imglib.Image(image.width, image.height);

    Plane plane = image.planes[index];
    const int shift = (0xFF << 24);

    for (int x = 0; x < image.width; x++) {
      for (int planeOffset = 0;
          planeOffset < image.height * image.width;
          planeOffset += image.width) {
        final pixelColor = plane.bytes[planeOffset + x];
        var newVal =
            shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;

        img.data[planeOffset + x] = newVal;
      }
    }

    return imglib.copyResize(img, width: 32, height: 32).getBytes();
  }

  Future _speak(String str) async {
    if (!mounted) return;
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(0.9);
    await flutterTts.speak(str);
  }
}
