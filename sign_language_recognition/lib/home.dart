import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sign_language_recognition/animations/animated_background.dart';
import 'package:sign_language_recognition/animations/fadein.dart';
import 'package:sign_language_recognition/camera.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HomePage({Key key, this.cameras}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Color color1 = Colors.white;
  Color color2 = Colors.white;

  @override
  void initState() {
    super.initState();
    loadModel().then((val) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBackground(
        child: Container(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: FadeIn(
                      delay: 2.0,
                      child: Container(
                        height: 330,
                        width: 200,
                        child: Image.asset(
                          "assets/app_logo.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: FadeIn(
                      delay: 6.0,
                      child: Container(
                        height: 50.0,
                        margin: EdgeInsets.symmetric(
                          horizontal: 70,
                        ),
                        child: FittedBox(
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder: (context, _, __) => Camera(
                                  cameras: widget.cameras,
                                ),
                                opaque: true,
                                transitionDuration: Duration(milliseconds: 500),
                                reverseTransitionDuration: Duration(
                                  milliseconds: 400,
                                ),
                                transitionsBuilder: (BuildContext context,
                                    Animation<double> animation,
                                    Animation<double> secondaryAnimation,
                                    Widget child) {
                                  return SlideTransition(
                                    position: new Tween<Offset>(
                                      begin: const Offset(1.0, 0.0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  );
                                },
                              ));
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(80.0)),
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Let's talk ",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.blue,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  loadModel() async {
    try {
      String res;
      res = await Tflite.loadModel(
        model: 'assets/model_unquant.tflite',
        labels: "assets/labels.txt",
      );
    } catch (e) {
      // print(e);
      print("ERROR");
    }
  }
}
